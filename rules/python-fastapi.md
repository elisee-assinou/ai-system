# Backend Architecture Rules — FastAPI (Clean Architecture)

## 1. ARCHITECTURE PRINCIPLE

The backend follows Clean Architecture strictly.
SQLAlchemy is used for persistence. Alembic for migrations.
FastAPI is a delivery mechanism only — not the application.

Layers (outer → inner):
- Presentation (routers, schemas, dependencies)
- Application (use cases, commands, queries)
- Domain (entities, value objects, domain events, repository interfaces)
- Infrastructure (SQLAlchemy models, repository implementations, external services)

---

## 2. GLOBAL STRUCTURE

src/
├── modules/              → business domains (bounded contexts)
├── shared/               → reusable abstractions
├── core/                 → base classes, event bus, exceptions
├── infrastructure/       → DB session, config, external clients
└── main.py

---

## 3. MODULE STRUCTURE (MANDATORY)

module/
├── domain/
│   ├── entities/         → Pure Python domain entities
│   ├── value_objects/    → Immutable value types
│   ├── events/           → Domain events (dataclasses)
│   ├── exceptions/       → Domain-specific exceptions
│   └── repositories/     → Repository interfaces (ABC)
│
├── application/
│   ├── commands/         → Command definitions + handlers
│   ├── queries/          → Query definitions + handlers
│   ├── dtos/             → Pydantic input/output schemas
│   └── ports/            → External service interfaces
│
├── infrastructure/
│   ├── persistence/      → SQLAlchemy models + repository implementations
│   ├── mappers/          → Domain ↔ ORM mapping
│   └── services/         → External service implementations
│
└── presentation/
├── routers/          → FastAPI routers
├── dependencies/     → FastAPI dependency injection
└── middlewares/      → HTTP middlewares

---

## 4. DOMAIN RULES (STRICT)

- Pure Python only
- No FastAPI imports
- No SQLAlchemy imports
- No Pydantic in domain (use dataclasses or plain Python)
- Entities contain behavior and enforce invariants
- Value objects are immutable (frozen dataclasses)
- Domain events raised inside entities

```python
from dataclasses import dataclass, field
from typing import List
from uuid import UUID, uuid4


@dataclass
class User:
    id: UUID
    email: Email
    _domain_events: List[DomainEvent] = field(default_factory=list, repr=False)

    @classmethod
    def create(cls, email: Email) -> "User":
        user = cls(id=uuid4(), email=email)
        user._domain_events.append(UserCreatedEvent(user_id=user.id))
        return user

    def pull_domain_events(self) -> List[DomainEvent]:
        events = list(self._domain_events)
        self._domain_events.clear()
        return events
```

---

## 5. VALUE OBJECT RULES

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class Email:
    value: str

    def __post_init__(self):
        if "@" not in self.value:
            raise InvalidEmailException(self.value)
        object.__setattr__(self, "value", self.value.lower())
```

Rules:
- Always `frozen=True`
- Self-validating in `__post_init__`
- Equality by value (automatic with dataclasses)

---

## 6. REPOSITORY RULES

Interface in domain (ABC):
```python
from abc import ABC, abstractmethod
from uuid import UUID


class IUserRepository(ABC):

    @abstractmethod
    async def find_by_id(self, user_id: UUID) -> User | None: ...

    @abstractmethod
    async def find_by_email(self, email: Email) -> User | None: ...

    @abstractmethod
    async def save(self, user: User) -> None: ...

    @abstractmethod
    async def delete(self, user_id: UUID) -> None: ...
```

Implementation in infrastructure:
```python
class SQLAlchemyUserRepository(IUserRepository):

    def __init__(self, session: AsyncSession):
        self._session = session

    async def find_by_id(self, user_id: UUID) -> User | None:
        result = await self._session.get(UserOrmModel, user_id)
        return UserMapper.to_domain(result) if result else None

    async def save(self, user: User) -> None:
        orm = UserMapper.to_orm(user)
        await self._session.merge(orm)
```

---

## 7. APPLICATION RULES (USE CASES)

```python
@dataclass
class CreateUserCommand:
    email: str
    password: str


class CreateUserHandler:

    def __init__(
        self,
        user_repository: IUserRepository,
        event_bus: IEventBus,
    ):
        self._user_repository = user_repository
        self._event_bus = event_bus

    async def execute(self, command: CreateUserCommand) -> None:
        email = Email(value=command.email)
        existing = await self._user_repository.find_by_email(email)
        if existing:
            raise UserAlreadyExistsException(command.email)

        user = User.create(email=email)
        await self._user_repository.save(user)
        await self._event_bus.publish_all(user.pull_domain_events())
```

Rules:
- Handlers orchestrate — they contain no business logic
- Business logic lives in domain only
- Commands mutate state
- Queries never mutate state
- One handler per command/query

---

## 8. SQLALCHEMY RULES

- ORM models are separate from domain entities
- ORM models live in infrastructure/persistence only
- Use async SQLAlchemy (AsyncSession)
- Use Alembic for all migrations — never use `create_all()`
- Never expose ORM models outside infrastructure layer
- Use mappers to convert ORM ↔ domain

```python
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from uuid import UUID


class Base(DeclarativeBase):
    pass


class UserOrmModel(Base):
    __tablename__ = "users"

    id: Mapped[UUID] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(unique=True, nullable=False)
    hashed_password: Mapped[str] = mapped_column(nullable=False)
```

---

## 9. PRESENTATION RULES

- Routers are thin — call use cases only
- No business logic in routers
- Use Pydantic v2 for request/response schemas
- Return response schemas only — never domain entities or ORM models
- Use FastAPI dependency injection for use case wiring

```python
router = APIRouter(prefix="/users", tags=["users"])


@router.post("/", status_code=201)
async def create_user(
    body: CreateUserSchema,
    handler: CreateUserHandler = Depends(get_create_user_handler),
) -> None:
    await handler.execute(CreateUserCommand(
        email=body.email,
        password=body.password,
    ))
```

---

## 10. FILE NAMING RULES

- Domain entities → `user.py` (snake_case)
- Value objects → `email.py`
- Commands → `create_user_command.py`
- Queries → `get_user_by_id_query.py`
- Handlers → `create_user_handler.py`
- Repository interfaces → `user_repository_interface.py`
- ORM models → `user_orm_model.py`
- Mappers → `user_mapper.py`
- Routers → `user_router.py`
- Schemas (Pydantic) → `create_user_schema.py`

---

## 11. FORBIDDEN PATTERNS

- Business logic inside handlers or routers
- SQLAlchemy imports inside domain layer
- FastAPI imports inside domain or application layer
- Pydantic models used as domain entities
- Direct ORM queries from routers
- God use cases (>50 lines)
- Anemic domain model
- `create_all()` instead of Alembic migrations
- Sync SQLAlchemy (always async)

---

## 12. AI EXECUTION RULES

Before generating code:
- Determine the bounded context (module)
- Determine the layer
- Determine if it's a command or query
- Generate pure Python domain entity with behavior
- Always generate ABC repository interface in domain
- Always generate SQLAlchemy ORM model separately
- Always generate mapper between ORM and domain
- Always generate Pydantic schema separately from domain entity