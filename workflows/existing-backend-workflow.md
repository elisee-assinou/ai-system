# Workflow — Projet Backend Existant

Utilise ce workflow quand tu reprends un projet backend déjà existant.

## Phase 1 : Analyse Complète

1. **Lis** `package.json` ou `requirements.txt` → stack et dépendances
2. **Liste** les modules avec leur structure de dossiers
3. **Vérifie** la séparation des couches (domain / application / infrastructure / presentation)
4. **Identifie** les violations d'architecture :
   - Business logic dans les controllers ?
   - Dépendances framework dans domain ?
   - ORM entities utilisées comme domain entities ?
   - Pas de mappers ?
   - Anemic domain models ?
5. **Documente** tout dans `ai-docs/analysis.md`

## Phase 2 : Plan de Refactoring

1. **Hiérarchise** les problèmes (ordre d'impact)
2. **Propose** un plan par module :
   - Extraire le domain des controllers
   - Créer les mappers ORM → Domain
   - Déplacer la logique métier dans les entities
   - Ajouter les value objects manquants
   - Séparer les use cases
3. **Estime** le risque de chaque changement
4. **Documente** le plan dans `ai-docs/refactoring-plan.md`

## Phase 3 : Exécution

1. **Commence par le kernel** (Entity, ValueObject, Result, DomainEvent) si absent
2. **Refactore module par module** — jamais tous en même temps
3. **Maintiens** la rétrocompatibilité API pendant le refactoring
4. **Ajoute des tests** avant de modifier du code existant (golden master)
5. **Valide** à chaque étape : `npm test`, `npm run lint`, `npm run typecheck`

## Phase 4 : Documentation

1. Mets à jour `CLAUDE.md` avec les patterns du projet
2. Documente les décisions dans `ai-docs/decisions.md`
3. Ajoute des guides dans `ai-docs/` si des patterns sont récurrents

## Checklist Qualité

- [ ] Controllers = dispatch uniquement (0 business logic)
- [ ] Domain = 0 import framework
- [ ] Mappers entre ORM et Domain
- [ ] Entities = comportement (pas anemic)
- [ ] Use cases retournent Result<T>
- [ ] Événements publiés après persistance
- [ ] Pas de `any`
- [ ] Tests présents
