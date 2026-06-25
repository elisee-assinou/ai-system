# Backend Architecture Rules — Django (Clean Architecture + DDD)

## 1. ARCHITECTURE PRINCIPLE

Django is a delivery mechanism only — not the application.
The project follows Clean Architecture and Domain-Driven Design strictly.
Django ORM, DRF, and Celery are infrastructure concerns — never domain concerns.

Layers (outer → inner):
- Presentation (DRF views, serializers, urls)
- Application (use cases, command/query handlers, tasks)
- Domain (entities, value objects, domain events, repository interfaces)
- Infrastructure (Django ORM models, repository implementations, external services)

Dependency rule: outer layers depend on inner layers. Never the reverse.

---

## 2. GLOBAL STRUCTURE

project/
├── config/                   → Django settings, urls, wsgi, asgi
│   ├── settings/
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   ├── urls.py
│   ├── celery.py
│   └── wsgi.py
│
├── modules/                  → business domains (bounded contexts)
│   ├── user/
│   ├── order/
│   ├── payment/
│   └── notification/
│
├── shared/                   → cross-cutting abstractions
│   ├── domain/
│   ├── application/
│   ├── infrastructure/
│   └── presentation/
│
├── manage.py
└── requirements/
├── base.txt
├── development.txt
└── production.txt

---

## 3. MODULE STRUCTURE (MANDATORY)

Each module MUST follow this exact structure:

module/
├── domain/
│   ├── entities/             → Pure Python domain entities
│   ├── value_objects/        → Immutable value types (frozen dataclasses)
│   ├── events/               → Domain event definitions
│   ├── enums/                → Domain enums
│   ├── exceptions/           → Domain-specific exceptions
│   └── repositories/         → Repository interfaces (ABC)
│
├── application/
│   ├── use_cases/            → One folder per use case
│   ├── event_handlers/       → Domain event handlers
│   ├── services/             → Application services (orchestration)
│   └── tasks/                → Celery task definitions (no Celery import)
│
├── infrastructure/
│   ├── persistence/          → Django ORM models + repository implementations
│   ├── mappers/              → Domain ↔ ORM mapping
│   ├── services/             → External service implementations
│   └── tasks/                → Celery task implementations + workers
│
├── presentation/
│   ├── views/                → DRF views (thin)
│   ├── serializers/          → DRF serializers (input/output only)
│   ├── urls.py               → URL routing
│   └── permissions/          → DRF permission classes
│
└── apps.py                   → Django AppConfig

---

## 4. DOMAIN RULES (STRICT)

- Pure Python only
- No Django imports
- No DRF imports
- No Celery imports
- No framework dependency whatsoever
- Entities contain business logic and enforce invariants
- Domain events raised inside entities
- Value objects are immutable (frozen dataclasses)
- Repository interfaces defined here (ABC)

