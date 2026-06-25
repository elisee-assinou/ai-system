# AI System — Infrastructure Agentique

Infrastructure de développement assisté par IA basée sur Claude Code. Centralise les règles d'architecture, les agents, les workflows et les skills pour coder avec DDD + Clean Architecture sur n'importe quelle stack.

---

## Table des matières

1. [Installation](#installation)
2. [Nouveau projet backend](#nouveau-projet-backend)
3. [Nouveau projet frontend / Flutter](#nouveau-projet-frontend--flutter)
4. [Projet existant backend](#projet-existant-backend)
5. [Projet existant frontend / Flutter](#projet-existant-frontend--flutter)
6. [Workflow quotidien avec les agents](#workflow-quotidien-avec-les-agents)
7. [SCRIBE + Graphify](#scribe--graphify)
8. [Skills disponibles](#skills-disponibles)
9. [Structure du repo](#structure-du-repo)
10. [Maintenance](#maintenance)

---

## Installation

### Prérequis

- [Claude Code](https://claude.ai/code) installé
- [agent-scribe-graphify](https://github.com/...) cloné dans `~/agent-scribe-graphify/`

### Cloner ce repo

```bash
git clone <url-du-repo> ~/ai-system
```

### Lier les agents Claude Code

```bash
# Les agents sont dans ~/.claude/agents/ — déjà configurés si tu clones ce repo
# Sinon, copier manuellement :
cp -r ~/ai-system/.claude/agents/* ~/.claude/agents/
```

### Lier les skills

```bash
ln -sf ~/ai-system/skills/pixel-perfect ~/.claude/skills/pixel-perfect
ln -sf ~/ai-system/skills/animation-designer ~/.claude/skills/animation-designer
ln -sf ~/ai-system/skills/core-3d-animation ~/.claude/skills/core-3d-animation
ln -sf ~/ai-system/skills/css-animation ~/.claude/skills/css-animation
ln -sf ~/ai-system/skills/cache-audit ~/.claude/skills/cache-audit
```

---

## Nouveau projet backend

### Stacks disponibles

| Stack | Commande |
|-------|---------|
| Express.js + MongoDB | `express` |
| NestJS + PostgreSQL | `nestjs` |
| Django + PostgreSQL | `django` |
| FastAPI + PostgreSQL | `fastapi` |
| Fullstack (Next.js + NestJS + FastAPI) | `fullstack` |

### Étapes

```bash
# 1. Créer le dossier et initialiser git
mkdir mon-api && cd mon-api
git init
npm init -y   # ou poetry init, etc.

# 2. Initialiser avec le template
source ~/ai-system/project-templates/project-init.sh express mon-api "Mon API"
#                                                      ^^^^^^ stack
#                                                             ^^^^^^^ dossier (. pour dossier courant)
#                                                                     ^^^^^^^^^ nom affiché

# 3. Ouvrir Claude Code
claude
```

Le script génère automatiquement :
- `CLAUDE.md` — instructions architecture pour les agents
- `.agent/` — bundle SCRIBE + Graphify + TENOR
- `.gitignore` — exclut `.agent/`, `scribe-out/`, `graphify-out/`, `ai-docs/`
- `.opencode/opencode.json` — config opencode si tu utilises opencode

### Ce que tu dis à Claude

```
"Je veux créer un module User avec inscription, connexion et profil"
```

Les agents s'enchaînent automatiquement :
1. `project-manager` crée le plan
2. `feature-architect-planner` planifie les fichiers à créer
3. `backend-engineer` implémente (domain → application → infrastructure → presentation)
4. `code-quality-reviewer` valide
5. `git-workflow-specialist` commit

---

## Nouveau projet frontend / Flutter

### Frontend (Next.js)

```bash
npx create-next-app@latest mon-frontend
cd mon-frontend

source ~/ai-system/project-templates/project-init.sh nextjs mon-frontend "Mon Frontend"

claude
```

### Flutter

```bash
flutter create --org com.yourcompany mon_app
cd mon_app

source ~/ai-system/project-templates/project-init.sh flutter mon_app "MonApp"

claude
```

Le template Flutter génère un `CLAUDE.md` complet avec :
- Architecture DDD complète (domain → application → data → presentation)
- Règles Bloc/Cubit, GetIt, GoRouter, Dio
- Réflexes SCRIBE + Graphify
- Workflow étape par étape

### Ce que tu dis à Claude (Flutter)

```
"Je veux créer le module auth avec OTP, connexion et gestion du token JWT"
```

L'agent `flutter-mobile-developer` crée dans l'ordre :
1. Domain (entity, value objects, repository interface)
2. Application (use case + DTO)
3. Data (DTO freezed, mapper, remote source, repository impl)
4. Presentation (Bloc, screen, widgets)
5. Registration GetIt + route GoRouter

---

## Projet existant backend

Si le projet a déjà un `CLAUDE.md` → ouvre directement :

```bash
cd ~/mon-projet-existant
claude
```

Si le projet n'a **pas** de `CLAUDE.md` :

```bash
cd ~/mon-projet-existant

# Détecter la stack puis initialiser
source ~/ai-system/project-templates/project-init.sh express .
# ou: nestjs | django | fastapi selon ta stack
```

### Reprendre un projet existant — ce que tu dis

```
"Analyse la structure du projet et dis-moi l'état de l'architecture"
```

L'agent `backend-engineer` va :
1. Lire le `CLAUDE.md` pour comprendre la stack
2. Lire `~/ai-system/rules/<stack>.md` pour les règles
3. Si `.agent/` présent → consulter SCRIBE (mémoire passée) + Graphify (carte du code)
4. Identifier les violations d'architecture
5. Proposer un plan de refactoring

```
"Implémente le module Payment selon notre architecture"
```

```
"Review le module User — il y a des violations ?"
```

```
"Il y a un bug dans le use case RegisterUser, ça fait 3 tentatives que j'essaie"
```
→ l'agent écrira automatiquement un SCAR dans SCRIBE après résolution

---

## Projet existant frontend / Flutter

```bash
cd ~/mon-frontend-existant
claude
```

Si pas de `CLAUDE.md` :

```bash
source ~/ai-system/project-templates/project-init.sh nextjs .
# ou: flutter .
```

### Ce que tu dis

```
"Analyse les composants — lesquels ont de la logique métier ?"
```

```
"Crée la page Dashboard avec les stats et un tableau des dernières commandes"
```

```
"Ce composant fait 450 lignes, réorganise-le"
```
→ `file-refactor-organizer` prend le relai

```
"Review le module auth côté frontend"
```

---

## Workflow quotidien avec les agents

### Les commandes que tu tapes en session

| Tu dis | Ce qui se passe |
|--------|----------------|
| `"implémenter le module X"` | project-manager → architect → engineer → reviewer → git |
| `"Status"` | project-manager donne l'avancement du plan |
| `"Review"` | code-quality-reviewer valide ce qui a été fait |
| `"Module suivant"` | enchaîne automatiquement sur le module suivant du plan |
| `"Stop"` | arrête l'enchaînement automatique |
| `"Commit"` | git-workflow-specialist commit avec un bon message |
| `"Documente cette lib"` | documentation-specialist recherche et écrit dans `ai-docs/` |
| `"Ce fichier fait 400 lignes"` | file-refactor-organizer le découpe |

### Les agents disponibles

| Agent | Modèle | Rôle |
|-------|--------|------|
| `project-manager` | Sonnet | Gère les plans dans `ai-docs/planning/` — backlog → active → completed |
| `feature-architect-planner` | Sonnet | Crée le plan technique avant d'implémenter |
| `backend-engineer` | Sonnet | Code backend complet (auto-détecte Express/Django/NestJS/FastAPI) |
| `frontend-ui-specialist` | Sonnet | Composants, pages, hooks, state (React/Next.js) |
| `flutter-mobile-developer` | Sonnet | Modules Flutter DDD complets |
| `code-quality-reviewer` | Sonnet | Review architecture + lint + tests |
| `git-workflow-specialist` | Sonnet | Commits, branches, worktrees parallèles |
| `documentation-specialist` | **Opus** | Recherche libs (Context7), docs dans `ai-docs/` |
| `file-refactor-organizer` | Sonnet | Split fichiers > 300 lignes |

### Ce que les agents font automatiquement

À chaque session dans un projet avec `.agent/` :
- Lisent le `CLAUDE.md` du projet pour connaître la stack et les règles
- Lisent les fichiers de règles correspondants dans `~/ai-system/rules/`
- Consultent SCRIBE avant d'implémenter (bugs connus, décisions passées)
- Utilisent Graphify au lieu de lire les fichiers bruts

---

## SCRIBE + Graphify

Le bundle `.agent/` est copié dans chaque projet par `project-init.sh`. Il contient trois outils :

| Outil | Rôle |
|-------|------|
| **TENOR** | Init de session — preuve machine que les règles ont été lues |
| **SCRIBE** | Mémoire causale — bugs résolus, décisions archi, patterns |
| **Graphify** | Carte AST temps réel du codebase (~700 tokens vs ~50k en lisant les fichiers) |

### Démarrer une session (dans le projet)

```bash
# Init obligatoire — les agents le font automatiquement
.agent/workflow/scribe/scribe tenor-init --type extension
```

### Avant d'implémenter quoi que ce soit

```bash
# Charger la mémoire du projet
.agent/workflow/scribe/scribe-rag context

# Valider que le plan ne va pas casser quelque chose
.agent/workflow/scribe/scribe-rag challenge "je vais ajouter un système de paiement"
# → PROCEED : go
# → REVIEW : lire les warnings avant de décider
# → STOP : ne pas le faire, la mémoire dit pourquoi
```

### Naviguer dans le code (sans lire les fichiers)

```bash
# Carte de l'architecture en 500 tokens
cat graphify-out/GRAPH_REPORT.md

# Chercher comment un module fonctionne
graphify query "module payment"

# Trouver le chemin entre deux fonctions
graphify path "PaymentController" "WalletDomain"

# Comprendre un composant
graphify explain "AuthBloc"
```

**Règle d'or** :
- `graphify` = QUOI / OÙ / COMMENT (structure du code)
- `scribe` = POURQUOI / DOULEUR / DÉCISION (mémoire causale)

### Après un bug résolu en plus de 2 tentatives

Les agents écrivent automatiquement un **SCAR** (cicatrice) dans SCRIBE :
- `cause_racine` — pourquoi le bug existait
- `resolution` — comment il a été résolu
- `test_binding` — comment le tester

La prochaine fois qu'un agent rencontre un problème similaire, SCRIBE le rappelle.

### Fin de session

```bash
.agent/workflow/scribe/scribe-rag autodream --read-only
```
> "Qu'est-ce qui fera souffrir le prochain LLM si je ne le documente pas ?"

### Mettre à jour le bundle

```bash
cd ~/agent-scribe-graphify && git pull

# Re-copier dans un projet existant si besoin
cp -r ~/agent-scribe-graphify/.agent ~/mon-projet/.agent
```

---

## Skills disponibles

### Skills dans ce repo (versionné)

| Skill | Déclencheur | Usage |
|-------|------------|-------|
| `pixel-perfect` | `/pixel-perfect` | Figma/screenshot → code frontend exact |
| `animation-designer` | "animation", "framer" | Animations Framer Motion + CSS |
| `core-3d-animation` | "3D", "three.js", "GSAP" | Three.js, R3F, BabylonJS, GSAP, Framer Motion |
| `css-animation` | "css animation", "walkthrough" | Walkthroughs HTML/CSS pour démos |
| `cache-audit` | `/cache-audit` | Audit Claude Code vs prompt caching |

### Skills externes (auto-mis à jour)

| Skill | Source |
|-------|--------|
| `ui-ux-promax` | GitHub — `git pull` dans `~/.claude/skills/ui-ux-promax/` |
| `figma-use` | Cursor — mis à jour automatiquement |
| `build-mcp-server`, `build-mcpb`, `build-mcp-app` | Marketplace Claude Code |
| `frontend-design` | Marketplace Claude Code |
| `skill-creator` | Marketplace Claude Code |
| 12 example-skills (canvas, branding, doc...) | Anthropic marketplace |
| `nano-banana` (génération images) | buildatscale marketplace |

### Ajouter un skill

```bash
# 1. Copier dans ai-system (source de vérité)
cp -r ~/mon-skill ~/ai-system/skills/mon-skill

# 2. Créer le symlink global
ln -sf ~/ai-system/skills/mon-skill ~/.claude/skills/mon-skill

# 3. Committer
cd ~/ai-system && git add skills/mon-skill && git commit -m "feat(skills): add mon-skill"
```

---

## Structure du repo

```
ai-system/
├── README.md                          ← ce fichier
├── STARTUP.md                         ← point d'entrée de chaque session
│
├── architecture/
│   └── context.md                     ← stack complète + principes DDD + SCRIBE/Graphify
│
├── rules/                             ← règles par stack (lues par les agents)
│   ├── expressjs.md                      850 lignes — Express + Mongoose + DDD
│   ├── flutter.md                        950 lignes — Flutter + Bloc + DDD
│   ├── django.md                         600 lignes — Django + DRF + Clean Arch
│   ├── nestJs.md                         310 lignes — NestJS + TypeORM + CQRS
│   ├── frontend.md                       290 lignes — Frontend Hexagonal
│   ├── nextjs.md                         250 lignes — Next.js App Router
│   ├── python-fastapi.md                 290 lignes — FastAPI + SQLAlchemy
│   ├── scribe-graphify.md                 85 lignes — Réflexes SCRIBE + Graphify
│   └── tailwind-tokens.md                 70 lignes — Design tokens
│
├── workflows/                         ← procédures par situation
│   ├── new-backend-workflow.md
│   ├── new-frontend-workflow.md
│   ├── existing-backend-workflow.md
│   └── existing-frontend-workflow.md
│
├── prompts/                           ← system prompts pour rôles spécifiques
│   ├── system-architect.md
│   ├── system-fullstack.md
│   ├── system-review.md
│   └── project-specific/              ← prompts propres à ton projet (non partagés)
│
├── project-templates/                 ← init automatique de projets
│   ├── project-init.sh                   script principal
│   ├── CLAUDE.flutter.md                 template CLAUDE.md Flutter
│   ├── express-mongodb.json
│   ├── nestjs-postgres.json
│   ├── fastapi-postgres.json
│   ├── django-postgres.json
│   ├── flutter.json
│   └── nextjs-nestjs-fastapi.json
│
└── skills/                            ← skills Claude Code (symlinks dans ~/.claude/skills/)
    ├── pixel-perfect/
    ├── animation-designer/
    ├── core-3d-animation/
    ├── css-animation/
    └── cache-audit/
```

---

## Maintenance

### Modifier les règles d'architecture

```bash
# Editer le fichier concerné
code ~/ai-system/rules/expressjs.md

# Committer
cd ~/ai-system && git add rules/expressjs.md && git commit -m "fix(rules): ..."
```

### Modifier les agents Claude Code

```bash
code ~/.claude/agents/backend-engineer.md
# Les agents sont dans ~/.claude/agents/, pas versionné dans ce repo
```

### Mettre à jour SCRIBE/Graphify (bundle externe)

```bash
cd ~/agent-scribe-graphify && git pull
```

### Mettre à jour ui-ux-promax

```bash
cd ~/.claude/skills/ui-ux-promax && git pull
```

### Initialiser le bundle sur un projet existant sans `.agent/`

```bash
cd ~/mon-projet
source ~/ai-system/project-templates/project-init.sh express .
# Remplacer 'express' par ta stack réelle
```

### Ajouter ce repo à un nouveau projet sans l'init script

Créer manuellement un `CLAUDE.md` dans la racine du projet avec au minimum :

```markdown
# Mon Projet

## Stack
- Express.js + MongoDB
- Architecture: DDD + Event-driven

## Architecture — OBLIGATOIRE
Lis et applique strictement :
- ~/ai-system/architecture/context.md
- ~/ai-system/rules/expressjs.md

## Workflow sous-agents
1. project-manager → plan
2. feature-architect-planner → plan technique
3. backend-engineer → implémentation
4. code-quality-reviewer → review
5. git-workflow-specialist → commit
```

---

*Elisee ASSINOU*
