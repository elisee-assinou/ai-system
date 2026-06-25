# Workflow — Projet Frontend Existant

Utilise ce workflow quand tu reprends un projet frontend déjà existant.

## Phase 0 : Initialisation SCRIBE/Graphify

Si `.agent/` existe dans le projet :

```bash
.agent/workflow/scribe/scribe tenor-init --type cli
.agent/workflow/scribe/scribe-rag context
cat graphify-out/GRAPH_REPORT.md
```

## Phase 1 : Analyse

1. **Graphify d'abord** (si disponible) :
   ```bash
   graphify query "architecture modules composants"
   graphify query "god components violations"
   ```
2. **Lis** `package.json` → stack (Next.js, React, librairies)
3. **Analyse** la structure des dossiers :
   - Existe-t-il une séparation module/layer ?
   - Les composants contiennent-ils de la logique métier ?
   - Y a-t-il un event bus ?
4. **Identifie** les violations :
   - Appels API directs dans les composants ?
   - Business logic dans les hooks/components ?
   - Pas de types/interfaces pour le domain ?
   - Composants > 150 lignes ?
   - Trop de Client Components ?
   - `any` utilisé ?
5. **Consulte le SCRIBE** :
   ```bash
   .agent/workflow/scribe/scribe-rag query "violations composants"
   .agent/workflow/scribe/scribe-rag query "ne pas reproposer"
   ```
6. **Documente** dans `ai-docs/analysis.md`

## Phase 2 : Plan de Refactoring

Avant de planifier :
```bash
.agent/workflow/scribe/scribe-rag challenge "<plan de refactoring UI>"
```

1. **Crée** la structure domain/application/infrastructure/ui si absente
2. **Déplace** progressivement :
   - Types et interfaces → domain/
   - Appels API et services → infrastructure/
   - Logique applicative → application/
   - UI pure → ui/components/
3. **Remplace** les appels API directs par des ports (interfaces)
4. **Ajoute** un event bus pour la communication inter-modules
5. **Extrais** les gros composants (>150 lignes) en sous-composants

## Phase 3 : Exécution

1. **Commence par le socle** : kernel, types, event bus
2. **Avant chaque composant majeur** :
   ```bash
   graphify explain "NomComposant"
   .agent/workflow/scribe/scribe-rag challenge "<refactoring prévu>"
   ```
3. **Migre module par module** (ne jamais tout casser à la fois)
4. **Ajoute des tests** avant chaque refactoring majeur
5. **Vérifie** le rendu visuel après chaque changement
6. **Valide** : `npm run lint`, `npm run typecheck`, `npm test`
7. **Après chaque bug > 2 tentatives** → SCAR immédiat

## Phase 4 : Documentation

1. Mets à jour `CLAUDE.md`
2. Documente les décisions dans `ai-docs/decisions.md`
3. Ajoute des guides de patterns si nécessaire
4. Fermeture de session :
   > "Qu'est-ce qui fera souffrir le prochain LLM si je ne le documente pas ?"

## Checklist Qualité

- [ ] UI = pure presentation (0 business logic)
- [ ] Appels API via infrastructure layer
- [ ] Composants < 150 lignes
- [ ] Server Components par défaut
- [ ] Client Components justifiés
- [ ] Types/interfaces pour tout le domain
- [ ] Event bus pour communication inter-modules
- [ ] Pas de `any`
- [ ] Tests pour les services applicatifs
- [ ] SCRIBE à jour (SCARs, GHOSTs si applicable)
- [ ] Graphify rebuild après changements majeurs
