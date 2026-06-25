# Backend Architecture Rules — Express.js (Clean Architecture + Hexagonal + DDD)

## 1. ARCHITECTURE PRINCIPLE

Express.js est un mécanisme de delivery uniquement — pas l'application.
Le projet suit Clean Architecture + Hexagonal Architecture + Domain-Driven Design.

Layers (outer → inner) :
- Presentation (Controllers, Routes, Middlewares, Swagger)
- Application (Use cases, DTOs, Event handlers, Jobs, Application services)
- Domain (Entities, Value objects, Repository interfaces, Domain events, Domain errors)
- Infrastructure (Repository implementations, Mappers, Mongoose models, Auth strategies, Queue, SMS/Email/Push, WebSocket)

**Ports & Adapters :**
- Domain/Application = PORTS (interfaces : `IRideRepository`, `IEventPublisher`, `IJWTStrategy`)
- Infrastructure = ADAPTERS (implémentations : `MongoRideRepository`, `EventPublisher`, `PassengerJWTStrategy`)

Stack:
- Express.js — HTTP layer only
- TypeScript (strict mode)
- MongoDB + Mongoose — persistence
- Redis 7 — cache, session, OTP, pub/sub
- Bull — job queues et background workers
- Socket.io — real-time WebSocket
- Firebase Admin — push notifications
- Twilio / Edok SMS — SMS
- SendGrid — email
- FedaPay — paiement
- Cloudflare R2 (S3) — file storage
- OSRM — routing engine

---

## 2. GLOBAL STRUCTURE

```
src/
├── app.ts                       → Express server entry point
├── start.ts                     → App starter (module-alias)
├── start-worker.ts              → Worker process starter
├── worker.ts                    → Event worker (Bull)
│
├── config/                      → Configuration modules
│   ├── index.ts
│   ├── database.config.ts
│   ├── jwt.config.ts
│   ├── maps.config.ts
│   ├── notification.config.ts
│   ├── payment.config.ts
│   ├── redis.config.ts
│   └── referral.config.ts
│
├── container/                   → IoC containers (WIP → migration)
│   ├── Container.ts
│   ├── setup.ts
│   └── modules/
│       ├── driverContainer.ts
│       ├── paymentContainer.ts
│       ├── rideContainer.ts
│       ├── sharedContainer.ts
│       └── userContainer.ts
│
├── modules/                     → Bounded contexts (18 modules)
│   ├── passenger/
│   ├── driver/
│   ├── ride/
│   ├── delivery/
│   ├── delivery-b2c/
│   ├── payment/
│   ├── wallet/
│   ├── user/
│   ├── notification/
│   ├── vehicle/
│   ├── promo-code/
│   ├── referral/
│   ├── document/
│   ├── courier/
│   ├── partner/
│   ├── admin/
│   └── analytics/
│
├── shared/                      → Shared kernel
│   ├── domain/                  → Value objects, errors, events, interfaces
│   ├── application/             → IUseCase, IRepository, IEventBus, Result
│   ├── infrastructure/          → Implémentations (mongoose, redis, queue, http, ws)
│   └── presentation/            → BaseController, middlewares, swagger
│
└── types/                       → Global type definitions
    └── express.d.ts
```

---

## 3. MODULE STRUCTURE (MANDATORY)

Chaque module DOIT suivre cette structure exacte :

