# Flutter Architecture Rules (DDD + Clean Architecture + Hexagonal)

## 1. ARCHITECTURE PRINCIPLE

Flutter est un framework de présentation uniquement — pas l'application.
Le projet suit Clean Architecture + Domain-Driven Design + Hexagonal Architecture.

Layers (outer → inner):
- Presentation (Screens, Widgets, Bloc/Cubit)
- Application (Use cases, DTOs, Event handlers)
- Domain (Entities, value objects, repository interfaces, domain events)
- Data (Mappers, repository implementations, remote sources)

Règle de dépendance : les couches externes dépendent des couches internes. Jamais le reverse.

**Ports & Adapters :**
- Domain / Application = PORTS (interfaces)
- Data = ADAPTERS (implémentations concrètes)

Stack:
- Flutter 3.35+ / Dart 3.9+
- Bloc/Cubit — state management
- Dio — HTTP client
- GetIt — injection de dépendances
- GoRouter — routing
- web_socket_channel — WebSocket (chat temps réel)
- Hive — cache local
- freezed + json_serializable — DTOs (code generation)

---

## 2. GLOBAL STRUCTURE

```
lib/
├── core/
│   ├── network/
│   │   ├── api_client.dart          → Dio instance configuré
│   │   ├── api_interceptors.dart    → JWT, logging, error interceptors
│   │   └── api_endpoints.dart       → Toutes les routes API
│   │
│   ├── di/
│   │   └── injection_container.dart → GetIt registration
│   │
│   ├── router/
│   │   ├── app_router.dart          → GoRouter config
│   │   └── route_guards.dart        → Auth guards
│   │
│   ├── errors/
│   │   ├── failures.dart            → Failure classes
│   │   └── exceptions.dart          → Exceptions mapping
│   │
│   ├── theme/
│   │   ├── app_theme.dart           → Thème global
│   │   ├── app_colors.dart          → Couleurs (cf. design system)
│   │   └── app_text_styles.dart     → Typographie
│   │
│   ├── constants/
│   │   └── app_constants.dart       → Constantes globales
│   │
│   └── utils/
│       ├── validators.dart
│       ├── extensions.dart
│       └── date_utils.dart
│
├── modules/                          → Bounded contexts (miroir backend)
│   ├── auth/                         → Connexion OTP + JWT
│   ├── passenger/                    → Profil passager
│   ├── driver/                       → Profil conducteur
│   ├── ride/                         → Courses (passager + conducteur)
│   ├── delivery/                     → Livraison B2B
│   ├── delivery_b2c/                 → Livraison B2C
│   ├── payment/                      → Paiements FedaPay
│   ├── wallet/                       → Portefeuille + transactions
│   ├── notification/                 → Notifications push
│   ├── vehicle/                      → Véhicules
│   ├── promo_code/                   → Codes promo
│   ├── referral/                     → Parrainage
│   ├── document/                     → Documents upload
│   ├── courier/                      → Coursiers
│   ├── partner/                      → Partenaires B2B
│   └── admin/                        → Admin panel
│
├── shared/                           → Shared kernel
│   ├── domain/
│   │   ├── value_objects/           → Value objects réutilisables
│   │   ├── errors/                   → Domain errors
│   │   └── events/                   → Domain event base
│   ├── application/
│   │   └── interfaces/              → IUseCase, IRepository, IEventBus
│   ├── data/
│   │   └── models/                  → Shared DTOs
│   └── widgets/                      → Widgets réutilisables
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── loading_overlay.dart
│       ├── error_snackbar.dart
│       └── status_badge.dart
│
└── main.dart                         → Entry point
```

---

## 3. MODULE STRUCTURE (MANDATORY)

Chaque module DOIT suivre cette structure exacte :

