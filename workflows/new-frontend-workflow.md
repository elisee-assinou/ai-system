# Workflow — Nouveau Projet Frontend

Utilise ce workflow quand tu démarres un nouveau projet frontend from scratch.

## Phase 1 : Conception

1. **Stack** : Next.js (App Router) + React + TypeScript strict + Tailwind CSS
2. **Structure** DDD + Hexagonal + Event-driven :
   ```
   src/
     modules/{module-name}/
       domain/
         entities/
         value-objects/
         events/
       application/
         services/
         ports/ (interfaces API)
       infrastructure/
         api/
         storage/
         external/
       ui/
         components/
         pages/
         hooks/
         layouts/
     shared/
       kernel/
       types/
       utils/
   ```
3. **Configure** : TypeScript strict, Tailwind, ESLint, Prettier, tests (Jest/Vitest)
4. **Définis** : event bus pour communication inter-modules
5. **Écris** les règles dans `CLAUDE.md` et `ai-docs/decisions.md`

## Phase 2 : Implémentation

1. Commence par le **Domain** : types, interfaces, events
2. Passe à l'**Application** : services, ports
3. Fais l'**Infrastructure** : API calls, adapters
4. Termine par l'**UI** : Server Components par défaut, Client Components seulement si nécessaire

## Phase 3 : Qualité

- UI ne call jamais l'API directement (passe par application layer)
- Pas de business logic dans les composants
- Composants < 150 lignes
- Tests pour chaque service applicatif

## Règles absolues

- Domain = pur TypeScript (0 React, 0 Next.js)
- UI → Application → Infrastructure (flux unidirectionnel)
- Server Components par défaut
- Client Components uniquement pour interactions utilisateur
- Pas de `any` — TypeScript strict partout