### Entity example:
```python
from dataclasses import dataclass, field
from typing import List
from uuid import UUID, uuid4

from shared.domain.events import DomainEvent
from shared.domain.exceptions import DomainException


@dataclass
class Order:
    id: UUID
    customer_id: UUID
    status: OrderStatus
    items: List[OrderItem]
    total: Money
    _domain_events: List[DomainEvent] = field(default_factory=list, repr=False)

    @classmethod
    def create(cls, customer_id: UUID, items: List[OrderItem]) -> "Order":
        if not items:
            raise EmptyOrderException()

        total = Money.sum(item.subtotal for item in items)
        order = cls(
            id=uuid4(),
            customer_id=customer_id,
            status=OrderStatus.PENDING,
            items=items,
            total=total,
        )
        order._domain_events.append(OrderCreatedEvent(order_id=order.id))
        return order

    def confirm(self) -> None:
        if self.status != OrderStatus.PENDING:
            raise InvalidOrderStatusException(self.status)
        self.status = OrderStatus.CONFIRMED
        self._domain_events.append(OrderConfirmedEvent(order_id=self.id))

    def cancel(self, reason: str) -> None:
        if self.status == OrderStatus.DELIVERED:
            raise CannotCancelDeliveredOrderException()
        self.status = OrderStatus.CANCELLED
        self._domain_events.append(OrderCancelledEvent(
            order_id=self.id,
            reason=reason,
        ))

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
class Money:
    amount: int        # always in cents
    currency: str

    def __post_init__(self):
        if self.amount < 0:
            raise NegativeAmountException(self.amount)
        if len(self.currency) != 3:
            raise InvalidCurrencyException(self.currency)

    def add(self, other: "Money") -> "Money":
        if self.currency != other.currency:
            raise CurrencyMismatchException()
        return Money(amount=self.amount + other.amount, currency=self.currency)

    @classmethod
    def sum(cls, moneys) -> "Money":
        moneys = list(moneys)
        if not moneys:
            raise EmptyMoneyListException()
        result = moneys[0]
        for m in moneys[1:]:
            result = result.add(m)
        return result


@dataclass(frozen=True)
class Email:
    value: str

    def __post_init__(self):
        if "@" not in self.value:
            raise InvalidEmailException(self.value)
        object.__setattr__(self, "value", self.value.lower().strip())
```

Rules:
- Always `frozen=True`
- Self-validating in `__post_init__`
- Immutable always — no setters
- Equality by value (automatic with dataclasses)
- Store Money as cents (int) — never float

---

## 6. DOMAIN EVENT RULES

```python
# Definition (domain layer)
from dataclasses import dataclass
from uuid import UUID

from shared.domain.events import DomainEvent


@dataclass
class OrderCreatedEvent(DomainEvent):
    EVENT_NAME = "order.created"
    order_id: UUID


@dataclass
class OrderConfirmedEvent(DomainEvent):
    EVENT_NAME = "order.confirmed"
    order_id: UUID


# Handler (application layer)
class OnOrderConfirmedHandler:
    def __init__(self, notification_service: INotificationService):
        self._notification_service = notification_service

    async def handle(self, event: OrderConfirmedEvent) -> None:
        await self._notification_service.send_confirmation(event.order_id)
```

Rules:
- Events defined in domain layer — pure Python dataclasses
- Handlers live in application/event_handlers
- Events must NOT contain business logic
- Events published after aggregate persistence — never before
- Use `EVENT_NAME` class constant for registration

---

## 7. REPOSITORY RULES

Interface in domain (ABC):
```python
from abc import ABC, abstractmethod
from uuid import UUID
from typing import List


class IOrderRepository(ABC):

    @abstractmethod
    def find_by_id(self, order_id: UUID) -> Order | None: ...

    @abstractmethod
    def find_by_customer(self, customer_id: UUID) -> List[Order]: ...

    @abstractmethod
    def save(self, order: Order) -> None: ...

    @abstractmethod
    def delete(self, order_id: UUID) -> None: ...
```

Implementation in infrastructure/persistence:
```python
from modules.order.domain.repositories import IOrderRepository
from modules.order.infrastructure.persistence.models import OrderOrmModel
from modules.order.infrastructure.mappers import OrderMapper


class DjangoOrderRepository(IOrderRepository):

    def __init__(self, mapper: OrderMapper):
        self._mapper = mapper

    def find_by_id(self, order_id: UUID) -> Order | None:
        try:
            model = OrderOrmModel.objects.get(id=str(order_id))
            return self._mapper.to_domain(model)
        except OrderOrmModel.DoesNotExist:
            return None

    def find_by_customer(self, customer_id: UUID) -> List[Order]:
        models = OrderOrmModel.objects.filter(
            customer_id=str(customer_id)
        ).select_related("items")
        return [self._mapper.to_domain(m) for m in models]

    def save(self, order: Order) -> None:
        data = self._mapper.to_orm(order)
        OrderOrmModel.objects.update_or_create(
            id=str(order.id),
            defaults=data,
        )
```