```
module/
├── domain/
│   ├── entities/                → Aggregate roots et entities (pure TS)
│   ├── value-objects/           → Value objects immutables
│   ├── events/                  → Domain event definitions
│   ├── enums/                   → Domain enums
│   └── repositories/            → Repository interfaces (PORTS)
│
├── application/
│   ├── use-cases/               → Un dossier par use case
│   │   └── <UseCaseName>/
│   │       ├── <UseCaseName>UseCase.ts
│   │       └── <UseCaseName>DTO.ts
│   ├── event-handlers/          → Domain event handlers
│   ├── services/                → Application services (orchestration)
│   └── jobs/                    → Job definitions (Bull)
│
├── infrastructure/
│   ├── auth/                    → JWT strategies (PassengerJWTStrategy)
│   ├── persistence/
│   │   ├── mongodb/
│   │   │   ├── models/          → Mongoose schemas/models
│   │   │   ├── repositories/    → Repository ADAPTERS
│   │   │   └── mappers/         → Domain ↔ Persistence mapping
│   │   └── ...
│   ├── services/                → Infrastructure service impls
│   └── ...
│
└── presentation/
    └── http/
        ├── controllers/         → Express controllers (thin)
        ├── routes/              → Routes + DI wiring (composition root)
        └── swagger/             → OpenAPI specs
```

---

## 4. MODULES (BOUNDED CONTEXTS)

### 4.1 user
- Identité globale (User)
- Multi-profiles : un User peut avoir PassengerProfile, DriverProfile, PartnerProfile
- Chaque profil a son propre mot de passe et auth

### 4.2 passenger
- Inscription (RegisterPassengerUseCase)
- Connexion, mot de passe oublié, reset
- Profil (GetPassengerProfile, ChangePassword, DeleteProfile)
- FCM token (UpdateFcmTokenUseCase)
- SendPhoneOtp / VerifyPhoneOtp
- Login avec mot de passe

### 4.3 driver
- Profil conducteur
- Statut disponible/occupé
- Driver scoring

### 4.4 ride (module le plus complexe — 28 use cases)
- RequestRide — demande de course
- MatchingOrchestrator + DriverScoringService + SurgeService
- AcceptRide / RejectRide / CancelRide
- StartRide / CompleteRide
- DriverOffer — réservation programmée
- DailyRoute — trajets quotidiens
- OfferBooking — réservation d'offre
- DestinationChange
- SubmitRating
- DispatchTimeoutJob / SurgeDispatchJob
- Event handlers : OnDriverOfferPublished, OnRideRequested, OnRideCompletedRestoreDriver, OnRideCompletedUpdateDriverStats

### 4.5 delivery (B2B)
- Création livraison, suivi
- Commandes, tournées (rounds), entrepôts (warehouses)
- 15+ controllers

### 4.6 delivery-b2c (B2C)
- Livraison entre particuliers
- Statuts : PENDING → ACCEPTED → PICKED_UP → IN_TRANSIT → DELIVERED

### 4.7 payment
- FedaPay integration
- Mobile Money
- Transaction lifecycle
- Webhook validation

### 4.8 wallet
- Solde, transactions, historique
- Paiement split

### 4.9 vehicle
- Ajout, vérification, assignation conducteur

### 4.10 promo-code
- Création, validation, application

### 4.11 referral
- Code parrainage, récompenses

### 4.12 document
- Upload (Cloudflare R2), vérification

### 4.13 notification
- SMS (Twilio/Edok), Email (SendGrid), Push (Firebase), WebSocket

### 4.14 courier
- Gestion coursiers

### 4.15 partner
- Profils partenaires B2B

### 4.16 admin
- Dashboard, RBAC, permissions

---

## 5. DOMAIN RULES (STRICT)

- Pure TypeScript uniquement
- Aucun import Express, Mongoose, Redis, Bull, Socket.io
- Aucune dépendance framework
- Les entités contiennent la logique métier et enforce les invariants
- Les domain events sont levés à l'intérieur des aggregates
- Les value objects sont immutables et auto-validants
- Constructeur privé + factory methods `create()` et `fromPersistence()`
- Repository interfaces (PORTS) définies ici

