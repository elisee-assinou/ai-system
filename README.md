# AI System — Infrastructure Agentique

Mon infrastructure de développement assisté par IA. Centralise les règles d'architecture, les agents Claude Code, les workflows et les skills.

---

## Ce que c'est

Un répertoire de configuration que tous mes projets partagent. Quand j'ouvre Claude Code sur n'importe quel projet, les agents lisent automatiquement les règles ici et savent comment coder.

```
ai-system/          ← CE repo (règles, workflows, templates)
~/.claude/agents/   ← 9 agents Claude Code spécialisés
~/.claude/skills/   ← Skills Claude Code (symlinks vers ici)
~/agent-scribe-graphify/  ← Bundle SCRIBE + Graphify (repo Git externe)
```

---

## Démarrage rapide

### Nouveau projet

```bash
mkdir mon-projet && cd mon-projet
git init

# Backend
source ~/ai-system/project-templates/project-init.sh express mon-projet "MonProjet"
# ou: nestjs | django | fastapi | flutter | nextjs | fullstack

claude
```

Le script fait tout : copie le bundle `.agent/`, génère le `CLAUDE.md`, configure `.gitignore`.

### Projet existant

```bash
cd ~/mon-projet
claude
```

Claude lit le `CLAUDE.md` local et les agents prennent le relai.

---

## Stacks supportées

| Stack | Règles | Usage |
|-------|--------|-------|
| Express.js + MongoDB | `rules/expressjs.md` | Backend for-you-platform |
| Flutter + Bloc | `rules/flutter.md` | foryou_app, foryou_driver |
| Django + DRF | `rules/django.md` | Backend Python |
| NestJS + TypeORM | `rules/nestJs.md` | Backend TypeScript CQRS |
| FastAPI + SQLAlchemy | `rules/python-fastapi.md` | API Python async |
| Next.js App Router | `rules/frontend.md` + `rules/nextjs.md` | yo-business, miconnect |

Architecture commune : **DDD + Clean Architecture + Hexagonal** sur toutes les stacks.

---

## Agents Claude Code

Les agents se déclenchent automatiquement selon le contexte. Tu parles normalement, ils s'enchaînent.

| Agent | Modèle | Quand |
|-------|--------|-------|
| `project-manager` | Sonnet | Début et fin de chaque feature |
| `feature-architect-planner` | Sonnet | Avant d'implémenter quelque chose de complexe |
| `backend-engineer` | Sonnet | Tout le code backend (auto-détecte la stack) |
| `frontend-ui-specialist` | Sonnet | Composants, pages, hooks, state |
| `flutter-mobile-developer` | Sonnet | Modules Flutter (domain → presentation) |
| `code-quality-reviewer` | Sonnet | Review post-implémentation |
| `git-workflow-specialist` | Sonnet | Commits, branches, worktrees |
| `documentation-specialist` | **Opus** | Recherche libs, docs dans `ai-docs/` |
| `file-refactor-organizer` | Sonnet | Fichiers > 300 lignes |

**Commandes utiles en session :**
```
"implémenter le module X"     → project-manager + architect + engineer s'enchaînent
"Status"                      → project-manager donne l'avancement
"Review"                      → code-quality-reviewer valide
"Module suivant"              → enchaine automatiquement
"Stop"                        → arrête
```

---

## SCRIBE + Graphify

Chaque projet initialisé avec `project-init.sh` a le bundle `.agent/`. Trois outils :

| Outil | Rôle | Commande principale |
|-------|------|-------------------|
| **TENOR** | Init obligatoire de session | `.agent/workflow/scribe/scribe tenor-init --type extension` |
| **SCRIBE** | Mémoire causale du projet | `scribe-rag context` · `scribe-rag challenge "<plan>"` |
| **Graphify** | Carte AST du codebase | `graphify query "<question>"` · `cat graphify-out/GRAPH_REPORT.md` |

### Workflow d'une session

```bash
# 1. Démarrer
.agent/workflow/scribe/scribe tenor-init --type extension

# 2. Avant d'implémenter quoi que ce soit
.agent/workflow/scribe/scribe-rag context
.agent/workflow/scribe/scribe-rag challenge "je vais implémenter X"
# → PROCEED : go | REVIEW : lire warnings | STOP : ne pas faire

# 3. Avant de lire du code (utiliser Graphify, pas grep)
cat graphify-out/GRAPH_REPORT.md
graphify query "module auth"
graphify path "LoginController" "UserDomain"

# 4. Après un bug résolu en > 2 tentatives
# → SCAR dans le SCRIBE (fait automatiquement par les agents)

# 5. Fin de session
.agent/workflow/scribe/scribe-rag autodream --read-only
# → "Qu'est-ce qui fera souffrir le prochain LLM ?"
```