```
module/
├── domain/
│   ├── entities/           → Entités pures Dart (immutables, avec comportement)
│   ├── value_objects/      → Value objects (ex: PassengerId, PhoneNumber, Money)
│   ├── enums/              → Enums du domaine
│   ├── events/             → Domain events
│   └── repositories/       → Interfaces de repository (PORTS)
│
├── application/
│   ├── use_cases/          → Un dossier par use case
│   │   └── <UseCaseName>/
│   │       ├── <use_case_name>_use_case.dart
│   │       └── <use_case_name>_dto.dart
│   └── event_handlers/     → Event handlers (ex: OnRideCompleted)
│
├── data/
│   ├── models/             → DTOs (freezed) + JSON serialization
│   ├── mappers/            → DTO <-> Entity mapping
│   └── repositories/       → Implémentations des repositories (ADAPTERS)
│
└── presentation/
    ├── bloc/               → Bloc/Cubit + events + states
    ├── screens/            → Pages complètes (une par écran)
    └── widgets/            → Widgets spécifiques au module
```

---

## 4. MODULES (MIRROIR BACKEND FOR-YOU-PLATFORM)

### 4.1 auth
- OTP authentication (request OTP, verify OTP par SMS)
- JWT token storage + refresh
- Multi-profiles : User → PassengerProfile / DriverProfile / PartnerProfile

### 4.2 passenger
- Inscription passager (RegisterPassengerUseCase)
- Connexion / mot de passe oublié / reset
- Profil (get, update, change password)
- FCM token management

### 4.3 driver
- Inscription conducteur
- Profil conducteur
- Statut (disponible/occupé)
- Score conducteur

### 4.4 ride (module le plus complexe)
- RequestRide — demande de course
- Matching — DriverScoringService + MatchingOrchestrator
- AcceptRide / RejectRide
- StartRide / CompleteRide / CancelRide
- DriverOffer system (réservation programmée)
- DailyRoute (trajets quotidiens)
- DestinationChange
- Rating
- Surge pricing

### 4.5 delivery (B2B)
- Création livraison
- Suivi commande
- Tournées / rounds
- Entrepôts / warehouses

### 4.6 delivery_b2c (B2C)
- Livraison entre particuliers
- Statuts : PENDING → ACCEPTED → PICKED_UP → IN_TRANSIT → DELIVERED

### 4.7 payment
- Paiement FedaPay
- Mobile Money
- Transaction history
- Validation webhook

### 4.8 wallet
- Solde
- Transactions (crédit / débit)
- Historique

### 4.9 vehicle
- Ajout véhicule
- Vérification documents
- Assignation conducteur

### 4.10 promo_code
- Codes promotionnels
- Validation
- Application à une course

### 4.11 referral
- Code parrainage
- Récompenses
- Stats

### 4.12 document
- Upload documents (Cloudflare R2)
- Vérification

### 4.13 notification
- Notifications push (Firebase)
- Préférences
- Historique

### 4.14 courier
- Gestion coursiers
- Statuts

### 4.15 partner
- Profils partenaires B2B
- Contrats

### 4.16 admin
- Dashboard
- RBAC / permissions
- Modération

---

## 5. DOMAIN RULES (STRICT)

- Dart pur uniquement — aucune dépendance Flutter/Dio/GetIt/Hive
- Les entités sont immutables (class avec `final` fields + `copyWith`)
- Les entités contiennent la logique métier et enforce les invariants
- Les value objects sont auto-validants à la création
- Les interfaces de repository (PORTS) sont définies ici
- Les domain events sont définis ici
- Toujours utiliser des factory methods (`create()`, `fromPersistence()`) — pas de constructeur public

### Entité exemple :
```dart
class PassengerProfile {
  final PassengerId id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? email;
  final bool isVerified;

  const PassengerProfile._({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.email,
    this.isVerified = false,
  });

  factory PassengerProfile.create({
    required PassengerId id,
    required String phoneNumber,
  }) {
    return PassengerProfile._(
      id: id,
      phoneNumber: phoneNumber,
    );
  }

  factory PassengerProfile.fromPersistence({
    required PassengerId id,
    required String phoneNumber,
    String? firstName,
    String? lastName,
    String? email,
    bool isVerified = false,
  }) {
    return PassengerProfile._(
      id: id,
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
      email: email,
      isVerified: isVerified,
    );
  }

  PassengerProfile copyWith({...}) => PassengerProfile._(...);

  PassengerProfile updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) {
    return PassengerProfile._(
      id: id,
      phoneNumber: phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      isVerified: isVerified,
    );
  }
}
```