### Entité exemple :
```typescript
export class PassengerProfile implements IProfileWithPassword {
    private constructor(private props: PassengerProfileProps) {}

    static create(props: CreatePassengerProfileProps): PassengerProfile {
        return new PassengerProfile({
            id: PassengerId.create(),
            userId: props.userId,
            phoneNumber: props.phoneNumber,
            password: Password.create(props.password),
            isVerified: false,
            createdAt: new Date(),
            updatedAt: new Date(),
        });
    }

    static fromPersistence(props: PassengerProfileProps): PassengerProfile {
        return new PassengerProfile(props);
    }

    async verifyPassword(plainPassword: string): Promise<boolean> {
        return this.props.password.verify(plainPassword);
    }

    async changePassword(oldPassword: string, newPassword: Password): Promise<void> {
        if (!(await this.verifyPassword(oldPassword))) {
            throw new InvalidPasswordError();
        }
        this.props.password = newPassword;
    }

    updateFcmToken(token: string): void {
        this.props.fcmToken = token;
    }

    // Getters
    get id(): PassengerId { return this.props.id; }
    get phoneNumber(): string { return this.props.phoneNumber; }
    get isVerified(): boolean { return this.props.isVerified; }
}
```

---

## 6. VALUE OBJECT RULES

```typescript
export class PassengerId {
    private constructor(private readonly _value: string) {
        if (!_value || _value.trim().length === 0) {
            throw new Error('PassengerId cannot be empty');
        }
    }

    static create(): PassengerId { return new PassengerId(uuidv4()); }
    static fromString(value: string): PassengerId { return new PassengerId(value); }

    get value(): string { return this._value; }

    equals(other: PassengerId): boolean { return this._value === other._value; }
}
```

Règles :
- Classe avec constructeur privé
- Factory methods `create()` (génération) et `fromString()` (reconstitution)
- Immutable
- Self-validating à la création
- Méthode `equals()` pour comparaison par valeur

---

## 7. DOMAIN EVENT RULES

```typescript
export abstract class DomainEvent {
    public readonly occurredAt: Date;
    public readonly eventId: string;

    constructor(
        public readonly eventName: string,
        occurredAt?: Date,
    ) {
        this.occurredAt = occurredAt ?? new Date();
        this.eventId = uuidv4();
    }

    abstract getData(): Record<string, any>;
}

// Événement concret
export class PassengerRegisteredEvent extends DomainEvent {
    constructor(public readonly passengerId: PassengerId) {
        super('passenger.registered');
    }

    getData(): Record<string, any> {
        return { passengerId: this.passengerId.value };
    }
}

// Handler (application layer)
export class OnPassengerRegisteredHandler implements IEventHandler<PassengerRegisteredEvent> {
    constructor(private readonly notificationService: INotificationService) {}

    async handle(event: PassengerRegisteredEvent): Promise<void> {
        await this.notificationService.sendWelcomeSms(event.passengerId);
    }
}
```

Règles :
- Events définis dans domain layer
- Handlers dans `application/event-handlers/`
- Les events ne contiennent PAS de logique métier
- Les events sont publiés APRÈS la persistence

---

## 8. REPOSITORY RULES (PORTS & ADAPTERS)

### Interface dans domain (PORT) :
```typescript
export interface IPassengerProfileRepository {
    save(profile: PassengerProfile): Promise<void>;
    findById(id: PassengerId): Promise<PassengerProfile | null>;
    findByUserId(userId: UserId): Promise<PassengerProfile | null>;
    findByPhoneNumber(phoneNumber: string): Promise<PassengerProfile | null>;
    existsByUserId(userId: UserId): Promise<boolean>;
    delete(id: PassengerId): Promise<void>;
}
```

### Implémentation dans infrastructure (ADAPTER) :
```typescript
export class PassengerProfileRepository implements IPassengerProfileRepository {
    async save(profile: PassengerProfile): Promise<void> {
        const document = PassengerProfileMapper.toPersistence(profile);
        await PassengerProfileModel
            .findByIdAndUpdate(document._id, document, { upsert: true, new: true })
            .exec();
    }

    async findById(id: PassengerId): Promise<PassengerProfile | null> {
        const doc = await PassengerProfileModel.findById(id.value).exec();
        return doc ? PassengerProfileMapper.toDomain(doc) : null;
    }
}
```