### Mettre à jour le bundle SCRIBE/Graphify

```bash
cd ~/agent-scribe-graphify && git pull
# Re-copier dans un projet si besoin :
cp -r ~/agent-scribe-graphify/.agent ~/mon-projet/.agent
```

---

## Skills disponibles

### Dans ai-system (versionné ici)

| Skill | Usage |
|-------|-------|
| `pixel-perfect` | Figma/screenshot → code frontend exact |
| `animation-designer` | Animations Framer Motion + CSS |
| `core-3d-animation` | Three.js, R3F, BabylonJS, GSAP, Framer Motion |
| `css-animation` | Walkthroughs HTML/CSS pour démos et onboarding |
| `cache-audit` | Audit setup Claude Code vs prompt caching |

### Externes (non versionné ici)

| Skill | Source | Màj |
|-------|--------|-----|
| `ui-ux-promax` | GitHub (nextlevelbuilder) | `git pull` dans `~/.claude/skills/ui-ux-promax/` |
| `figma-use` | Cursor cache | Automatique avec Cursor |
| `build-mcp-server`, `frontend-design`, `skill-creator` | Marketplace Claude Code | Automatique |
| `example-skills` (12 skills) | Anthropic marketplace | Automatique |
| `nano-banana` | buildatscale marketplace | Automatique |

### Ajouter un skill

```bash
cp -r ~/mon-skill ~/ai-system/skills/mon-skill
ln -sf ~/ai-system/skills/mon-skill ~/.claude/skills/mon-skill
cd ~/ai-system && git add skills/mon-skill && git commit -m "feat(skills): add mon-skill"
```

---

## Structure du repo

```
ai-system/
├── README.md                    ← ce fichier
├── STARTUP.md                   ← point d'entrée de chaque session
│
├── architecture/
│   └── context.md               ← stack complète + principes DDD + section SCRIBE/Graphify
│
├── rules/                       ← règles par stack (lues par les agents)
│   ├── expressjs.md
│   ├── flutter.md
│   ├── django.md
│   ├── nestJs.md
│   ├── frontend.md
│   ├── nextjs.md
│   ├── python-fastapi.md
│   ├── scribe-graphify.md       ← réflexes SCRIBE + Graphify
│   └── tailwind-tokens.md
│
├── workflows/                   ← procédures par situation
│   ├── new-backend-workflow.md
│   ├── new-frontend-workflow.md
│   ├── existing-backend-workflow.md
│   └── existing-frontend-workflow.md
│
├── prompts/                     ← system prompts
│   ├── system-architect.md
│   ├── system-fullstack.md
│   └── system-review.md
│
├── project-templates/           ← init automatique de projets
│   ├── project-init.sh          ← script principal
│   ├── CLAUDE.flutter.md        ← template CLAUDE.md Flutter
│   ├── express-mongodb.json
│   ├── nestjs-postgres.json
│   ├── fastapi-postgres.json
│   ├── django-postgres.json
│   ├── flutter.json
│   └── nextjs-nestjs-fastapi.json
│
└── skills/                      ← skills Claude Code (symlinked dans ~/.claude/skills/)
    ├── pixel-perfect/
    ├── animation-designer/
    ├── core-3d-animation/
    ├── css-animation/
    └── cache-audit/
```

---

## Maintenance

### Mettre à jour ai-system après modifications

```bash
cd ~/ai-system
git add -A
git commit -m "feat/fix: description"
```

### Mettre à jour SCRIBE/Graphify

```bash
cd ~/agent-scribe-graphify && git pull
```

### Mettre à jour ui-ux-promax

```bash
cd ~/.claude/skills/ui-ux-promax && git pull
```

### Initialiser un projet existant qui n'a pas encore le bundle

```bash
cd ~/mon-projet
source ~/ai-system/project-templates/project-init.sh express .
```

---

## Projets actifs

| Projet | Stack | Repo |
|--------|-------|------|
| `foryou_app` | Flutter | App passager VTC + Livraison (Bénin) |
| `foryou_driver` | Flutter | App chauffeur/livreur |
| `for-you-platform` | Express.js + MongoDB | Backend ForYou (18 modules) |
| `yo-backend` | Express.js + Sequelize + MySQL | Backend billetterie Yo |
| `yo-business` | Next.js 15 | Admin panel Yo |
| `hbpay-workspace` | Microservices | HBPay fintech |
| `flash-wallet-sdk` | SDK | Bitcoin Lightning → XOF Mobile Money |
