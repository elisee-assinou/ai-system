# {{PROJECT_NAME}} — {{APP_NAME}}

## Description

{{SHORT_DESCRIPTION}}

TODO : Decris ici ce que fait l'app, pour qui, et son contexte metier.

## Stack

- **Framework** : Flutter {{FLUTTER_VERSION}}
- **Langage** : Dart {{DART_VERSION}}
- **State management** : Bloc/Cubit
- **DI** : GetIt
- **Router** : GoRouter
- **HTTP** : Dio
- **Local storage** : Hive
- **Fonts** : google_fonts

## Backend

- **Repo** : `../mon-backend`  ← Chemin vers le backend
- **Base URL** : `{{API_BASE_URL}}`
- **Auth** : JWT Bearer token
- **Format reponse** : `{ success: boolean, data: any, message: string }`  ← A adapter
- **Pagination** : `{ data: [], total: number, page: number, limit: number }`  ← A adapter

## Design

- **Style** : TODO (glassmorphic / material / etc.)
- **Palette** :
  - Primary : `#TODO`
  - Background : `#TODO`
  - Text : `#TODO`
  - Error : `#TODO`
  - Success : `#TODO`
- **Fonts** : TODO

## Modules (bounded contexts)

TODO : Liste ici tous les modules/features avec leur statut.

| Module | Description | Statut |
|--------|-------------|--------|
| auth | OTP, JWT, multi-profils | 🔲 A faire |
| user | Profil, compte | 🔲 A faire |
| TODO | TODO | 🔲 A faire |

## Commandes

```bash
flutter run                # Lancer en dev
flutter build apk          # Build Android
flutter build ios          # Build iOS
flutter test               # Tests
flutter analyze            # Analyse statique
```

## Architecture

DDD + Clean Architecture + Hexagonal (Ports & Adapters) :

```
lib/
├── core/
│   ├── network/         → api_client, intercepteurs, endpoints
│   ├── di/              → injection_container.dart
│   ├── router/
│   │   ├── app_router.dart → GoRouter routes
│   │   └── app_shell.dart  → layout partage
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
│   ├── application/     → interfaces generiques (IUseCase)
│   └── widgets/         → composants reutilisables
└── main.dart
```

## Architecture — OBLIGATOIRE

Lis et applique strictement ces fichiers de regles avant de generer du code :
- ~/ai-system/STARTUP.md
- ~/ai-system/architecture/context.md
- ~/ai-system/rules/flutter.md
- ~/ai-system/rules/scribe-graphify.md (si .agent/ present)

## Regles absolues

- **Pas de logique metier** dans les widgets, screens ou Blocs
- **Domain pure** : 0 import Flutter/Dio/GetIt/Hive dans `domain/`
- **Result pattern** : toujours `Result<T, E>`, jamais de throws
- **PORTS dans domain** (interfaces), **ADAPTERS dans data** (implementations)
- **Mappers obligatoires** : DTO → Entity, jamais de DTO expose hors de `data/`
- **Factory methods** : `create()` et `fromPersistence()` sur les entites
- **Modules independants** : pas de cross-module imports du domain

## SCRIBE + Graphify

Initialisation obligatoire au debut de CHAQUE session :
```bash
.agent/workflow/scribe/scribe tenor-init --type extension
```

Avant chaque implementation :
```bash
.agent/workflow/scribe/scribe-rag context
.agent/workflow/scribe/scribe-rag challenge "<ce que tu vas faire>"
```
- STOP → ne pas implementer
- REVIEW → lire les warnings, decider
- PROCEED → go

Avant de naviguer dans le code :
```bash
cat graphify-out/GRAPH_REPORT.md
graphify query "<module ou feature>"
```

Apres un bug resolu en > 2 tentatives → SCAR immediat.
Fin de session → "Qu'est-ce qui fera souffrir le prochain LLM ?"

## Workflow obligatoire — sous-agents

Ne jamais coder directement. Toujours passer par les agents.

### Ordre pour chaque module/feature :
1. **project-manager** — cree le plan, decoupe en taches
2. **feature-architect-planner** — planifie les fichiers a creer
3. **flutter-mobile-developer** — implemente (domain → application → data → presentation)
4. **code-quality-reviewer** — flutter analyze + review
5. **git-workflow-specialist** — commit
6. **project-manager** — marque done, passe au suivant

### Regles absolues :
- Graphify avant lecture de fichiers
- SCRIBE avant implementation
- Jamais git add . → toujours git add <fichiers-specifiques>
- Jamais committer .agent/ scribe-out/ graphify-out/

### Commandes utilisateur :
- "Module suivant" → enchaine
- "Stop" → arrete
- "Status" → project-manager donne l'avancement
- "Review" → code-quality-reviewer valide

## Notes specifiques

TODO : Ajoute ici tout ce que les agents doivent savoir sur ce projet
qui n'est pas derive du code (decisions, contraintes, regles metier, etc.)

---
*Elisee ASSINOU*
