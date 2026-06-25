# AI System — Infrastructure Agentique

Infrastructure de développement assisté par IA basée sur Claude Code. Centralise les règles d'architecture, les agents, les workflows et les skills pour coder avec DDD + Clean Architecture sur n'importe quelle stack.

---

## Table des matières

1. [Installation](#installation)
2. [Nouveau projet backend](#nouveau-projet-backend)
3. [Nouveau projet frontend](#nouveau-projet-frontend)
4. [Nouveau projet Flutter](#nouveau-projet-flutter)
5. [Projet existant backend](#projet-existant-backend)
6. [Projet existant frontend / Flutter](#projet-existant-frontend--flutter)
7. [Workflow quotidien avec les agents](#workflow-quotidien-avec-les-agents)
8. [Worktrees — développement parallèle](#worktrees--développement-parallèle)
9. [SCRIBE + Graphify](#scribe--graphify)
10. [Skills disponibles](#skills-disponibles)
11. [Structure du repo](#structure-du-repo)
12. [Maintenance](#maintenance)

---

## Installation

### Prérequis

- [Claude Code](https://claude.ai/code) installé
- Git installé

### Cloner ce repo

```bash
git clone git@github.com:elisee-assinou/ai-system.git ~/ai-system
```

### Cloner le bundle SCRIBE + Graphify

```bash
git clone git@github.com:jackjosias/agent-scribe-graphify.git ~/agent-scribe-graphify
```

### Lier les skills Claude Code

```bash
ln -sf ~/ai-system/skills/pixel-perfect      ~/.claude/skills/pixel-perfect
ln -sf ~/ai-system/skills/animation-designer ~/.claude/skills/animation-designer
ln -sf ~/ai-system/skills/core-3d-animation  ~/.claude/skills/core-3d-animation
ln -sf ~/ai-system/skills/css-animation      ~/.claude/skills/css-animation
ln -sf ~/ai-system/skills/cache-audit        ~/.claude/skills/cache-audit
```

### Copier les agents Claude Code

```bash
cp ~/ai-system/.claude/agents/* ~/.claude/agents/
```

---

## Nouveau projet backend

### Stacks disponibles

| Commande | Stack |
|---------|-------|
| `express` | Express.js + MongoDB + Redis + BullMQ + Socket.io |
| `nestjs` | NestJS + TypeORM + PostgreSQL (CQRS) |
| `django` | Django + DRF + PostgreSQL + Celery + Redis |
| `fastapi` | FastAPI + SQLAlchemy async + Alembic + PostgreSQL |
| `fullstack` | Next.js + NestJS + FastAPI |

### Étapes

> ⚠️ Le script `project-init.sh` **n'initialise pas le projet** (pas de `mkdir`, `git init`, `npm init`).
> Il ajoute uniquement la couche agentique (CLAUDE.md, .agent/, .gitignore, opencode.json)
> sur un projet déjà existant.

```bash
# 1. Créer et initialiser le projet toi-même
mkdir mon-api && cd mon-api
git init
npm init -y   # ou: poetry init | pip install | etc.

# 2. Lancer le script — il ajoute la couche agentique sur ton projet
source ~/ai-system/project-templates/project-init.sh express mon-api "Mon API"
#                                                     ^^^^^^  ^^^^^^^^  ^^^^^^^^^
#                                                     stack   dossier   nom affiché dans CLAUDE.md

# 3. Ouvrir Claude Code
claude
```

**Ce que le script fait exactement :**
- Copie `~/agent-scribe-graphify/.agent/` → `.agent/` (SCRIBE + Graphify + TENOR)
- Lance `scribe bootstrap` (initialise la mémoire causale)
- Génère `CLAUDE.md` à la racine (stack, archi, workflow agents)
- Crée `.opencode/opencode.json` (si tu utilises opencode)
- Ajoute `.agent/ scribe-out/ graphify-out/ ai-docs/` au `.gitignore`

**Ce que le script ne fait PAS :**
- Créer le dossier
- Initialiser git
- Installer les dépendances npm/pip
- Créer la structure `src/`

### Ce que le script génère

```
mon-api/
├── CLAUDE.md               ← Instructions pour les agents (stack, archi, workflow)
├── .agent/                 ← Bundle SCRIBE + Graphify + TENOR
│   ├── skills/             ← init-tenor, graphify, fallow
│   ├── rules/              ← scribe.md + graphify.md (always-on)
│   └── workflow/scribe/    ← CLI scribe + scribe-rag
├── .opencode/
│   └── opencode.json       ← Config opencode (si tu utilises opencode)
└── .gitignore              ← Exclut .agent/, scribe-out/, graphify-out/, ai-docs/
```

### Ce que tu dis à Claude

```
"Je veux créer un module User avec inscription, connexion et profil"
```

Les agents s'enchaînent automatiquement :

```
project-manager         → crée le plan dans ai-docs/planning/active/
feature-architect-planner → liste les fichiers à créer par layer
backend-engineer        → implémente dans l'ordre :
                           domain/ → application/ → infrastructure/ → presentation/
code-quality-reviewer   → vérifie Clean Architecture, Result pattern, tests
git-workflow-specialist → commit avec message conventionnel
project-manager         → marque done, passe au module suivant
```

### Architecture générée (exemple Express.js)

```
src/
├── modules/
│   └── user/
│       ├── domain/
│       │   ├── entities/User.ts              ← Pure TypeScript, zéro framework
│       │   ├── value-objects/Email.ts        ← Auto-validant, immutable
│       │   ├── events/UserRegisteredEvent.ts ← Levé dans l'entité
│       │   └── repositories/IUserRepository.ts ← Interface (PORT)
│       ├── application/
│       │   └── use-cases/RegisterUser/
│       │       ├── RegisterUserUseCase.ts    ← Retourne Result<T,E>
│       │       └── RegisterUserDTO.ts
│       ├── infrastructure/
│       │   ├── persistence/mongodb/
│       │   │   ├── models/UserModel.ts       ← Mongoose schema
│       │   │   ├── mappers/UserMapper.ts     ← ORM ↔ Domain
│       │   │   └── repositories/UserRepository.ts ← ADAPTER
│       └── presentation/
│           └── http/
│               ├── controllers/RegisterUserController.ts ← Max 30 lignes
│               └── routes/user.routes.ts     ← Composition root (DI wiring)
└── shared/
    └── domain/value-objects/    ← PhoneNumber, Email, Money, UserId...
```

---

## Nouveau projet frontend

```bash
# 1. Créer le projet Next.js (commande officielle)
npx create-next-app@latest mon-frontend --typescript --tailwind --app
cd mon-frontend

# 2. Ajouter la couche agentique
source ~/ai-system/project-templates/project-init.sh nextjs mon-frontend "Mon Frontend"

# 3. Ouvrir Claude Code
claude
```

### Ce que tu dis à Claude

```
"Crée le module Auth avec une page login, une page inscription et la gestion du token JWT"
```

```
"Crée le Dashboard avec les stats globales et un tableau des derniers utilisateurs"
```

### Architecture générée (Next.js)

```
src/
├── app/                    ← Next.js routing ONLY (pages, layouts)
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── register/page.tsx
│   └── dashboard/page.tsx
│
├── modules/
│   └── auth/
│       ├── domain/
│       │   ├── entities/       ← Types TypeScript purs (0 React)
│       │   └── value-objects/
│       ├── application/
│       │   └── use-cases/      ← loginUser(), registerUser()
│       ├── infrastructure/
│       │   └── api/            ← Appels API (axios/fetch)
│       └── ui/
│           ├── components/     ← LoginForm, RegisterForm
│           ├── pages/          ← LoginPage, RegisterPage
│           └── hooks/          ← useLogin(), useAuth()
│
└── shared/
    ├── components/ui/          ← Button, Input, Modal...
    └── core/                   ← Event bus, config
```

---

## Nouveau projet Flutter

```bash
# 1. Créer l'app Flutter (commande officielle)
flutter create --org com.yourcompany mon_app
cd mon_app

# 2. Ajouter la couche agentique
source ~/ai-system/project-templates/project-init.sh flutter mon_app "MonApp"

# 3. Ouvrir Claude Code
claude
```

### Ce que tu dis à Claude

```
"Crée le module auth avec OTP par SMS, connexion et gestion du token JWT"
```

### Architecture générée (Flutter)

```
lib/
├── core/
│   ├── network/api_client.dart      ← Dio configuré
│   ├── di/injection_container.dart  ← GetIt registrations
│   ├── router/app_router.dart       ← GoRouter routes + guards
│   └── theme/                       ← app_colors, app_text_styles
│
├── modules/
│   └── auth/
│       ├── domain/
│       │   ├── entities/User.dart           ← Pure Dart, factory methods
│       │   ├── value_objects/PhoneNumber.dart
│       │   └── repositories/IAuthRepository.dart ← PORT
│       ├── application/
│       │   └── use_cases/login/
│       │       ├── login_use_case.dart      ← Retourne Result<T,E>
│       │       └── login_dto.dart
│       ├── data/
│       │   ├── models/auth_response_dto.dart ← freezed + json_serializable
│       │   ├── mappers/auth_mapper.dart
│       │   ├── sources/auth_remote_source.dart ← Dio
│       │   └── repositories/auth_repository.dart ← ADAPTER
│       └── presentation/
│           ├── bloc/auth_bloc.dart          ← Orchestre uniquement
│           ├── screens/login_screen.dart
│           └── widgets/
│
└── shared/
    ├── domain/value_objects/        ← PhoneNumber, Email, Money...
    └── widgets/                     ← AppButton, AppTextField, LoadingOverlay...
```

L'agent `flutter-mobile-developer` génère les couches dans l'ordre domain → application → data → presentation et enregistre tout dans GetIt + GoRouter.

---

## Projet existant backend

### Si le projet a déjà un `CLAUDE.md`

```bash
cd ~/mon-projet
claude
# Claude lit le CLAUDE.md et reprend le contexte
```

### Si le projet n'a pas de `CLAUDE.md`

```bash
cd ~/mon-projet

# Détecter la stack (package.json, requirements.txt...)
# puis initialiser
source ~/ai-system/project-templates/project-init.sh express .
# Remplacer 'express' par ta stack : nestjs | django | fastapi
```

### Analyser l'état de l'architecture

```
"Analyse la structure du projet et identifie les violations d'architecture"
```

L'agent `backend-engineer` va :
1. Lire le `CLAUDE.md` + les règles de la stack
2. Si `.agent/` présent → `graphify update .` puis `cat graphify-out/GRAPH_REPORT.md`
3. Si `.agent/` présent → `scribe-rag context` pour voir la mémoire passée
4. Identifier : business logic dans controllers ? Framework dans domain ? ORM utilisé comme entity ?
5. Proposer un plan de refactoring priorisé

### Refactorer un module existant

```
"Refactore le module Payment pour respecter Clean Architecture"
```

```
"Il y a un bug dans RegisterUser, ça fait 3 tentatives — regarde"
```
→ Après résolution, l'agent écrit un **SCAR** dans SCRIBE automatiquement

### Ajouter un use case à un projet existant

```
"Ajoute un use case BlockUser qui désactive le compte après 3 paiements échoués"
```

L'agent `backend-engineer` :
1. Consulte SCRIBE : `scribe-rag challenge "ajouter BlockUserUseCase"`
2. Consulte Graphify : `graphify query "User domain payment"` pour voir les dépendances
3. Implémente uniquement les fichiers nécessaires (pas de réécriture globale)

---

## Projet existant frontend / Flutter

### Analyser

```
"Analyse les composants — lesquels ont de la logique métier ?"
```

```
"Quels composants font plus de 150 lignes ?"
```

### Ajouter une feature

```
"Ajoute la page Settings avec les préférences notifications et la gestion du mot de passe"
```

### Refactorer

```
"Ce composant UserDashboard fait 450 lignes, réorganise-le en sous-composants"
```
→ `file-refactor-organizer` prend le relai automatiquement

### Flutter — reprendre un module

```
"Le module Ride n'a pas de Bloc — ajoute le layer presentation complet"
```

```
"Ajoute un use case GetRideHistory avec pagination"
```

---

## Workflow quotidien avec les agents

### Les commandes que tu tapes en session

| Tu dis | Ce qui se passe |
|--------|----------------|
| `"implémenter le module X"` | project-manager → architect → engineer → reviewer → git |
| `"Status"` | project-manager donne l'avancement du plan |
| `"Review"` | code-quality-reviewer valide ce qui a été fait |
| `"Module suivant"` | enchaîne automatiquement sur le module suivant |
| `"Stop"` | arrête l'enchaînement automatique |
| `"Commit"` | git-workflow-specialist commit avec message conventionnel |
| `"Documente cette lib"` | documentation-specialist recherche + écrit dans `ai-docs/` |
| `"Ce fichier fait 400 lignes"` | file-refactor-organizer le découpe |
| `"Crée une PR"` | git-workflow-specialist push + crée la PR sur GitHub |

---

### Les 9 agents et leur rôle exact

| Agent | Modèle | Ce qu'il fait |
|-------|--------|--------------|
| `project-manager` | Sonnet | Crée et suit le plan dans `ai-docs/planning/`. Marque done, enchaîne. |
| `feature-architect-planner` | Sonnet | Liste les fichiers exacts à créer par layer avant de coder |
| `backend-engineer` | Sonnet | Code tout le backend — auto-détecte Express/Django/NestJS/FastAPI |
| `frontend-ui-specialist` | Sonnet | Composants, pages, hooks, state — React/Next.js |
| `flutter-mobile-developer` | Sonnet | Modules Flutter DDD complets (domain → data → presentation) |
| `code-quality-reviewer` | Sonnet | Review architecture + lint + tests post-implémentation |
| `git-workflow-specialist` | Sonnet | Commits, branches, worktrees, PRs |
| `documentation-specialist` | **Opus** | Recherche libs (Context7 + web), docs dans `ai-docs/` |
| `file-refactor-organizer` | Sonnet | Split fichiers > 300 lignes |

---

### Le flux complet — agents + SCRIBE/Graphify

> SCRIBE et Graphify ne sont pas des agents Claude Code.
> Ce sont des **outils transversaux** que chaque agent utilise en interne à chaque étape.

```
TOI : "ajoute le module KYC"
           ↓
┌─────────────────────────────────────────────────┐
│ project-manager                                 │
│  ├── scribe-rag context     ← mémoire projet   │
│  ├── scribe-rag challenge   ← valider le plan  │
│  └── crée ai-docs/planning/active/kyc-plan.md  │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│ feature-architect-planner                       │
│  ├── graphify query "kyc"   ← carte du code    │
│  ├── scribe-rag query       ← décisions passées│
│  └── liste les fichiers à créer avec paths     │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│ backend-engineer / frontend-ui-specialist       │
│  ├── scribe-rag challenge   ← risques connus   │
│  ├── graphify explain "X"   ← dépendances      │
│  ├── [implémente le code]                       │
│  └── bug > 2 tentatives → SCAR auto            │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│ code-quality-reviewer                           │
│  ├── graphify query "blast radius"  ← impact  │
│  └── review contre ~/ai-system/rules/<stack>   │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│ git-workflow-specialist                         │
│  ├── scribe worktree   ← sépare source/généré  │
│  └── git add <fichiers-spécifiques> && commit  │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│ project-manager                                 │
│  └── "KYC done. Module suivant ?"              │
└─────────────────────────────────────────────────┘
```

**Tes agents = les mains qui codent**
**SCRIBE = la mémoire qui guide (pourquoi, douleur, décisions)**
**Graphify = les yeux qui voient le code (quoi, où, comment)**

---

### Planification automatique

```
"Je veux implémenter les modules User, Ride et Payment"
```

`project-manager` crée `ai-docs/planning/active/backend-modules-plan.md` :
```
Tâche 1 : Domain User       → backend-engineer
Tâche 2 : Application User  → backend-engineer  (dépend de 1)
Tâche 3 : Infra User        → backend-engineer  (dépend de 2)
Tâche 4 : Review User       → code-quality-reviewer  (dépend de 3)
Tâche 5 : Domain Ride       → backend-engineer  (dépend de 4)
...
```

---

## Worktrees — développement parallèle

Les worktrees permettent de travailler sur plusieurs branches en même temps dans des dossiers séparés. Il existe **3 systèmes** dans ce setup.

---

### Système 1 — Claude Code `isolation: "worktree"` ⭐ Le plus puissant

Quand le main thread lance un agent avec `isolation: "worktree"`, Claude Code crée automatiquement un worktree Git isolé pour cet agent. Idéal pour le **développement parallèle multi-agents**.

**Comment ça marche :**
```
Main thread
├── Lance Agent A avec isolation: "worktree"  →  crée branche feature/module-A
├── Lance Agent B avec isolation: "worktree"  →  crée branche feature/module-B
└── Lance Agent C avec isolation: "worktree"  →  crée branche feature/module-C

Chaque agent travaille dans son propre dossier isolé.
Aucun agent ne peut casser le travail d'un autre.

Résultat :
- Agent A termine → retourne { path: "../project-feature-module-A", branch: "feature/module-A" }
- Agent B termine → retourne { path: "../project-feature-module-B", branch: "feature/module-B" }
- Main thread demande à git-workflow-specialist de merger les 3 branches
```

**Ce que tu dis à Claude :**
```
"Implémente en parallèle les modules User, Payment et Notification —
 ils sont indépendants, lance-les simultanément"
```

Le main thread va lancer 3 agents en parallèle avec `isolation: "worktree"`, puis merger les 3 branches quand tout est terminé.

**Nettoyage automatique :**
- Agent ne fait rien → worktree supprimé automatiquement, aucune trace
- Agent fait des changements → worktree + branche préservés jusqu'au merge

**Cas d'usage :**
- Implémenter plusieurs modules backend indépendants en simultané
- Backend + Frontend en parallèle sur la même feature
- Tests d'architecture risqués sans polluer le working tree
- Expérimentation : si l'agent rate, il ne casse rien

---

### Système 2 — Git worktrees manuels

Pour les **streams long-terme** : une feature qui prend plusieurs jours pendant qu'une autre avance.

```bash
# Créer un worktree pour une feature longue
git worktree add ../mon-projet-feature-auth -b feature/auth-module

# Ouvrir Claude Code dans ce worktree
cd ../mon-projet-feature-auth && claude

# Lister les worktrees actifs
git worktree list

# Après merge, nettoyer
git worktree remove ../mon-projet-feature-auth
git branch -d feature/auth-module
```

**Exemple concret :**
```bash
# Tu travailles sur le module Ride (long)
git worktree add ../projet-ride -b feature/ride-module

# Un bug urgent arrive sur Payment
git worktree add ../projet-hotfix -b hotfix/payment-bug

# Tu corriges le bug dans un worktree, tu continues Ride dans l'autre
# Les deux branches coexistent sans se gêner
```

**Workflow type :**
```bash
# 1. Créer les worktrees
git worktree add ../projet-feature-A -b feature/module-A
git worktree add ../projet-feature-B -b feature/module-B

# 2. Ouvrir Claude Code dans chaque
cd ../projet-feature-A && claude  # Terminal 1
cd ../projet-feature-B && claude  # Terminal 2

# 3. Merger quand les deux sont prêts
cd ~/mon-projet
git merge --no-ff feature/module-A -m "feat(module-a): ..."
git merge --no-ff feature/module-B -m "feat(module-b): ..."

# 4. Nettoyer
git worktree remove ../projet-feature-A
git worktree remove ../projet-feature-B
git branch -d feature/module-A feature/module-B
```

---

### Système 3 — SCRIBE worktree (classification des changements)

SCRIBE classe les fichiers Git modifiés pour séparer le code source des artefacts agentiques avant un commit.

```bash
.agent/workflow/scribe/scribe worktree --surface auth --agent "<ID>" --limit 80
```

**4 catégories :**
| Catégorie | Exemples | Action |
|-----------|---------|--------|
| `tracked_changes` | `src/auth/login.ts` modifié | ✅ À committer |
| `untracked_source` | nouveaux `.ts`, `.dart`, `.py` | ✅ À committer (git add) |
| `generated_noise` | `scribe-out/`, `graphify-out/`, `__pycache__/` | ❌ Ne jamais committer |
| `other_untracked` | fichiers divers | À examiner |

Cela évite d'accidentellement committer les fichiers SCRIBE/Graphify avec le code.

---

### Quand utiliser quel système

| Situation | Système |
|-----------|---------|
| 2+ modules indépendants à implémenter | **isolation: "worktree"** (automatique) |
| Feature risquée / expérimentation | **isolation: "worktree"** (auto-nettoyé si ça rate) |
| Feature longue (jours) en parallèle | **Git worktree manuel** |
| Hotfix urgent pendant feature en cours | **Git worktree manuel** |
| Vérifier ce qui mérite un commit | **SCRIBE worktree** |
| Feature simple séquentielle | Aucun worktree (pas nécessaire) |

---

## SCRIBE + Graphify

Le bundle `.agent/` est copié dans chaque projet par `project-init.sh`. Il contient deux CLIs :
- **`scribe`** — CLI maintenance (bootstrap, doctor, lock, whoami, dashboard...)
- **`scribe-rag`** — CLI agent (context, challenge, preflight, query, build, gate...)

| Outil | Rôle |
|-------|------|
| **TENOR** | Init de session — preuve machine que les règles ont été lues |
| **SCRIBE** | Mémoire causale — bugs résolus, décisions archi, patterns à éviter |
| **Graphify** | Carte AST temps réel — ~700 tokens au lieu de ~50 000 pour comprendre le code |
| **Fallow** | Dead code, duplication, complexité JS/TS |

---

### Étape 1 — Démarrer une session (TENOR init)

```bash
# Type selon ton outil : extension | cli | api | unknown
.agent/workflow/scribe/scribe tenor-init --type extension

# Produit un bloc SCRIBE-CHECK TENOR V4 :
# ✅ Workflow ACK, identité agent, mémoire chargée, lock status, claims actifs
```

Si `tenor-init` échoue → afficher l'erreur réelle, ne pas continuer.

---

### Étape 2 — Choisir le mode de friction

Le **mode** détermine combien de vérifications faire avant de coder.

| Mode | Quand | Commande |
|------|-------|---------|
| **NANO** | Correction < 30 min, 1 fichier, pas de surface partagée | `scribe-rag context` seulement |
| **QUICK** | Feature simple, 1-2h, surface connue | `scribe-rag preflight --tier QUICK "<plan>"` |
| **STANDARD** | Feature normale, multi-fichiers, refactoring | `scribe-rag preflight --tier STANDARD "<plan>"` |
| **CRITICAL** | Auth, data, API publique, migrations, multi-agent | `scribe-rag preflight --tier CRITICAL --strict "<plan>"` |

```bash
# Exemples
.agent/workflow/scribe/scribe-rag context                              # NANO
.agent/workflow/scribe/scribe-rag preflight --tier STANDARD "ajouter module Payment"
.agent/workflow/scribe/scribe-rag preflight --tier CRITICAL --strict "migrer la table users"
```

---

### Étape 3 — Charger la mémoire et valider le plan

```bash
# Charger le contexte mémoire (toujours)
.agent/workflow/scribe/scribe-rag context
# → hot entries (SCARs, VACs, GHOSTs chauds), dettes actives, dernier JOURNAL

# Valider le plan contre la mémoire
.agent/workflow/scribe/scribe-rag challenge "je vais implémenter X"
# → PROCEED : aucun risque connu → go
# → REVIEW   : warnings à lire → décider avec l'utilisateur
# → STOP     : approche dans ne_pas_reproposer ou SCAR bloquant → ne pas faire

# Rebuild l'index si la mémoire est ancienne
.agent/workflow/scribe/scribe-rag build
.agent/workflow/scribe/scribe-rag build --with-embeddings  # mode hybride (plus précis, plus lent)
```

---

### Étape 4 — Naviguer dans le code avec Graphify

```bash
# Vue d'ensemble de l'architecture (~500 tokens)
cat graphify-out/GRAPH_REPORT.md
# → God-nodes, blast radius, communautés, connexions surprenantes

# Chercher par concept
graphify query "payment processing"        # BFS — contexte large
graphify query "auth token" --dfs          # DFS — suivre un chemin précis

# Chemin entre deux composants
graphify path "PaymentController" "WalletRepository"

# Comprendre un nœud spécifique
graphify explain "AuthBloc"

# Mettre à jour le graphe après modifications
graphify update .

# Watcher temps réel (rebuild < 3s après chaque save)
graphify watch .
```

**Règle d'or :** si `graphify-out/GRAPH_REPORT.md` existe → le lire **avant** de lire des fichiers sources.

---

### Étape 5 — Implémenter

Pendant l'implémentation, les agents suivent les règles de `~/ai-system/rules/<stack>.md`.

Si plan change en cours de route :
```bash
.agent/workflow/scribe/scribe-rag challenge "<plan révisé>"
# Relancer le challenge à chaque changement significatif
```

---

### Étape 6 — Après un bug résolu (> 2 tentatives)

Écrire un **SCAR** immédiat :

```bash
# L'agent l'écrit automatiquement, mais tu peux le déclencher manuellement
```

```yaml
type: SCAR
id: SCAR-XXX
cause_racine: "Le mapper n'initialisait pas le champ currency"
resolution: "Ajouter currency dans MoneyMapper.toPersistence() avec valeur par défaut 'XOF'"
test_binding: "test: MoneyMapper.toPersistence doit inclure currency"
```

La prochaine fois, `scribe-rag challenge` le rappelle automatiquement.

---

### Étape 7 — Fermeture de session

```bash
# Suggestions automatiques de ce qui mérite d'être documenté
.agent/workflow/scribe/scribe-rag autodream --read-only
```

> "Qu'est-ce qui fera souffrir le prochain LLM si je ne le documente pas ?"

| Ce qui s'est passé | Ce qu'on écrit |
|--------------------|----------------|
| Bug résolu en > 2 tentatives | **SCAR** (cicatrice) |
| Décision architecturale prise | **GHOST** (fantôme — alternative rejetée + raison) |
| Règle préventive identifiée | **VAC** (vaccin) |
| Pattern réutilisable découvert | **PAT** (pattern) |
| Session normale sans problème | **JOURNAL** seulement |

---

### Les 5 types d'entrées SCRIBE

| Type | ID | Quand écrire | Contenu |
|------|-----|-------------|---------|
| **SCAR** | `SCAR-XXX` | Bug résolu > 2 tentatives, régression, rollback | `cause_racine` + `resolution` + `test_binding` |
| **GHOST** | `GHOST-XXX` | Décision archi — pourquoi on n'a PAS fait X | Alternative rejetée + raison |
| **VAC** | `VAC-XXX` | Règle préventive causale (née d'un SCAR) | Règle + scope + evidence |
| **PAT** | `PAT-XXX` | Pattern validé et réutilisable | Solution + contexte d'application |
| **JOURNAL** | `JOURNAL-XXX` | Chaque session de travail | Ce qui a été fait, décisions mineures |

**Ne jamais écrire** SCAR/GHOST/PAT/VAC pour gonfler les statistiques — seulement si ça évite une vraie souffrance au prochain LLM.

---

### Commandes de diagnostic

```bash
# Santé du bundle SCRIBE
.agent/workflow/scribe/scribe doctor --suggest-fix

# Dashboard HTML (statistiques, hot entries, timeline)
.agent/workflow/scribe/scribe dashboard
.agent/workflow/scribe/scribe dashboard --serve --host 127.0.0.1 --port 8765

# Qualité de l'index RAG (doit être 8/8)
.agent/workflow/scribe/scribe-rag gate

# Identité de l'agent courant
.agent/workflow/scribe/scribe whoami --type cli --surface idle

# Requête libre sur la mémoire
.agent/workflow/scribe/scribe-rag query "authentification bug"
.agent/workflow/scribe/scribe-rag explain "SCAR-001"
```

---

### Mode multi-agents (plusieurs Claude simultanés)

Quand plusieurs agents travaillent sur le même projet en parallèle, SCRIBE gère les conflits d'écriture.

```bash
# Chaque agent s'identifie
.agent/workflow/scribe/scribe whoami --type cli --surface auth

# Vérifier qui travaille sur quoi
.agent/workflow/scribe/scribe coordination status

# Réclamer une zone avant d'implémenter
.agent/workflow/scribe/scribe coordination claim \
  --agent "<ID>" --claim "auth:login" \
  --task "refacto login" --expected-file "src/auth/login.ts"

# Acquérir le lock avant d'écrire dans SCRIBE
.agent/workflow/scribe/scribe lock acquire --agent "<ID>" --type cli --session <JOURNAL-ID>

# Libérer après écriture
.agent/workflow/scribe/scribe lock release --agent "<ID>"
```

**Mécanismes de protection :**
- `lock acquire` — atomique, refuse si un autre agent écrit
- `coordination claim` — réserve sémantiquement une zone de code
- `sync` — vérifie que l'état SCRIBE est à jour avant d'écrire
- `worktree` — classe les fichiers modifiés (source vs généré vs agentique)

---

### Mettre à jour le bundle

```bash
cd ~/agent-scribe-graphify && git pull

# Re-copier dans un projet existant si besoin
cp -r ~/agent-scribe-graphify/.agent ~/mon-projet/.agent
```

---

## Repos

| Repo | URL | Description |
|------|-----|-------------|
| **ai-system** | https://github.com/elisee-assinou/ai-system | Ce repo — règles, agents, workflows, skills |
| **agent-scribe-graphify** | https://github.com/jackjosias/agent-scribe-graphify | Bundle SCRIBE + Graphify + TENOR |

---

## Skills disponibles

### Skills dans ce repo (versionné + symlinké dans `~/.claude/skills/`)

| Skill | Déclencheur | Usage |
|-------|------------|-------|
| `pixel-perfect` | `/pixel-perfect` | Figma/screenshot → code frontend exact |
| `animation-designer` | "animation", "framer motion" | Animations Framer Motion + CSS |
| `core-3d-animation` | "3D", "three.js", "GSAP", "R3F" | Three.js, React Three Fiber, BabylonJS, GSAP |
| `css-animation` | "css animation", "walkthrough demo" | Walkthroughs HTML/CSS pour démos et onboarding |
| `cache-audit` | `/cache-audit` | Audit du setup Claude Code vs prompt caching |

### Skills externes (gérés automatiquement)

| Skill | Source | Mise à jour |
|-------|--------|------------|
| `ui-ux-promax` | GitHub (nextlevelbuilder) | `git pull` dans `~/.claude/skills/ui-ux-promax/` |
| `figma-use` | Cursor cache | Automatique avec Cursor |
| `build-mcp-server`, `build-mcpb`, `build-mcp-app` | Marketplace Claude Code | Automatique |
| `frontend-design` | Marketplace Claude Code | Automatique |
| `skill-creator` | Marketplace Claude Code | Automatique |
| 12 example-skills (canvas, branding, doc, art...) | Anthropic marketplace | Automatique |
| `nano-banana` (génération images Gemini) | buildatscale marketplace | Automatique |

### Ajouter un nouveau skill

```bash
# 1. Copier dans ai-system (source de vérité, versionné Git)
cp -r ~/mon-skill ~/ai-system/skills/mon-skill

# 2. Créer le symlink global (disponible dans tous les projets)
ln -sf ~/ai-system/skills/mon-skill ~/.claude/skills/mon-skill

# 3. Committer dans ai-system
cd ~/ai-system
git add skills/mon-skill
git commit -m "feat(skills): add mon-skill"
```

---

## Structure du repo

```
ai-system/
│
├── README.md                          ← ce fichier
├── STARTUP.md                         ← point d'entrée de chaque session Claude
│
├── architecture/
│   └── context.md                     ← toutes les stacks + principes DDD + SCRIBE/Graphify
│
├── rules/                             ← règles par stack (lues automatiquement par les agents)
│   ├── expressjs.md                      ~850 lignes — Express + Mongoose + DDD complet
│   ├── flutter.md                        ~950 lignes — Flutter + Bloc + DDD complet
│   ├── django.md                         ~600 lignes — Django + DRF + Clean Arch
│   ├── nestJs.md                         ~310 lignes — NestJS + TypeORM + CQRS
│   ├── frontend.md                       ~290 lignes — Frontend DDD + Hexagonal
│   ├── nextjs.md                         ~250 lignes — Next.js App Router spécifique
│   ├── python-fastapi.md                 ~290 lignes — FastAPI + SQLAlchemy async
│   ├── scribe-graphify.md                 ~85 lignes — Réflexes SCRIBE + Graphify
│   └── tailwind-tokens.md                 ~70 lignes — Design tokens CSS → Tailwind
│
├── workflows/                         ← procédures détaillées par situation
│   ├── new-backend-workflow.md           Phases 0→4 pour un nouveau backend
│   ├── new-frontend-workflow.md          Phases 0→4 pour un nouveau frontend
│   ├── existing-backend-workflow.md      Analyse + refactoring backend existant
│   └── existing-frontend-workflow.md     Analyse + refactoring frontend existant
│
├── prompts/                           ← system prompts pour rôles spécifiques
│   ├── system-architect.md               Rôle architecte logiciel
│   ├── system-fullstack.md               Rôle développeur fullstack
│   ├── system-review.md                  Rôle code reviewer
│   └── project-specific/                 Prompts propres à ton projet (non partagés)
│
├── project-templates/                 ← initialisation automatique de nouveaux projets
│   ├── project-init.sh                   Script principal (copie .agent/, génère CLAUDE.md)
│   ├── CLAUDE.flutter.md                 Template CLAUDE.md pour projets Flutter
│   ├── express-mongodb.json              Config opencode Express
│   ├── nestjs-postgres.json              Config opencode NestJS
│   ├── fastapi-postgres.json             Config opencode FastAPI
│   ├── django-postgres.json              Config opencode Django
│   ├── flutter.json                      Config opencode Flutter
│   └── nextjs-nestjs-fastapi.json        Config opencode Fullstack
│
└── skills/                            ← Skills Claude Code (symlinkés dans ~/.claude/skills/)
    ├── pixel-perfect/                    Figma → code pixel-perfect
    ├── animation-designer/               Framer Motion + CSS animations
    ├── core-3d-animation/                Three.js, R3F, BabylonJS, GSAP
    ├── css-animation/                    Walkthroughs HTML/CSS
    └── cache-audit/                      Audit prompt caching
```

---

## Maintenance

### Modifier les règles d'architecture

```bash
# Éditer la règle concernée
code ~/ai-system/rules/expressjs.md

# Committer
cd ~/ai-system
git add rules/expressjs.md
git commit -m "fix(rules): clarify mapper pattern for MongoDB"
```

Les agents liront la version mise à jour à la prochaine session.

### Modifier les agents Claude Code

Les agents sont dans `~/.claude/agents/` — ils ne sont pas versionnés dans ce repo (personnels).

```bash
code ~/.claude/agents/backend-engineer.md
```

### Mettre à jour SCRIBE/Graphify

```bash
cd ~/agent-scribe-graphify && git pull

# Pour mettre à jour un projet existant avec la nouvelle version :
cp -r ~/agent-scribe-graphify/.agent ~/mon-projet/.agent
```

### Mettre à jour ui-ux-promax

```bash
cd ~/.claude/skills/ui-ux-promax && git pull
```

### Initialiser le bundle sur un projet existant (sans `project-init.sh`)

```bash
cd ~/mon-projet

# Copier le bundle
cp -r ~/agent-scribe-graphify/.agent .

# Bootstrapper SCRIBE
.agent/workflow/scribe/scribe bootstrap

# Ajouter au .gitignore
echo ".agent/
scribe-out/
graphify-out/
ai-docs/" >> .gitignore
```

### Créer un `CLAUDE.md` minimal pour un projet sans template

```markdown
# Mon Projet

## Stack
- Express.js + MongoDB
- Architecture: DDD + Event-driven

## Architecture — OBLIGATOIRE
Lire et appliquer strictement avant de générer du code :
- ~/ai-system/architecture/context.md
- ~/ai-system/rules/expressjs.md
- ~/ai-system/rules/scribe-graphify.md (si .agent/ présent)

## SCRIBE + Graphify
Si `.agent/` présent dans ce projet :
- Démarrer : `.agent/workflow/scribe/scribe tenor-init --type extension`
- Avant impl : `scribe-rag context` + `scribe-rag challenge "<plan>"`
- Navigation code : `cat graphify-out/GRAPH_REPORT.md` + `graphify query "..."`

## Workflow sous-agents
1. project-manager → plan
2. feature-architect-planner → plan technique
3. backend-engineer → implémentation (domain → application → infrastructure → presentation)
4. code-quality-reviewer → review
5. git-workflow-specialist → commit
```

---

*Elisee ASSINOU*