### Value Object exemple :
```dart
class PassengerId {
  final String value;

  const PassengerId._(this.value);

  factory PassengerId.create() => PassengerId._(Uuid().v4());

  factory PassengerId.fromString(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('PassengerId cannot be empty');
    }
    return PassengerId._(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PassengerId && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
```

### Repository interface (PORT) :
```dart
abstract class IPassengerProfileRepository {
  Future<Result<PassengerProfile>> save(PassengerProfile profile);
  Future<Result<PassengerProfile?>> findById(PassengerId id);
  Future<Result<PassengerProfile?>> findByPhoneNumber(String phoneNumber);
  Future<Result<bool>> existsByPhoneNumber(String phoneNumber);
  Future<Result<void>> delete(PassengerId id);
}
```

---

## 6. DATA LAYER RULES (ADAPTERS)

### Models (DTOs) — freezed + json_serializable :
```dart
@freezed
class PassengerProfileDto with _$PassengerProfileDto {
  const factory PassengerProfileDto({
    @JsonKey(name: '_id') required String id,
    @JsonKey(name: 'phoneNumber') required String phoneNumber,
    @JsonKey(name: 'firstName') String? firstName,
    @JsonKey(name: 'lastName') String? lastName,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'isVerified') @Default(false) bool isVerified,
  }) = _PassengerProfileDto;

  factory PassengerProfileDto.fromJson(Map<String, dynamic> json) =>
      _$PassengerProfileDtoFromJson(json);
}
```

### Mapper — DTO <-> Domain :
```dart
extension PassengerProfileDtoMapper on PassengerProfileDto {
  PassengerProfile toDomain() => PassengerProfile.fromPersistence(
        id: PassengerId.fromString(id),
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
        email: email,
        isVerified: isVerified,
      );
}

extension PassengerProfileMapper on PassengerProfile {
  Map<String, dynamic> toCreatePayload() => {
        'phoneNumber': phoneNumber,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      };

  Map<String, dynamic> toUpdatePayload() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      };
}
```

### Remote source — Dio :
```dart
class PassengerRemoteSource {
  final Dio _dio;

  PassengerRemoteSource(this._dio);

  Future<Result<List<PassengerProfileDto>>> fetchPassengers({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.passengers,
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = (response.data['data'] as List)
          .map((e) => PassengerProfileDto.fromJson(e))
          .toList();
      return Result.ok(list);
    } on DioException catch (e) {
      return Result.fail(Failure.fromDioError(e));
    }
  }
}
```

### Repository Implementation (ADAPTER) :
```dart
class PassengerProfileRepository implements IPassengerProfileRepository {
  final PassengerRemoteSource _remoteSource;

  PassengerProfileRepository(this._remoteSource);

  @override
  Future<Result<PassengerProfile>> save(PassengerProfile profile) async {
    final payload = profile.toCreatePayload();
    final result = await _remoteSource.createPassenger(payload);
    return result.map((dto) => dto.toDomain());
  }

  @override
  Future<Result<PassengerProfile?>> findById(PassengerId id) async {
    final result = await _remoteSource.fetchPassenger(id.value);
    return result.map((dto) => dto?.toDomain());
  }

  @override
  Future<Result<PassengerProfile?>> findByPhoneNumber(String phoneNumber) async {
    final result = await _remoteSource.fetchPassengerByPhone(phoneNumber);
    return result.map((dto) => dto?.toDomain());
  }

  @override
  Future<Result<bool>> existsByPhoneNumber(String phoneNumber) async {
    final result = await _remoteSource.checkPhoneExists(phoneNumber);
    return result.map((exists) => exists);
  }

  @override
  Future<Result<void>> delete(PassengerId id) async {
    return _remoteSource.deletePassenger(id.value);
  }
}
```

