# Backend Architecture Rules — NestJS (Clean Architecture + CQRS)

## 1. ARCHITECTURE PRINCIPLE

The backend follows Clean Architecture strictly.
CQRS is applied at the application layer via a custom command bus.

Layers (outer → inner):
- Presentation (controllers, resolvers, guards)
- Application (commands, queries, handlers)
- Domain (entities, aggregates, value objects, domain events)
- Infrastructure (repositories, ORM, external services)

Dependency rule: outer layers depend on inner layers. Never the reverse.

---

## 2. GLOBAL STRUCTURE

src/
├── modules/              → business domains (bounded contexts)
├── shared/               → reusable abstractions and utilities
├── core/                 → command bus, event bus, base classes
└── main.ts

---

## 3. MODULE STRUCTURE (MANDATORY)

Each module MUST follow this structure:

module/
├── domain/
│   ├── entities/         → Aggregate roots and entities
│   ├── value-objects/    → Immutable value types
│   ├── events/           → Domain events
│   ├── exceptions/       → Domain-specific exceptions
│   └── repositories/     → Repository interfaces (ports)
│
├── application/
│   ├── commands/         → Command definitions + handlers
│   ├── queries/          → Query definitions + handlers
│   ├── dtos/             → Input/output contracts
│   └── ports/            → External service interfaces
│
├── infrastructure/
│   ├── persistence/      → TypeORM entities + repository implementations
│   ├── mappers/          → Domain ↔ ORM mapping
│   └── services/         → External service implementations
│
└── presentation/
    ├── controllers/      → HTTP controllers
    ├── guards/           → Auth guards
    └── pipes/            → Validation pipes

---

## 4. DOMAIN RULES (STRICT)

- Pure TypeScript only
- No NestJS decorators
- No TypeORM decorators
- No framework dependency whatsoever
- Entities contain business logic and invariants
- Aggregates enforce consistency boundaries
- Value objects are immutable
- Domain events are raised inside aggregates

Example aggregate:

```typescript
export class User {
  private readonly _id: UserId;
  private _email: Email;
  private _domainEvents: DomainEvent[] = [];

  private constructor(id: UserId, email: Email) {
    this._id = id;
    this._email = email;
  }

  static create(id: UserId, email: Email): User {
    const user = new User(id, email);
    user.addDomainEvent(new UserCreatedEvent(id, email));
    return user;
  }

  private addDomainEvent(event: DomainEvent): void {
    this._domainEvents.push(event);
  }

  pullDomainEvents(): DomainEvent[] {
    const events = [...this._domainEvents];
    this._domainEvents = [];
    return events;
  }

  get id(): UserId { return this._id; }
  get email(): Email { return this._email; }
}
```

---

## 5. CQRS RULES (CUSTOM COMMAND BUS)

Commands and queries are dispatched through a custom command bus (not @nestjs/cqrs).

### Command structure:
```typescript
// command definition
export class CreateUserCommand {
  constructor(
    public readonly email: string,
    public readonly password: string,
  ) {}
}

// command handler
export class CreateUserHandler implements ICommandHandler<CreateUserCommand> {
  constructor(
    private readonly userRepository: IUserRepository,
    private readonly eventBus: IEventBus,
  ) {}

  async execute(command: CreateUserCommand): Promise<void> {
    const user = User.create(
      UserId.generate(),
      Email.create(command.email),
    );
    await this.userRepository.save(user);
    await this.eventBus.publishAll(user.pullDomainEvents());
  }
}
```

### Query structure:
```typescript
export class GetUserByIdQuery {
  constructor(public readonly userId: string) {}
}

export class GetUserByIdHandler implements IQueryHandler<GetUserByIdQuery, UserDto> {
  constructor(private readonly userRepository: IUserRepository) {}

  async execute(query: GetUserByIdQuery): Promise<UserDto> {
    const user = await this.userRepository.findById(UserId.from(query.userId));
    if (!user) throw new UserNotFoundException(query.userId);
    return UserMapper.toDto(user);
  }
}
```

