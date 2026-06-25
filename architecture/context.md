# Architecture Context

## Stack

### Frontend
- Next.js (App Router)
- React (functional components only)
- TypeScript (strict mode)
- Tailwind CSS
- Architecture: DDD + Hexagonal + Event-driven
- Rules: see rules/frontend.md

### Backend — NestJS
- NestJS
- TypeScript (strict mode)
- TypeORM + PostgreSQL
- Custom command bus (CQRS)
- Architecture: Clean Architecture + CQRS
- Rules: see rules/nestjs.md

### Backend — Express.js
- Express.js
- TypeScript (strict mode)
- MongoDB + Mongoose
- Redis (cache, token blacklist, OTP, pub/sub)
- BullMQ (job queues + background workers)
- Socket.io (real-time websocket)
- Architecture: DDD + Event-driven
- IoC: manual container per module (no decorator magic)
- Rules: see rules/expressjs.md

### Backend — Django
- Django + Django REST Framework
- Python 3.12+
- PostgreSQL ou MySQL selon projet
- Redis (cache, broker Celery, token blacklist, OTP)
- Celery (tâches async + workers)
- Architecture: Clean Architecture + DDD
- IoC: container manuel par module via AppConfig.ready()
- Rules: see rules/django.md

### Backend — FastAPI
- FastAPI
- Python 3.12+
- SQLAlchemy (async) + Alembic + PostgreSQL
- Architecture: Clean Architecture
- Rules: see rules/python-fastapi.md

### Mobile — Flutter
- Flutter 3.35+ / Dart 3.9+
- Bloc/Cubit — state management
- Dio — HTTP client
- GetIt — injection de dépendances
- GoRouter — routing
- Hive — cache local
- Architecture: DDD + Clean Architecture
- Modules miroir du backend Django (auth, services, payments, chat, notifications)
- Rules: see rules/flutter.md

---

## Core Principles (all layers)

- Clean Architecture: dependency rule is always respected
- Domain is always pure — no framework dependency
- Infrastructure is always replaceable
- Application layer orchestrates, never decides
- UI/Presentation layer is always thin
- No business logic outside domain

---

## Shared Conventions

### Naming
- TypeScript files: PascalCase for classes/components, kebab-case for files (infrastructure), camelCase for hooks
- Python files: snake_case always
- Dart files: snake_case always
- Events: `noun.past-tense` (e.g. `user.created`, `payment.completed`)
- Commands: verb + noun (e.g. `CreateUser`, `UpdateProfile`)
- Queries: `Get` + noun (e.g. `GetUserById`, `ListOrders`)

### Code Quality
- Strongly typed always (no `any` in TS, no untyped in Python)
- Single responsibility per file
- No file over 150 lines (split if needed)
- Explicit over implicit
- Composition over inheritance

### Architecture Boundaries
- No cross-module domain imports
- No framework in domain layer
- No ORM entities outside infrastructure
- No business logic in presentation layer

---

## Module Communication

- Frontend modules communicate via event bus
- Backend modules communicate via domain events
- No direct cross-module service injection

---

## Error Handling

- Domain exceptions for business rule violations
- Application exceptions for orchestration errors
- Infrastructure maps external errors to domain exceptions
- Presentation layer uses exception filters/handlers only

---

## Infrastructure Agentique (SCRIBE + Graphify + TENOR)

Tous les projets initialisés avec `project-init.sh` ont le bundle `.agent/` :

| Outil | Rôle | Commandes clés |
|-------|------|---------------|
| **TENOR** | Init obligatoire de session, preuves machine | `.agent/workflow/scribe/scribe tenor-init --type cli` |
| **SCRIBE** | Mémoire causale (bugs, décisions, patterns) | `scribe-rag context` · `scribe-rag challenge` · `scribe-rag query` |
| **Graphify** | Graphe AST temps réel du codebase | `graphify query` · `graphify explain` · `graphify path` |
| **Fallow** | Dead code, duplication, complexité JS/TS | `fallow dead-code` · `fallow dupes` · `fallow health` |

### Règle d'or
- **Graphify** = QUOI/OÙ/COMMENT (structure du code)
- **SCRIBE** = POURQUOI/DOULEUR/DÉCISION (causalité)

### Réflexes par situation

| Situation | Commande |
|-----------|---------|
| Démarrer une session | `scribe tenor-init --type cli` |
| Comprendre un module | `graphify explain "NomModule"` |
| Avant d'implémenter | `scribe-rag context` + `scribe-rag challenge "<plan>"` |
| Chercher qui appelle quoi | `graphify path "A" "B"` |
| Bug résolu > 2 tentatives | SCAR dans SCRIBE |
| Fin de session | `scribe-rag autodream --read-only` |

### Source du bundle
`~/agent-scribe-graphify/.agent/` — repo Git externe (`git pull` pour mises à jour)
Réflexes complets : `~/ai-system/rules/scribe-graphify.md`
---
*Elisee ASSINOU*