---

## 7. APPLICATION LAYER (USE CASES)

```dart
class RegisterPassengerUseCase
    implements IUseCase<RegisterPassengerDto, PassengerProfile> {
  final IPassengerProfileRepository _passengerRepository;
  final IUserRepository _userRepository;
  final IEventPublisher _eventPublisher;

  RegisterPassengerUseCase({
    required IPassengerProfileRepository passengerRepository,
    required IUserRepository userRepository,
    required IEventPublisher eventPublisher,
  })  : _passengerRepository = passengerRepository,
        _userRepository = userRepository,
        _eventPublisher = eventPublisher;

  @override
  Future<Result<PassengerProfile>> execute(RegisterPassengerDto dto) async {
    // 1. Valider l'input via Value Objects
    final passengerId = PassengerId.create();
    final phoneResult = PhoneNumber.create(dto.phoneNumber);
    if (phoneResult.isFailure) return Result.fail(phoneResult.error);

    // 2. Vérifier les règles métier
    final exists = await _passengerRepository.existsByPhoneNumber(dto.phoneNumber);
    if (exists.isSuccess && exists.value) {
      return Result.fail(ProfileAlreadyExistsError());
    }

    // 3. Créer l'entité
    final passenger = PassengerProfile.create(
      id: passengerId,
      phoneNumber: dto.phoneNumber,
    );

    // 4. Persister
    final saved = await _passengerRepository.save(passenger);

    // 5. Publier les événements
    if (saved.isSuccess) {
      await _eventPublisher.publish(PassengerRegisteredEvent(passengerId));
    }

    return saved;
  }
}
```

Règles :
- Un use case = un dossier (`RegisterPassenger/`) avec fichier use case + DTO
- Implémente `IUseCase<Input, Output>`
- `execute()` est l'unique méthode
- Ne contient pas de logique métier — orchestration uniquement
- Retourne `Result<T, E>` — ne throw jamais
- Dépend d'interfaces (PORTS), jamais d'implémentations concrètes

---

## 8. RESULT PATTERN

```dart
class Result<T, E = Failure> {
  final T? _value;
  final E? _error;
  final bool isSuccess;

  const Result._({this._value, this._error, required this.isSuccess});

  factory Result.ok(T value) => Result._(value: value, isSuccess: true);

  factory Result.fail(E error) => Result._(error: error, isSuccess: false);

  bool get isFailure => !isSuccess;

  T get value {
    if (!isSuccess) throw StateError('Cannot get value from failed result');
    return _value!;
  }

  E get error {
    if (isSuccess) throw StateError('Cannot get error from success result');
    return _error!;
  }

  Result<U, E> map<U>(U Function(T value) fn) =>
      isSuccess ? Result.ok(fn(_value!)) : Result.fail(_error!);

  Result<U, E> andThen<U>(Result<U, E> Function(T value) fn) =>
      isSuccess ? fn(_value!) : Result.fail(_error!);

  T unwrapOr(T defaultValue) => isSuccess ? _value! : defaultValue;
}
```

---

## 9. PRESENTATION LAYER RULES

### Bloc pattern avec Result :