### Rules:
- One command = one handler
- One query = one handler
- Handlers contain no business logic — they orchestrate
- Business logic lives in domain only
- Commands mutate state
- Queries never mutate state

---

## 6. REPOSITORY RULES

Interface defined in domain:
```typescript
export interface IUserRepository {
  findById(id: UserId): Promise<User | null>;
  findByEmail(email: Email): Promise<User | null>;
  save(user: User): Promise<void>;
  delete(id: UserId): Promise<void>;
}
```

Implementation in infrastructure:
```typescript
@Injectable()
export class TypeOrmUserRepository implements IUserRepository {
  constructor(
    @InjectRepository(UserOrmEntity)
    private readonly repo: Repository<UserOrmEntity>,
    private readonly mapper: UserMapper,
  ) {}

  async findById(id: UserId): Promise<User | null> {
    const entity = await this.repo.findOne({ where: { id: id.value } });
    return entity ? this.mapper.toDomain(entity) : null;
  }

  async save(user: User): Promise<void> {
    const entity = this.mapper.toOrm(user);
    await this.repo.save(entity);
  }
}
```

---

## 7. VALUE OBJECT RULES

```typescript
export class Email {
  private constructor(private readonly value: string) {}

  static create(value: string): Email {
    if (!value.includes('@')) throw new InvalidEmailException(value);
    return new Email(value.toLowerCase());
  }

  equals(other: Email): boolean {
    return this.value === other.value;
  }

  toString(): string { return this.value; }
}
```

Rules:
- Immutable always
- Self-validating on creation
- No setters
- Equality by value, not reference

---

## 8. TYPEORM RULES

- ORM entities are separate from domain entities
- ORM entities live in infrastructure/persistence only
- Use mappers to convert between ORM ↔ domain
- Never expose ORM entities outside infrastructure
- Use migrations (never synchronize: true in production)

---

## 9. PRESENTATION RULES

- Controllers are thin — dispatch commands/queries only
- No business logic in controllers
- Use class-validator + class-transformer for input validation
- Return DTOs only, never domain entities
- Use pipes globally for validation

```typescript
@Controller('users')
export class UserController {
  constructor(private readonly commandBus: ICommandBus) {}

  @Post()
  async create(@Body() dto: CreateUserDto): Promise<void> {
    await this.commandBus.dispatch(
      new CreateUserCommand(dto.email, dto.password)
    );
  }
}
```

---

## 10. EXCEPTION RULES

- Domain exceptions extend DomainException base class
- Application exceptions extend ApplicationException
- Infrastructure maps external errors to domain/application exceptions
- Controllers never catch domain exceptions directly — use exception filters

---

## 11. FILE NAMING RULES

- Domain entities → `User.ts` (PascalCase)
- Value objects → `Email.ts` (PascalCase)
- Commands → `create-user.command.ts`
- Queries → `get-user-by-id.query.ts`
- Handlers → `create-user.handler.ts`
- Repository interfaces → `user.repository.interface.ts`
- ORM entities → `user.orm-entity.ts`
- Mappers → `user.mapper.ts`
- Controllers → `user.controller.ts`
- DTOs → `create-user.dto.ts`

---

## 12. FORBIDDEN PATTERNS

- Business logic inside handlers
- Domain logic inside controllers
- ORM entities used as domain entities
- Cross-module domain imports
- Direct repository calls from controllers
- TypeORM decorators on domain entities
- Any framework import inside domain layer
- God handlers (>50 lines)
- Anemic domain model (entities with no behavior)

---

## 13. AI EXECUTION RULES

Before generating code:
- Determine the bounded context (module)
- Determine the layer (domain / application / infrastructure / presentation)
- Determine if it's a command (mutation) or query (read)
- Generate domain entity with behavior, not just data
- Always generate repository interface in domain
- Always generate mapper between ORM and domain
- Always generate DTO separate from domain entity