---

## 9. MAPPER RULES

Le mapper est OBLIGATOIRE — aucun domaine entity n'est jamais sauvegardé directement en MongoDB.

```typescript
export class PassengerProfileMapper {
    static toPersistence(profile: PassengerProfile): any {
        return {
            _id: profile.id.value,
            userId: profile.userId.value,
            phoneNumber: profile.phoneNumber,
            password: profile.password.value,
            firstName: profile.firstName,
            lastName: profile.lastName,
            email: profile.email,
            isVerified: profile.isVerified,
            fcmToken: profile.fcmToken,
        };
    }

    static toDomain(document: IPassengerProfileDocument): PassengerProfile {
        return PassengerProfile.fromPersistence({
            id: PassengerId.fromString(document._id),
            userId: UserId.fromString(document.userId),
            phoneNumber: document.phoneNumber,
            password: document.password,
            firstName: document.firstName,
            lastName: document.lastName,
            email: document.email,
            isVerified: document.isVerified,
            fcmToken: document.fcmToken,
            createdAt: document.createdAt,
            updatedAt: document.updatedAt,
        });
    }
}
```

---

## 10. USE CASE RULES

```typescript
export class RegisterPassengerUseCase
    implements IUseCase<RegisterPassengerDTO, { user: User; profile: PassengerProfile }>
{
    constructor(
        private readonly passengerProfileRepository: IPassengerProfileRepository,
        private readonly userRepository: IUserRepository,
        private readonly eventPublisher: IEventPublisher,
    ) {}

    async execute(
        dto: RegisterPassengerDTO,
    ): Promise<Result<{ user: User; profile: PassengerProfile }, Error>> {
        // 1. Valider l'input via Value Objects
        const phoneNumber = PhoneNumber.create(dto.phoneNumber);

        // 2. Vérifier les règles métier
        const exists = await this.passengerProfileRepository.existsByPhoneNumber(dto.phoneNumber);
        if (exists) return Result.fail(new ProfileAlreadyExistsError());

        // 3. Créer l'entité
        const user = User.create({ role: UserRole.PASSENGER });
        const profile = PassengerProfile.create({
            userId: user.id,
            phoneNumber: dto.phoneNumber,
            password: dto.password,
        });

        // 4. Persister
        await this.userRepository.save(user);
        await this.passengerProfileRepository.save(profile);

        // 5. Publier les événements
        await this.eventPublisher.publish(new PassengerRegisteredEvent(profile.id));

        return Result.ok({ user, profile });
    }
}
```

Règles :
- Implémente `IUseCase<Input, Output>`
- Un dossier par use case (UseCase.ts + DTO.ts)
- Retourne `Result<T, E>` — ne throw jamais
- Orchestration uniquement — pas de logique métier
- Publie les domain events APRÈS la persistence

---

## 11. MONGOOSE RULES

- Mongoose models dans `infrastructure/persistence/mongodb/models/` uniquement
- Toujours mapper Mongoose Document ↔ Domain Entity
- Jamais exporter de documents Mongoose hors de l'infrastructure
- Index définis dans le schema

```typescript
const PassengerProfileSchema = new Schema({
    _id: { type: String, required: true },
    userId: { type: String, required: true, index: true },
    phoneNumber: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    firstName: { type: String },
    lastName: { type: String },
    email: { type: String },
    isVerified: { type: Boolean, default: false },
    fcmToken: { type: String },
}, { timestamps: true });

PassengerProfileSchema.index({ phoneNumber: 1 });
PassengerProfileSchema.index({ userId: 1 });

export const PassengerProfileModel = model<IPassengerProfileDocument>(
    'PassengerProfile',
    PassengerProfileSchema,
);
```

---

## 12. RESULT PATTERN