---

## 8. USE CASE RULES

```python
from dataclasses import dataclass
from uuid import UUID

from shared.application.types import Result
from shared.application.interfaces import IUseCase, IEventBus


@dataclass
class CreateOrderCommand:
    customer_id: UUID
    items: list[dict]


@dataclass
class CreateOrderResult:
    order_id: UUID


class CreateOrderUseCase(IUseCase[CreateOrderCommand, Result[CreateOrderResult]]):

    def __init__(
        self,
        order_repository: IOrderRepository,
        product_repository: IProductRepository,
        event_bus: IEventBus,
    ):
        self._order_repository = order_repository
        self._product_repository = product_repository
        self._event_bus = event_bus

    def execute(self, command: CreateOrderCommand) -> Result[CreateOrderResult]:
        items = [
            OrderItem.create(
                product=self._product_repository.find_by_id(item["product_id"]),
                quantity=item["quantity"],
            )
            for item in command.items
        ]

        order = Order.create(
            customer_id=command.customer_id,
            items=items,
        )

        self._order_repository.save(order)
        self._event_bus.publish_all(order.pull_domain_events())

        return Result.ok(CreateOrderResult(order_id=order.id))
```

Rules:
- Implements `IUseCase[Input, Output]`
- Returns `Result[T]` — never raises from use case
- Orchestrates only — no business logic
- Publishes domain events after persistence — never before
- One use case per folder

---

## 9. DJANGO ORM RULES

- ORM models are separate from domain entities always
- ORM models live in infrastructure/persistence only
- Use mappers to convert ORM models ↔ domain entities
- Never expose ORM models outside infrastructure layer
- Use migrations for all schema changes — never `migrate --run-syncdb`
- Use `select_related` and `prefetch_related` explicitly — never lazy load in use cases
- Use UUIDs as primary keys

```python
from django.db import models
import uuid


class OrderOrmModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    customer_id = models.UUIDField(db_index=True)
    status = models.CharField(max_length=50)
    total_amount = models.IntegerField()       # cents
    total_currency = models.CharField(max_length=3)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "orders"
        indexes = [
            models.Index(fields=["customer_id", "status"]),
        ]

    def __str__(self):
        return f"Order {self.id} — {self.status}"
```

---

## 10. CELERY RULES

Task definitions in application layer (no Celery import):
```python
# application/tasks/send_order_receipt_task.py
from dataclasses import dataclass


@dataclass
class SendOrderReceiptTask:
    QUEUE_NAME = "order.receipts"
    order_id: str
    customer_id: str
```

Task implementations in infrastructure layer:
```python
# infrastructure/tasks/send_order_receipt.py
from celery import shared_task
from modules.order.application.tasks import SendOrderReceiptTask


@shared_task(
    name=SendOrderReceiptTask.QUEUE_NAME,
    bind=True,
    max_retries=3,
    default_retry_delay=60,
)
def send_order_receipt(self, order_id: str, customer_id: str) -> None:
    try:
        # resolve dependencies manually or via container
        use_case = container.get_send_receipt_use_case()
        use_case.execute(SendOrderReceiptCommand(
            order_id=order_id,
            customer_id=customer_id,
        ))
    except Exception as exc:
        raise self.retry(exc=exc)
```

Rules:
- Task definitions in application layer — no Celery imports
- Task implementations in infrastructure layer only
- Always use `bind=True` with retry logic
- Always use `shared_task` — never `app.task`
- Separate Celery worker entry point
- Queue names defined as class constants

---

## 11. DRF PRESENTATION RULES

- Views are thin — call use cases only
- No business logic in views or serializers
- Serializers for input validation and output formatting only
- Return response DTOs only — never domain entities or ORM models
- Use DRF permissions for authorization — not in use cases

