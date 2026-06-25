# Workflow — Nouveau Projet Backend

Utilise ce workflow quand tu démarres un nouveau projet backend from scratch.

## Phase 0 : Initialisation SCRIBE/Graphify

Si `.agent/` existe dans le projet :

```bash
.agent/workflow/scribe/scribe tenor-init --type cli
.agent/workflow/scribe/scribe-rag context
```

## Phase 1 : Conception

1. **Demande** : Quelle stack backend ? (Express/NestJS/Django/FastAPI)
2. **Génère la structure** du projet selon Clean Architecture + DDD :
   ```
   src/
     modules/{module-name}/
       domain/
         entities/
         value-objects/
         events/
         repositories/ (interfaces)
       application/
         commands/
         queries/
         handlers/
         use-cases/
       infrastructure/
         persistence/ (ORM models + mappers)
         cache/
         queue/
         external/ (APIs tierces)
       presentation/
         controllers/
         middlewares/
         validators/
     shared/
       kernel/ (base classes: Entity, ValueObject, AggregateRoot, DomainEvent)
       errors/ (domain exceptions)
       utils/
   ```
3. **Configure** TypeScript/Python, ESLint, Prettier, Docker, tests
4. **Définis** le module Kernel (Entity, ValueObject, AggregateRoot, DomainEvent, Result)
5. **Écris** les règles dans `CLAUDE.md` et `ai-docs/decisions.md`

## Phase 2 : Implémentation

Avant chaque module :
```bash
.agent/workflow/scribe/scribe-rag challenge "<module + use cases prévus>"
```

1. Commence par le **Domain** : entités, value objects, interfaces repository
2. Passe à l'**Application** : use cases, handlers, DTOs
3. Termine par l'**Infrastructure** : ORM, mappers, services externes
4. Finis par la **Presentation** : controllers, routes, validation

## Phase 3 : Qualité

- Tests unitaires obligatoires pour chaque use case
- Tests d'intégration pour chaque endpoint
- Documentation Swagger/OpenAPI
- Vérifie : aucune dépendance framework dans domain/

Si `.agent/` présent :
```bash
graphify update .                          # rebuild le graphe
cat graphify-out/GRAPH_REPORT.md          # vérifier god-nodes et blast radius
```

## Phase 4 : Mémoire

```bash
.agent/workflow/scribe/scribe-rag autodream --read-only   # suggestions de documentation
```
Documenter dans SCRIBE : décisions architecturales (GHOST), patterns réutilisables (PAT).

## Règles absolues

- Domain = pure
- Mappers ORM → Domain obligatoires
- Use cases retournent `Result<T>` (pas de throw)
- Événements publiés après persistance, jamais avant
- 1 commande = 1 handler, 1 query = 1 handler

---
*Elisee ASSINOU*