```typescript
export class Result<T, E = Error> {
    public readonly isSuccess: boolean;
    public readonly isFailure: boolean;

    private constructor(
        private readonly _value?: T,
        private readonly _error?: E,
        isSuccess: boolean,
    ) {
        this.isSuccess = isSuccess;
        this.isFailure = !isSuccess;
    }

    static ok<T, E = Error>(value: T): Result<T, E> {
        return new Result<T, E>(value, undefined, true);
    }

    static fail<T, E = Error>(error: E): Result<T, E> {
        return new Result<T, E>(undefined, error, false);
    }

    get value(): T {
        if (!this.isSuccess) throw new Error('Cannot get value from failed result');
        return this._value!;
    }

    get error(): E {
        if (this.isSuccess) throw new Error('Cannot get error from success result');
        return this._error!;
    }

    map<U>(fn: (value: T) => U): Result<U, E> {
        return this.isSuccess ? Result.ok(fn(this._value!)) : Result.fail(this._error!);
    }

    andThen<U>(fn: (value: T) => Result<U, E>): Result<U, E> {
        return this.isSuccess ? fn(this._value!) : Result.fail(this._error!);
    }

    unwrapOr(defaultValue: T): T {
        return this.isSuccess ? this._value! : defaultValue;
    }

    match<U>(onSuccess: (value: T) => U, onFailure: (error: E) => U): U {
        return this.isSuccess ? onSuccess(this._value!) : onFailure(this._error!);
    }
}
```

---

## 13. PRESENTATION RULES

### Controller (thin — appelle uniquement le use case) :
```typescript
export class RegisterPassengerController {
    constructor(
        private readonly registerPassengerUseCase: RegisterPassengerUseCase,
    ) {}

    async handle(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const result = await this.registerPassengerUseCase.execute({
                phoneNumber: req.body.phoneNumber,
                password: req.body.password,
            });

            if (result.isFailure) {
                res.status(400).json({ success: false, error: result.error.message });
                return;
            }

            res.status(201).json({ success: true, data: result.value });
        } catch (error) {
            next(error);
        }
    }
}
```

Règles :
- Les controllers sont thin — appellent les use cases uniquement
- Pas de logique métier dans les controllers ou routes
- Retournent des DTOs uniquement — jamais des entités domain ou des documents Mongoose
- Résultats HTTP mappés dans le controller

### Routes = Composition Root (DI Wiring) :
```typescript
export function createPassengerRoutes(): Router {
    const router = Router();

    // 1. Infrastructure
    const passengerProfileRepository = new PassengerProfileRepository();
    const userRepository = new UserRepository();
    const eventPublisher = new EventPublisher(redisConfig);
    const jwtStrategy = new PassengerJWTStrategy(jwtConfig);

    // 2. Use cases
    const registerPassengerUseCase = new RegisterPassengerUseCase(
        passengerProfileRepository,
        userRepository,
        eventPublisher,
    );

    // 3. Controllers
    const registerController = new RegisterPassengerController(registerPassengerUseCase);

    // 4. Routes
    router.post('/register', (req, res, next) => registerController.handle(req, res, next));

    return router;
}
```

---

## 14. EVENT-DRIVEN WORKER PATTERN

### Worker process (`worker.ts`) :
```typescript
// Subscription aux événements
await eventConsumer.subscribe('passenger.registered', sendVerificationCodesHandler);
await eventConsumer.subscribe('ride.requested', onRideRequested);
await eventConsumer.subscribe('ride.completed', onRideCompletedUpdateDriverStats);

// Event consumer (infrastructure/queue/EventConsumer.ts)
export class EventConsumer {
    constructor(private readonly bullQueue: Queue) {}

    async subscribe<T extends DomainEvent>(
        eventName: string,
        handler: IEventHandler<T>,
    ): Promise<void> {
        this.bullQueue.process(eventName, async (job) => {
            await handler.handle(job.data as T);
        });
    }
}
```

### Event publisher (Composite — plusieurs backends) :
```typescript
export class CompositeEventPublisher implements IEventPublisher {
    constructor(private readonly publishers: IEventPublisher[]) {}

    async publish<T extends DomainEvent>(event: T): Promise<void> {
        await Promise.all(this.publishers.map(p => p.publish(event)));
    }
}
```

