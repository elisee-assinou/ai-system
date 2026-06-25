# Guide d'utilisation — AI System

Guide pratique complet pour utiliser l'infrastructure agentique au quotidien.

---

## 1. Nouveau projet

### Étape 1 — Créer le projet avec l'outil officiel

```bash
# Backend Node.js (Express, NestJS)
mkdir mon-api && cd mon-api
git init && npm init -y

# Backend Python (Django, FastAPI)
mkdir mon-api && cd mon-api
git init && poetry init

# Frontend Next.js
npx create-next-app@latest mon-frontend --typescript --tailwind --app
cd mon-frontend

# Flutter
flutter create --org com.yourcompany mon_app
cd mon_app
```

### Étape 2 — Ajouter la couche agentique

```bash
source ~/ai-system/project-templates/project-init.sh <stack> <dossier> "<Nom>"
```

| Stack | Commande |
|-------|---------|
| Express.js + MongoDB | `express` |
| NestJS + PostgreSQL | `nestjs` |
| Django + PostgreSQL | `django` |
| FastAPI + PostgreSQL | `fastapi` |
| Next.js | `nextjs` |
| Flutter | `flutter` |
| Fullstack | `fullstack` |

**Exemples :**
```bash
source ~/ai-system/project-templates/project-init.sh express mon-api "Mon API"
source ~/ai-system/project-templates/project-init.sh flutter mon_app "MonApp"
source ~/ai-system/project-templates/project-init.sh nextjs mon-frontend "Mon Frontend"
```

**Ce que le script génère :**
- `CLAUDE.md` — instructions pour les agents (à personnaliser)
- `.agent/` — bundle SCRIBE + Graphify + TENOR
- `.gitignore` — exclut `.agent/`, `scribe-out/`, `graphify-out/`, `ai-docs/`
- `.opencode/opencode.json` — config opencode

### Étape 3 — Personnaliser le CLAUDE.md

Ouvrir le `CLAUDE.md` généré et remplir tous les `TODO` :

```markdown
## Description       → ce que fait le projet, pour qui
## Backend           → repo, base URL, format réponse (si frontend)
## Design            → palette, fonts, style (si frontend)
## Modules           → liste des features avec statuts
## Variables d'env   → les .env nécessaires
## Notes spécifiques → tout ce que les agents doivent savoir
```

### Étape 4 — Ouvrir Claude Code

```bash
claude
```

TENOR init se déclenche automatiquement. Tu parles, les agents codent.

---

## 2. Projet existant

### Étape 1 — Ajouter la couche agentique

```bash
cd ~/mon-projet-existant
source ~/ai-system/project-templates/project-init.sh express .
# Remplacer 'express' par ta stack réelle
```

### Étape 2 — Personnaliser le CLAUDE.md

Le script génère un CLAUDE.md générique. Le personnaliser avec le contexte réel du projet :
- Supprimer les `TODO`
- Ajouter les vrais modules et leur statut
- Documenter les règles spécifiques (ex: JWT sans Bearer, typos API, patterns particuliers)

### Étape 3 — Mettre le SCRIBE à versionner

```bash
# Retirer AGENT-MEMOIRE_PROJECT_STATUS.scribe du gitignore si présent
sed -i '' '/AGENT-MEMOIRE_PROJECT_STATUS\.scribe/d' .gitignore

# Committer
git add CLAUDE.md AGENT-MEMOIRE_PROJECT_STATUS.scribe .gitignore
git commit -m "feat: bootstrap ai-system (SCRIBE + CLAUDE.md)"
```

### Étape 4 — Ouvrir Claude Code

```bash
claude
```

---

## 3. Reprendre un projet déjà configuré

```bash
cd ~/mon-projet
claude
```

C'est tout. Claude lit le `CLAUDE.md`, charge SCRIBE, Graphify est disponible.

---

## 4. Session de travail quotidienne

### Ce que tu tapes

| Commande | Ce qui se passe |
|---------|----------------|
| `"implémenter le module X"` | project-manager → architect → engineer → reviewer → git |
| `"Status"` | project-manager donne l'avancement |
| `"Review"` | code-quality-reviewer valide |
| `"Module suivant"` | enchaîne automatiquement |
| `"Stop"` | arrête |
| `"Commit"` | git-workflow-specialist commit |
| `"Documente cette lib"` | documentation-specialist recherche + écrit dans ai-docs/ |
| `"Ce fichier fait 400 lignes"` | file-refactor-organizer le découpe |

### Ce que SCRIBE/Graphify font automatiquement