```dart
// États
@freezed
class PassengerState with _$PassengerState {
  const factory PassengerState.initial() = _Initial;
  const factory PassengerState.loading() = _Loading;
  const factory PassengerState.loaded(PassengerProfile passenger) = _Loaded;
  const factory PassengerState.error(String message) = _Error;
}

// Bloc
class PassengerBloc extends Bloc<PassengerEvent, PassengerState> {
  final RegisterPassengerUseCase _registerPassenger;
  final GetPassengerProfile _getPassenger;

  PassengerBloc({
    required RegisterPassengerUseCase registerPassenger,
    required GetPassengerProfile getPassenger,
  })  : _registerPassenger = registerPassenger,
        _getPassenger = getPassenger,
        super(const PassengerState.initial()) {
    on<RegisterPassenger>(_onRegisterPassenger);
    on<LoadPassengerProfile>(_onLoadProfile);
  }

  Future<void> _onRegisterPassenger(
    RegisterPassenger event,
    Emitter<PassengerState> emit,
  ) async {
    emit(const PassengerState.loading());
    final result = await _registerPassenger.execute(
      RegisterPassengerDto(phoneNumber: event.phoneNumber),
    );
    result.isSuccess
        ? emit(PassengerState.loaded(result.value))
        : emit(PassengerState.error(result.error.message));
  }
}
```

### Screen :
```dart
class PassengerProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PassengerBloc>()..add(const LoadPassengerProfile()),
      child: BlocBuilder<PassengerBloc, PassengerState>(
        builder: (context, state) => state.map(
          initial: (_) => const SizedBox.shrink(),
          loading: (_) => const LoadingOverlay(),
          loaded: (state) => _ProfileContent(passenger: state.passenger),
          error: (state) => ErrorView(message: state.message),
        ),
      ),
    );
  }
}
```

Règles presentation :
- Les widgets ne contiennent AUCUNE logique métier
- Les screens appellent uniquement le Bloc via des events
- Les widgets reçoivent les données via constructeur
- Un fichier par widget/screen
- Utiliser `const` constructeurs partout où possible

---

## 10. INJECTION DE DÉPENDANCES (GETIT)

```dart
final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  getIt.registerLazySingleton<Dio>(() => createDioClient());

  // Shared
  getIt.registerLazySingleton<IEventPublisher>(() => EventPublisher());

  // Passenger module
  getIt.registerLazySingleton<PassengerRemoteSource>(() => PassengerRemoteSource(getIt()));
  getIt.registerLazySingleton<IPassengerProfileRepository>(
    () => PassengerProfileRepository(getIt()),
  );
  getIt.registerLazySingleton<RegisterPassengerUseCase>(() => RegisterPassengerUseCase(
    passengerRepository: getIt(),
    userRepository: getIt(),
    eventPublisher: getIt(),
  ));
  getIt.registerFactory<PassengerBloc>(() => PassengerBloc(
    registerPassenger: getIt(),
    getPassenger: getIt(),
  ));

  // Ride module
  getIt.registerLazySingleton<RideRemoteSource>(() => RideRemoteSource(getIt()));
  getIt.registerLazySingleton<IRideRepository>(() => RideRepository(getIt()));
  getIt.registerLazySingleton<RequestRideUseCase>(() => RequestRideUseCase(
    rideRepository: getIt(),
    eventPublisher: getIt(),
  ));
  getIt.registerFactory<RideBloc>(() => RideBloc(
    requestRide: getIt(),
    getRideHistory: getIt(),
  ));
}
```

---

## 11. ROUTING (GO ROUTER)

```dart
final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = getIt<AuthBloc>().state.isAuthenticated;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');
    if (!isLoggedIn && !isAuthRoute) return '/auth/login';
    if (isLoggedIn && isAuthRoute) return '/';
    return null;
  },
  routes: [
    // Auth
    GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/auth/otp', builder: (_, __) => const OtpScreen()),

    // Passenger
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/passenger/profile', builder: (_, __) => const PassengerProfileScreen()),

    // Rider (conducteur)
    GoRoute(path: '/driver/dashboard', builder: (_, __) => const DriverDashboardScreen()),
    GoRoute(path: '/driver/profile', builder: (_, __) => const DriverProfileScreen()),

    // Ride
    GoRoute(path: '/ride/request', builder: (_, __) => const RequestRideScreen()),
    GoRoute(
      path: '/ride/:id',
      builder: (_, state) => RideDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(path: '/ride/history', builder: (_, __) => const RideHistoryScreen()),

    // Delivery
    GoRoute(path: '/delivery/new', builder: (_, __) => const NewDeliveryScreen()),
    GoRoute(
      path: '/delivery/:id/track',
      builder: (_, state) => DeliveryTrackingScreen(id: state.pathParameters['id']!),
    ),

    // Wallet
    GoRoute(path: '/wallet', builder: (_, __) => const WalletScreen()),
    GoRoute(path: '/wallet/transactions', builder: (_, __) => const TransactionHistoryScreen()),

    // Notifications
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
  ],
);
```

