# Workflow — Projet Backend Existant

Utilise ce workflow quand tu reprends un projet backend déjà existant.

## Phase 0 : Initialisation SCRIBE/Graphify

Si `.agent/` existe dans le projet :

```bash
.agent/workflow/scribe/scribe tenor-init --type cli
.agent/workflow/scribe/scribe-rag context       # mémoire causale existante
cat graphify-out/GRAPH_REPORT.md                # carte structurelle du codebase
```

Ces deux commandes te donnent en ~1200 tokens ce qui prendrait 50k tokens à lire manuellement.

## Phase 1 : Analyse Complète

1. **Graphify d'abord** (si disponible) :
   ```bash
   graphify query "architecture modules"
   graphify query "god nodes violations"
   ```
2. **Lis** `package.json` ou `requirements.txt` → stack et dépendances
3. **Liste** les modules avec leur structure de dossiers
4. **Vérifie** la séparation des couches (domain / application / infrastructure / presentation)
5. **Identifie** les violations d'architecture :
   - Business logic dans les controllers ?
   - Dépendances framework dans domain ?
   - ORM entities utilisées comme domain entities ?
   - Pas de mappers ?
   - Anemic domain models ?
6. **Consulte le SCRIBE** pour les bugs et décisions passés :
   ```bash
   .agent/workflow/scribe/scribe-rag query "violations architecture"
   .agent/workflow/scribe/scribe-rag query "ne pas reproposer"
   ```
7. **Documente** tout dans `ai-docs/analysis.md`

## Phase 2 : Plan de Refactoring

Avant de planifier :
```bash
.agent/workflow/scribe/scribe-rag challenge "<plan de refactoring>"
```

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
3. **Avant chaque module** :
   ```bash
   graphify path "ControllerActuel" "DomainCible"   # blast radius
   .agent/workflow/scribe/scribe-rag challenge "<refactoring prévu>"
   ```
4. **Maintiens** la rétrocompatibilité API pendant le refactoring
5. **Ajoute des tests** avant de modifier du code existant (golden master)
6. **Valide** à chaque étape : `npm test`, `npm run lint`, `npm run typecheck`
7. **Après chaque bug > 2 tentatives** → SCAR immédiat

## Phase 4 : Documentation

1. Mets à jour `CLAUDE.md` avec les patterns du projet
2. Documente les décisions dans `ai-docs/decisions.md`
3. Ajoute des guides dans `ai-docs/` si des patterns sont récurrents
4. Fermeture de session :
   ```bash
   .agent/workflow/scribe/scribe-rag autodream --read-only
   ```
   > "Qu'est-ce qui fera souffrir le prochain LLM si je ne le documente pas ?"

## Checklist Qualité

- [ ] Controllers = dispatch uniquement (0 business logic)
- [ ] Domain = 0 import framework
- [ ] Mappers entre ORM et Domain
- [ ] Entities = comportement (pas anemic)
- [ ] Use cases retournent Result<T>
- [ ] Événements publiés après persistance
- [ ] Pas de `any`
- [ ] Tests présents
- [ ] SCRIBE à jour (SCARs, GHOSTs, PATs si applicable)
- [ ] Graphify rebuild après changements majeurs

---
*Elisee ASSINOU*
