# Workflow — Projet Frontend Existant

Utilise ce workflow quand tu reprends un projet frontend déjà existant.

## Phase 1 : Analyse

1. **Lis** `package.json` → stack (Next.js, React, librairies)
2. **Analyse** la structure des dossiers :
   - Existe-t-il une séparation module/layer ?
   - Les composants contiennent-ils de la logique métier ?
   - Y a-t-il un event bus ?
3. **Identifie** les violations :
   - Appels API directs dans les composants ?
   - Business logic dans les hooks/components ?
   - Pas de types/interfaces pour le domain ?
   - Composants > 150 lignes ?
   - Trop de Client Components ?
   - `any` utilisé ?
4. **Documente** dans `ai-docs/analysis.md`

## Phase 2 : Plan de Refactoring

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
2. **Migre module par module** (ne jamais tout casser à la fois)
3. **Ajoute des tests** avant chaque refactoring majeur
4. **Vérifie** le rendu visuel après chaque changement
5. **Valide** : `npm run lint`, `npm run typecheck`, `npm test`

## Phase 4 : Documentation

1. Mets à jour `CLAUDE.md`
2. Documente les décisions dans `ai-docs/decisions.md`
3. Ajoute des guides de patterns si nécessaire

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