---

## 12. GESTION DES ERREURS API

```dart
class ApiInterceptors extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      getIt<AuthBloc>().add(const LogoutRequested());
    }
    handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getIt<AuthBloc>().state.token;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class Failure {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const Failure({required this.message, this.statusCode, this.originalError});

  factory Failure.fromDioError(DioException e) {
    return Failure(
      message: e.response?.data['message'] ?? e.message ?? 'Erreur inconnue',
      statusCode: e.response?.statusCode,
      originalError: e,
    );
  }
}
```

---

## 13. ENDPOINTS API (MIROIR BACKEND FOR-YOU-PLATFORM)

```dart
class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL');

  // Auth
  static const String sendOtp = '/api/auth/send-otp';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String refreshToken = '/api/auth/refresh';

  // Users
  static const String users = '/api/users';
  static String userById(String id) => '/api/users/$id';

  // Passengers
  static const String passengers = '/api/passengers';
  static String passengerById(String id) => '/api/passengers/$id';
  static const String passengerRegister = '/api/passengers/register';
  static const String passengerLogin = '/api/passengers/login';

  // Drivers
  static const String drivers = '/api/drivers';
  static String driverById(String id) => '/api/drivers/$id';

  // Rides
  static const String rides = '/api/ride';
  static const String requestRide = '/api/passenger/ride/request';
  static const String acceptRide = '/api/driver/ride/accept';
  static const String startRide = '/api/driver/ride/start';
  static const String completeRide = '/api/driver/ride/complete';
  static const String cancelRide = '/api/ride/cancel';
  static const String rateRide = '/api/ride/rate';
  static String rideById(String id) => '/api/ride/$id';

  // Delivery
  static const String deliveries = '/api/delivery';
  static const String deliveryB2c = '/api/passenger/delivery';

  // Payments
  static const String payment = '/api/payment';
  static const String createPaymentSession = '/api/payment/create-session';
  static const String paymentWebhook = '/api/payment/webhook';

  // Wallet
  static const String wallets = '/api/wallets';
  static String walletById(String id) => '/api/wallets/$id';
  static const String walletTransactions = '/api/wallets/transactions';

  // Vehicles
  static const String vehicles = '/api/vehicles';

  // Notifications
  static const String notifications = '/api/notifications';
  static const String updateFcmToken = '/api/notifications/fcm-token';

  // Documents
  static const String documents = '/api/documents';
  static const String documentUpload = '/api/documents/upload';

  // Promo codes
  static const String promoCode = '/api/admin/promo-codes';
  static const String validatePromoCode = '/api/promo-codes/validate';

  // Health
  static const String health = '/health';
}
```

---

## 14. FILE NAMING RULES