---

## 15. REDIS RULES

Redis est utilisé pour :
- Cache (résultats de requêtes, computed data)
- Token blacklist (invalidation JWT)
- OTP storage (avec TTL)
- Pub/sub (events cross-service)
- Session data

Accès Redis via `ICache` interface — jamais d'appels `ioredis` directs hors infrastructure.

```typescript
export interface ICache {
    get<T>(key: string): Promise<T | null>;
    set<T>(key: string, value: T, ttlSeconds?: number): Promise<void>;
    delete(key: string): Promise<void>;
    exists(key: string): Promise<boolean>;
}
```

---

## 16. WEBSOCKET RULES (SOCKET.IO)

- Socket.io dans `presentation/websocket/`
- Pas de logique métier dans les handlers WebSocket
- Les handlers WebSocket appellent des use cases uniquement
- Auth middleware appliqué aux connexions socket

---

## 17. NAMING CONVENTIONS

| Élément | Convention | Exemple |
|---------|-----------|---------|
| Modules (dossiers) | `kebab-case` | `delivery-b2c/`, `promo-code/` |
| Entities | `PascalCase` | `PassengerProfile.ts`, `Ride.ts` |
| Value objects | `PascalCase` | `PassengerId.ts`, `PhoneNumber.ts` |
| Use cases (dossier) | `PascalCase` | `RegisterPassenger/` |
| Use cases (fichier) | `PascalCase` + `UseCase.ts` | `RegisterPassengerUseCase.ts` |
| DTOs | `PascalCase` + `DTO.ts` | `RegisterPassengerDTO.ts` |
| Repository interfaces | `I` + `PascalCase` | `IPassengerProfileRepository.ts` |
| Repository impls | `PascalCase` + `Repository.ts` | `PassengerProfileRepository.ts` |
| Mappers | `PascalCase` + `Mapper.ts` | `PassengerProfileMapper.ts` |
| Mongoose models | `PascalCase` + `Model.ts` | `PassengerProfileModel.ts` |
| Controllers | `PascalCase` + `Controller.ts` | `RegisterPassengerController.ts` |
| Routes | `kebab-case` + `.routes.ts` | `passenger.routes.ts` |
| Swagger docs | `kebab-case` + `.swagger.ts` | `passenger.swagger.ts` |
| Event handlers | `On` + `EventName` + `Handler.ts` | `OnRideRequestedHandler.ts` |
| Jobs | `PascalCase` + `Job.ts` | `DispatchTimeoutJob.ts` |
| Services | `PascalCase` + `Service.ts` | `VerificationCodeService.ts` |
| Auth strategies | `PascalCase` + `Strategy.ts` | `PassengerJWTStrategy.ts` |
| Containers | `camelCase` + `Container.ts` | `rideContainer.ts` |
| Interfaces applicatives | `I` + `PascalCase` | `IUseCase.ts`, `IEventPublisher.ts` |
| Config files | `kebab-case` + `.config.ts` | `database.config.ts` |
| Endpoints API | `kebab-case` | `/api/passengers/register` |

---

## 18. FILE SIZE RULES

- Use cases : max 60 lignes
- Controllers : max 30 lignes
- Routes : pas de limite stricte (contient le wiring)
- Entities : pas de limite mais single responsibility
- Fichiers > 150 lignes → split

---

## 19. FORBIDDEN PATTERNS

- Imports Mongoose/Redis/Bull/Socket.io dans domain ou application
- Logique métier dans les controllers, routes, middlewares ou handlers WebSocket
- Imports cross-module du domain (utiliser shared kernel)
- Entités anémiques (sans comportement)
- Appels `ioredis` ou `mongoose` directs hors infrastructure
- Use cases > 60 lignes
- Skip du Result pattern et throw depuis les use cases
- Publication d'events avant la persistence
- Job processors avec logique métier
- Documents Mongoose exposés hors infrastructure