```
Démarrage session
  → tenor-init (TENOR vérifie tout, charge la mémoire)
  → scribe-rag context (bugs connus, décisions passées)

Avant chaque implémentation (agents)
  → scribe-rag challenge "<plan>"
  → PROCEED / REVIEW / STOP

Avant de lire du code (agents)
  → graphify query "..."   (700 tokens au lieu de 50 000)

Bug résolu > 2 tentatives (automatique)
  → SCAR écrit dans SCRIBE

Fin de session
  → "Qu'est-ce qui fera souffrir le prochain LLM ?"
  → GHOST si décision archi / SCAR si bug / rien si session normale
```

---

## 5. Les 9 agents — qui fait quoi

| Agent | Modèle | Rôle |
|-------|--------|------|
| `project-manager` | Sonnet | Crée et suit les plans dans `ai-docs/planning/` |
| `feature-architect-planner` | Sonnet | Planifie les fichiers à créer avant d'implémenter |
| `backend-engineer` | Sonnet | Code backend complet (auto-détecte Express/Django/NestJS/FastAPI) |
| `frontend-ui-specialist` | Sonnet | Composants, pages, hooks, state (React/Next.js) |
| `flutter-mobile-developer` | Sonnet | Modules Flutter DDD complets |
| `code-quality-reviewer` | Sonnet | Review architecture + lint + tests |
| `git-workflow-specialist` | Sonnet | Commits, branches, worktrees, PRs |
| `documentation-specialist` | **Opus** | Recherche libs (Context7), docs dans `ai-docs/` |
| `file-refactor-organizer` | Sonnet | Split fichiers > 300 lignes |

---

## 6. SCRIBE — règles d'écriture

| Type | ID | Quand écrire |
|------|----|-------------|
| **SCAR** | `SCAR-XXX` | Bug résolu **après la résolution** (> 2 tentatives) |
| **GHOST** | `GHOST-XXX` | Décision archi prise **en séance** |
| **PAT** | `PAT-XXX` | Pattern réutilisable émergé **du travail** |
| **JOURNAL** | `JOURNAL-XXX` | Automatique à chaque session |

**Ne jamais écrire dans SCRIBE :**
- De la documentation existante (ça va dans `ai-docs/`)
- Des bugs ouverts non résolus (ça va dans `ai-docs/ride-audit.md` ou similar)
- Des décisions déjà dans `CLAUDE.md`

---

## 7. Documentation — qui écrit quoi

| Doc | Agent | Quand |
|-----|-------|-------|
| `CLAUDE.md` | Toi (setup) + agents (màj) | Setup + évolutions majeures |
| `ai-docs/planning/active/` | `project-manager` | Avant chaque feature |
| `ai-docs/planning/completed/` | `project-manager` | Après chaque feature |
| `ai-docs/decisions.md` | `documentation-specialist` | Décisions archi |
| `ai-docs/libraries/` | `documentation-specialist` | Nouvelle lib intégrée |
| `AGENT-MEMOIRE.scribe` | Agents (automatique) | Bug résolu, décision prise |

---

## 8. Worktrees — développement parallèle

### Features indépendantes en parallèle (Claude Code)

```
# Le main thread lance les agents simultanément
Agent(backend-engineer,       isolation: "worktree", prompt: "implement module A")
Agent(frontend-ui-specialist, isolation: "worktree", prompt: "implement module B")
# Nettoyage automatique si rien n'est fait
```

### Features longues en parallèle (Git manuel)

```bash
git worktree add ../projet-feature-auth -b feature/auth-module
cd ../projet-feature-auth && claude   # Terminal 1

git worktree add ../projet-feature-pay -b feature/payment
cd ../projet-feature-pay && claude    # Terminal 2

# Merger quand les deux sont prêts
git merge --no-ff feature/auth-module
git merge --no-ff feature/payment
git worktree remove ../projet-feature-auth
git worktree remove ../projet-feature-pay
```

---

## 9. Ajouter un skill

```bash
# 1. Copier dans ai-system (source de vérité)
cp -r ~/mon-skill ~/ai-system/skills/mon-skill

# 2. Symlink global
ln -sf ~/ai-system/skills/mon-skill ~/.claude/skills/mon-skill

# 3. Committer
cd ~/ai-system
git add skills/mon-skill
git commit -m "feat(skills): add mon-skill"
git push
```

---

## 10. Maintenance

### Mettre à jour SCRIBE/Graphify

```bash
cd ~/agent-scribe-graphify && git pull

# Mettre à jour un projet existant
cp -r ~/agent-scribe-graphify/.agent ~/mon-projet/.agent
```

### Mettre à jour ai-system

```bash
cd ~/ai-system
git add -A
git commit -m "type(scope): description"
git push
```

### Mettre à jour ui-ux-promax

```bash
cd ~/.claude/skills/ui-ux-promax && git pull
```

---

## 11. Repos

| Repo | URL |
|------|-----|
| **ai-system** | https://github.com/elisee-assinou/ai-system |
| **agent-scribe-graphify** | https://github.com/jackjosias/agent-scribe-graphify |

---

*Elisee ASSINOU*