| Élément | Convention | Exemple |
|---------|-----------|---------|
| Entités | `snake_case` | `passenger_profile.dart` |
| Value objects | `snake_case` | `passenger_id.dart`, `phone_number.dart` |
| Enums | `snake_case` | `ride_status.dart` |
| Use cases (dossier) | `snake_case` | `register_passenger/` |
| Use case | `snake_case` + `_use_case.dart` | `register_passenger_use_case.dart` |
| DTOs | `snake_case` + `_dto.dart` | `register_passenger_dto.dart` |
| Repository interface | `i` + `snake_case` + `_repository.dart` | `i_passenger_profile_repository.dart` |
| Repository impl | `snake_case` + `_repository.dart` | `passenger_profile_repository.dart` |
| Remote source | `snake_case` + `_remote_source.dart` | `passenger_remote_source.dart` |
| Mapper | `snake_case` + `_mapper.dart` | `passenger_profile_mapper.dart` |
| Modèles (DTOs) | `snake_case` + `_dto.dart` | `passenger_profile_dto.dart` |
| Bloc | `snake_case` + `_bloc.dart` | `passenger_bloc.dart` |
| Events | `snake_case` + `_event.dart` | `passenger_event.dart` |
| States | `snake_case` + `_state.dart` | `passenger_state.dart` |
| Screens | `snake_case` + `_screen.dart` | `passenger_profile_screen.dart` |
| Widgets | `snake_case` | `passenger_card.dart` |
| Event handlers | `on_` + `_handler.dart` | `on_ride_completed_handler.dart` |
| Interfaces | `i` + `snake_case` | `i_use_case.dart`, `i_event_publisher.dart` |
| Constantes | `snake_case` | `app_colors.dart`, `api_endpoints.dart` |

---

## 15. DOMAIN EVENTS PATTERN

```dart
// Base class
abstract class DomainEvent {
  final String eventName;
  final DateTime occurredAt;
  final String eventId;

  DomainEvent(this.eventName, {DateTime? occurredAt, String? eventId})
      : occurredAt = occurredAt ?? DateTime.now(),
        eventId = eventId ?? const Uuid().v4();

  Map<String, dynamic> getData();
}

// Événement concret
class PassengerRegisteredEvent extends DomainEvent {
  final PassengerId passengerId;

  PassengerRegisteredEvent(this.passengerId)
      : super('passenger.registered');

  @override
  Map<String, dynamic> getData() => {
        'passengerId': passengerId.value,
      };
}

// Event handler
class OnPassengerRegisteredHandler implements IEventHandler<PassengerRegisteredEvent> {
  final INotificationService _notificationService;

  OnPassengerRegisteredHandler(this._notificationService);

  @override
  Future<void> handle(PassengerRegisteredEvent event) async {
    await _notificationService.sendWelcomeSms(event.passengerId);
  }
}

// Event publisher (PORT)
abstract class IEventPublisher {
  Future<void> publish<T extends DomainEvent>(T event);
  Future<void> publishAll(List<DomainEvent> events);
}
```

---

## 16. FORBIDDEN PATTERNS

- Imports Flutter/Dio/GetIt/Hive dans le domain layer
- Logique métier dans les widgets, screens, ou Blocs
- Appels API directs depuis les widgets (toujours via use case + repository)
- Entités avec setter publics (toujours final + copyWith ou factory)
- DTOs exposés hors du data layer (mapper → domain avant)
- Use cases qui throw des exceptions (toujours Result<T, E>)
- Constructeur public sur les entités (utiliser `factory` methods)
- Fichiers > 150 lignes (split si nécessaire)
- `dynamic` sauf dans le JSON parsing
- Cross-module imports du domain (utiliser shared kernel)
- Initialisation GetIt dans les widgets (dans main.dart uniquement)

---

## 17. AI EXECUTION RULES

Avant de générer du code :
1. Déterminer le bounded context (module)
2. Déterminer la couche (domain / application / data / presentation)
3. Créer d'abord l'entité domain (pure Dart, factory methods)
4. Créer le value object si nécessaire
5. Créer l'interface repository (PORT) dans domain
6. Créer le DTO (freezed) dans data/models
7. Créer le mapper dans data/mappers
8. Créer le remote source (Dio) dans data
9. Créer l'implémentation repository (ADAPTER) dans data/repositories
10. Créer le use case + DTO dans application
11. Créer l'event handler si nécessaire
12. Créer le Bloc + Events + States dans presentation
13. Créer le screen et les widgets dans presentation
14. Enregistrer dans GetIt

Toujours suivre l'ordre Domain → Application → Data → Presentation.

---
*Elisee ASSINOU*