```python
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated


class CreateOrderView(APIView):
    permission_classes = [IsAuthenticated]

    def __init__(self, use_case: CreateOrderUseCase, **kwargs):
        super().__init__(**kwargs)
        self._use_case = use_case

    def post(self, request) -> Response:
        serializer = CreateOrderSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        result = self._use_case.execute(CreateOrderCommand(
            customer_id=request.user.id,
            items=serializer.validated_data["items"],
        ))

        if result.is_failure:
            return Response(
                {"error": str(result.error)},
                status=status.HTTP_400_BAD_REQUEST,
            )

        return Response(
            {"order_id": str(result.value.order_id)},
            status=status.HTTP_201_CREATED,
        )
```

---

## 12. REDIS RULES

Redis is used for:
- Cache (query results, computed data)
- Celery broker and result backend
- Token blacklist (JWT invalidation)
- Verification codes (OTP with TTL)
- Rate limiting

All Redis access via `ICache` interface — never direct redis-py calls outside infrastructure.

---

## 13. DEPENDENCY INJECTION

Django has no built-in IoC container — wire dependencies manually via `AppConfig.ready()` or a dedicated container module per bounded context.

```python
# modules/order/apps.py
from django.apps import AppConfig


class OrderConfig(AppConfig):
    name = "modules.order"

    def ready(self):
        from modules.order.infrastructure.container import OrderContainer
        OrderContainer.wire()
```

```python
# modules/order/infrastructure/container.py
class OrderContainer:
    _order_repository = None
    _create_order_use_case = None

    @classmethod
    def wire(cls):
        from modules.order.infrastructure.persistence.repositories import DjangoOrderRepository
        from modules.order.infrastructure.mappers import OrderMapper
        from modules.order.application.use_cases.create_order import CreateOrderUseCase
        from shared.infrastructure.events import EventBus

        cls._order_repository = DjangoOrderRepository(OrderMapper())
        cls._create_order_use_case = CreateOrderUseCase(
            order_repository=cls._order_repository,
            event_bus=EventBus.instance(),
        )

    @classmethod
    def get_create_order_use_case(cls) -> CreateOrderUseCase:
        return cls._create_order_use_case
```

---

## 14. FILE NAMING RULES

- Domain entities → `order.py` (snake_case)
- Value objects → `money.py`, `email.py`
- Domain events → `order_created_event.py`
- Repository interfaces → `order_repository_interface.py`
- Use cases → `create_order_use_case.py` (one folder)
- Event handlers → `on_order_confirmed_handler.py`
- ORM models → `order_orm_model.py`
- Mappers → `order_mapper.py`
- Serializers → `create_order_serializer.py`
- Views → `order_views.py`
- Tasks (definition) → `send_order_receipt_task.py`
- Tasks (implementation) → `send_order_receipt.py`
- Container → `container.py` per module

---

## 15. FORBIDDEN PATTERNS

- Django ORM imports inside domain or application layer
- DRF imports inside domain or application layer
- Celery imports inside domain or application layer
- Business logic inside views, serializers, or tasks
- ORM models used as domain entities
- Cross-module domain imports (use shared value objects)
- Lazy ORM evaluation inside use cases (always explicit queries)
- Domain events published before persistence
- God use cases (>60 lines)
- Anemic domain model (entities with no behavior)
- Float for monetary values (always use int cents)
- `migrate --run-syncdb` or `create_all()`

---

## 16. AI EXECUTION RULES

Before generating code:
- Determine the bounded context (module)
- Determine the layer
- Determine if it's a use case (mutation) or query (read)
- Generate pure Python domain entity with behavior — never anemic
- Always generate ABC repository interface in domain
- Always generate Django ORM model separately in infrastructure
- Always generate mapper between ORM model and domain entity
- Always generate DRF serializer separately from domain entity
- Always use Result[T] return type on use cases
- Always publish domain events after persistence — never before
- Always use int (cents) for monetary values — never float
---
*Elisee ASSINOU*