---

## 20. SHARED KERNEL STRUCTURE

```
shared/
├── domain/
│   ├── enums/
│   │   └── VehicleType.ts
│   ├── errors/
│   │   ├── DomainError.ts
│   │   ├── NotFoundError.ts
│   │   ├── ValidationError.ts
│   │   ├── UnauthorizedError.ts
│   │   ├── ForbiddenError.ts
│   │   └── ConflictError.ts
│   ├── events/
│   │   ├── DomainEvent.ts
│   │   ├── IEventHandler.ts
│   │   └── PasswordResetRequestedEvent.ts
│   ├── interfaces/
│   │   ├── IProfileRepository.ts
│   │   └── IProfileWithPassword.ts
│   ├── specifications/
│   │   └── ISpecification.ts
│   └── value-objects/
│       ├── ValueObject.ts
│       ├── Address.ts
│       ├── Coordinates.ts
│       ├── Currency.ts
│       ├── DateRange.ts
│       ├── Distance.ts
│       ├── Email.ts
│       ├── Location.ts
│       ├── Money.ts
│       ├── Password.ts
│       ├── PhoneNumber.ts
│       ├── UserId.ts
│       └── WalletId.ts
│
├── application/
│   ├── interfaces/
│   │   ├── IEventBus.ts
│   │   ├── IEventConsumer.ts
│   │   ├── IEventPublisher.ts
│   │   ├── IJob.ts
│   │   ├── IJWTStrategy.ts
│   │   ├── IMapper.ts
│   │   ├── IRepository.ts
│   │   ├── IUseCase.ts
│   │   └── IVerificationCodeService.ts
│   ├── types/
│   │   ├── PaginationInput.ts
│   │   ├── PaginationOutput.ts
│   │   └── Result.ts
│   └── use-cases/           → Use cases partagés (optionnels)
│       ├── ChangeProfilePassword/
│       ├── ForgotPassword/
│       ├── GetProfile/
│       ├── LoginProfile/
│       ├── ResetPassword/
│       ├── SendPhoneOtp/
│       └── VerifyPhoneOtp/
│
├── infrastructure/
│   ├── auth/JWTService.ts
│   ├── cache/redis/
│   ├── database/mongoose/
│   ├── events/handlers/
│   ├── http/express/
│   ├── logging/winston/
│   ├── queue/
│   │   ├── EventBusAdapter.ts
│   │   ├── EventConsumer.ts
│   │   ├── EventPublisher.ts
│   │   └── CompositeEventPublisher.ts
│   ├── services/
│   │   ├── email/ (SendGrid / mock)
│   │   ├── push/ (Firebase)
│   │   ├── sms/ (Edok / Twilio)
│   │   └── verification/
│   └── utils/
│       ├── DateUtils.ts
│       ├── Encryptor.ts
│       ├── IdGenerator.ts
│       └── Validator.ts
│
└── presentation/
    ├── http/
    │   ├── base/BaseController.ts
    │   ├── middlewares/authMiddleware.ts
    │   └── swagger/swagger.config.ts
    └── websocket/
```

---

## 21. AI EXECUTION RULES

Before generating code:
1. Determine the bounded context (module)
2. Determine the layer (domain / application / infrastructure / presentation)
3. Determine if triggered by HTTP, WebSocket, Job, or Domain Event
4. Generate domain entity with behavior (factory methods + business methods)
5. Always generate value objects for domain primitives (IDs, PhoneNumber, etc.)
6. Always generate repository interface (PORT) in domain
7. Always generate Mongoose model separately in infrastructure/persistence
8. Always generate mapper between Mongoose doc and domain entity
9. Always use Result<T, E> return type on use cases
10. Always publish domain events after persistence, never before
11. Wire dependencies in routes (composition root pattern)
12. Use shared kernel value objects instead of cross-module domain imports
