# {{PROJECT_NAME}} — {{APP_NAME}}

{{SHORT_DESCRIPTION}}

## Startup

Au début de CHAQUE session, charge systématiquement :
1. `~/ai-system/STARTUP.md` — point d'entrée
2. `~/ai-system/architecture/context.md` — architecture globale
3. `~/ai-system/rules/flutter.md` — règles Flutter
4. `~/ai-system/rules/scribe-graphify.md` — réflexes SCRIBE/Graphify
5. Ce fichier (CLAUDE.md)

Si `.agent/` existe dans ce projet, initialise TENOR avant toute action :
```bash
.agent/workflow/scribe/scribe tenor-init --type extension
```

## Stack

- **Framework** : Flutter {{FLUTTER_VERSION}}
- **Langage** : Dart {{DART_VERSION}}
- **State management** : Bloc/Cubit
- **DI** : GetIt
- **Router** : GoRouter
- **HTTP** : Dio
- **Local storage** : Hive
- **Fonts** : google_fonts

## Architecture

DDD + Clean Architecture + Hexagonal (Ports & Adapters) :

```
lib/
├── core/
│   ├── network/         → api_client, intercepteurs, endpoints
│   ├── di/              → injection_container.dart
│   ├── router/
│   │   ├── app_router.dart → GoRouter routes
│   │   └── app_shell.dart  → layout partagé (TopBar + BottomNav + FAB)
│   ├── theme/           → app_theme, app_colors, text_styles
│   ├── constants/       → app_constants.dart
│   └── utils/           → validators, extensions, date_utils
├── modules/             → bounded contexts
│   └── {module}/
│       ├── domain/      → entities, value_objects, repository interfaces
│       ├── application/ → use cases, events
│       ├── data/        → DTOs, repository impl, remote sources
│       └── presentation/→ screens, blocs, widgets
├── shared/
│   ├── domain/          → value_objects communs, errors, events
│   ├── application/     → interfaces génériques (IUseCase)
│   └── widgets/         → composants réutilisables
└── main.dart
```

## API

- **Base URL** : `{{API_BASE_URL}}`
- **Format** : JSON

## Règles absolues

- **Pas de logique métier** dans les widgets, screens ou Blocs
- **Domain pure** : 0 import Flutter/Dio/GetIt/Hive dans `domain/`
- **Result pattern** : toujours `Result<T, E>`, jamais de throws
- **PORTS dans domain** (interfaces), **ADAPTERS dans data** (implémentations)
- **Mappers obligatoires** : DTO → Entity, jamais de DTO exposé hors de `data/`
- **Factory methods** : `create()` et `fromPersistence()` sur les entités
- **Modules indépendants** : pas de cross-module imports du domain

## SCRIBE + Graphify

### Avant chaque implémentation
```bash
.agent/workflow/scribe/scribe-rag context
.agent/workflow/scribe/scribe-rag challenge "<ce que tu vas faire>"
```
- `STOP` → ne pas implémenter, lire le blocage
- `REVIEW` → lire les warnings, décider
- `PROCEED` → go

### Avant de naviguer dans le code
```bash
cat graphify-out/GRAPH_REPORT.md          # carte structurelle
graphify query "nom du module ou feature" # ~700 tokens vs 50k
```

### Après un bug résolu en > 2 tentatives
→ SCAR immédiat dans le SCRIBE

### Fermeture de session
> "Qu'est-ce qui fera souffrir le prochain LLM si je ne le documente pas ?"

## Workflow

1. Lire CLAUDE.md + `~/ai-system/` + initialiser TENOR si `.agent/` présent
2. Consulter Graphify → `cat graphify-out/GRAPH_REPORT.md`
3. Consulter le SCRIBE → `scribe-rag context` + `scribe-rag challenge`
4. Consulter le backend → voir `CLAUDE.md` du projet pour le chemin du backend
5. Générer dans l'ordre → Domain → Application → Data → Presentation
6. Enregistrer dans GetIt → `core/di/injection_container.dart`
7. Ajouter la route → `core/router/app_router.dart`
8. Valider → `flutter analyze && flutter test`

---
*Elisee ASSINOU*
