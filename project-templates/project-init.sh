#!/usr/bin/env bash
# Usage: source project-init.sh <stack> [project-dir] [project-name]
# Stacks: express, nestjs, fastapi, django, fullstack, nextjs, flutter
#
# PRE-REQUIS : le projet doit deja exister (git init + npm init / poetry init / flutter create...)
# Ce script ajoute uniquement la couche agentique sur un projet existant :
# 1. Copie le bundle .agent/ (SCRIBE + Graphify + TENOR)
# 2. Ajoute .agent/ scribe-out/ graphify-out/ ai-docs/ au .gitignore
# 3. Lance le bootstrap SCRIBE
# 4. Configure opencode.json (pour opencode)
# 5. Genere le CLAUDE.md avec les regles d'archi selon le stack

set -e

STACK="${1:-fullstack}"
DIR="${2:-.}"
NAME="${3:-app}"
TEMPLATES="$HOME/ai-system/project-templates"
RULES="$HOME/ai-system/rules"
ARCH="$HOME/ai-system/architecture"
BUNDLE="$HOME/agent-scribe-graphify/.agent"

# ── Validation du stack ──────────────────────────────────────────────
case "$STACK" in
  express|express-mongo)
    OPENCODE="$TEMPLATES/express-mongodb.json"
    ARCH_RULES="$RULES/expressjs.md"
    ARCH_LABEL="DDD + Event-driven" ;;
  nestjs|nest)
    OPENCODE="$TEMPLATES/nestjs-postgres.json"
    ARCH_RULES="$RULES/nestJs.md"
    ARCH_LABEL="Clean Architecture + CQRS" ;;
  fastapi|python)
    OPENCODE="$TEMPLATES/fastapi-postgres.json"
    ARCH_RULES="$RULES/python-fastapi.md"
    ARCH_LABEL="Clean Architecture" ;;
  django)
    OPENCODE="$TEMPLATES/django-postgres.json"
    ARCH_RULES="$RULES/django.md"
    ARCH_LABEL="Clean Architecture + DDD" ;;
  fullstack|nextjs)
    OPENCODE="$TEMPLATES/nextjs-nestjs-fastapi.json"
    ARCH_RULES="$RULES/frontend.md"
    ARCH_LABEL="DDD + Hexagonal + Event-driven"
    EXTRA_RULES="$RULES/nextjs.md" ;;
  flutter)
    OPENCODE="$TEMPLATES/flutter.json"
    ARCH_RULES="$RULES/flutter.md"
    ARCH_LABEL="DDD + Clean Architecture"
    CLAUDE_TEMPLATE="$TEMPLATES/CLAUDE.flutter.md" ;;
  *)
    echo "❌ Stack inconnu: $STACK"
    echo "Stacks: express, nestjs, fastapi, django, fullstack, nextjs, flutter"
    return 1 ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 PROJECT INIT — $NAME ($STACK)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── 1. Bundle .agent/ ────────────────────────────────────────────────
if [ -d "$DIR/.agent" ]; then
  echo "⚠️  .agent/ existe deja, ignore"
else
  if [ -d "$BUNDLE" ]; then
    cp -r "$BUNDLE" "$DIR/.agent"
    echo "✅ Bundle .agent/ copie"
  else
    echo "⚠️  Bundle introuvable: $BUNDLE — skip"
  fi
fi

# ── 2. .gitignore ───────────────────────────────────────────────────
if [ -f "$DIR/.gitignore" ]; then
  ENTRIES=(".agent/" "scribe-out/" "graphify-out/" "ai-docs/")
  ADDED=0
  for entry in "${ENTRIES[@]}"; do
    if ! grep -qF "$entry" "$DIR/.gitignore" 2>/dev/null; then
      echo "$entry" >> "$DIR/.gitignore"
      ADDED=1
    fi
  done
  if [ "$ADDED" -eq 1 ]; then
    echo "✅ .gitignore mis a jour (.agent/, scribe-out/, graphify-out/, ai-docs/)"
  else
    echo "⚠️  .gitignore deja a jour"
  fi
else
  cat > "$DIR/.gitignore" << 'GITIGNORE'
# Agent bundle & generated data
.agent/
scribe-out/
graphify-out/
ai-docs/
GITIGNORE
  echo "✅ .gitignore cree"
fi

# ── 3. Bootstrap SCRIBE ─────────────────────────────────────────────
if [ -f "$DIR/.agent/workflow/scribe/scribe" ]; then
  "$DIR/.agent/workflow/scribe/scribe" bootstrap 2>/dev/null || true
  echo "✅ SCRIBE bootstrap done"
else
  echo "⚠️  SCRIBE bootstrap skip (bundle absent)"
fi

# ── 4. OpenCode config ──────────────────────────────────────────────
mkdir -p "$DIR/.opencode"
cp "$OPENCODE" "$DIR/.opencode/opencode.json"
echo "✅ opencode.json cree ($STACK)"

# ── 5. CLAUDE.md ────────────────────────────────────────────────────
if [ "$STACK" = "flutter" ]; then
  if [ ! -f "$DIR/CLAUDE.md" ]; then
    sed "s/{{PROJECT_NAME}}/$NAME/g; s/{{APP_NAME}}/$NAME/g; s/{{SHORT_DESCRIPTION}}/Application Flutter/g; s/{{FLUTTER_VERSION}}/3.35+/g; s/{{DART_VERSION}}/3.9+/g; s/{{API_BASE_URL}}/https:\/\/api.example.com/g" "$CLAUDE_TEMPLATE" > "$DIR/CLAUDE.md"
    echo "✅ CLAUDE.md cree (template Flutter)"
  else
    echo "⚠️  CLAUDE.md existe deja, ignore"
  fi
elif [ ! -f "$DIR/CLAUDE.md" ]; then
  EXTRA_LINE=""
  if [ -n "$EXTRA_RULES" ]; then
    EXTRA_LINE="- $EXTRA_RULES"
  fi

  # Determine agent selon le type de stack
  case "$STACK" in
    express|express-mongo|nestjs|nest|fastapi|python|django)
      IMPL_AGENT="backend-engineer" ;;
    fullstack|nextjs)
      IMPL_AGENT="frontend-ui-specialist" ;;
    *)
      IMPL_AGENT="backend-engineer" ;;
  esac

  # Determine sections specifiques par type de stack
  case "$STACK" in
    express|express-mongo|nestjs|nest|fastapi|python|django)
      STACK_SECTION="## API

- **Base URL** : \`http://localhost:PORT\`  ← A personnaliser
- **Auth** : JWT Bearer token
- **Format reponse** : \`{ success: boolean, data: any, message: string }\`  ← A adapter
- **Pagination** : \`{ data: [], total: number, page: number, limit: number }\`  ← A adapter

## Base de donnees

- **Type** : TODO (MongoDB / PostgreSQL / MySQL)
- **ORM** : TODO (Mongoose / TypeORM / Prisma / SQLAlchemy)
- **Collections/Tables principales** :
  - TODO : decrire tes tables/collections ici

## Variables d'environnement

\`\`\`env
PORT=3000
NODE_ENV=development
DATABASE_URL=TODO
JWT_SECRET=TODO
# Ajouter les autres variables necessaires
\`\`\`" ;;
    fullstack|nextjs)
      STACK_SECTION="## Backend

- **Repo** : \`../mon-backend\`  ← Chemin vers le backend
- **Base URL** : variable d'env \`NEXT_PUBLIC_API_URL\`
- **Auth** : TODO (JWT / Session / OAuth)
- **Format reponse** : \`{ success: boolean, data: any, message: string }\`  ← A adapter
- **Pagination** : \`{ data: [], total: number, page: number, limit: number }\`  ← A adapter

## Design

- **Style** : TODO (minimaliste / glassmorphic / material / etc.)
- **Palette** :
  - Primary : \`#TODO\`
  - Background : \`#TODO\`
  - Text : \`#TODO\`
  - Error : \`#TODO\`
  - Success : \`#TODO\`
- **Fonts** : TODO (Inter / Poppins / etc.)

## Variables d'environnement

\`\`\`env
NEXT_PUBLIC_API_URL=http://localhost:3000
# Ajouter les autres variables necessaires
\`\`\`" ;;
  esac

  cat > "$DIR/CLAUDE.md" << CLAUDEMD
# $NAME

## Description

TODO : Decris ici ce que fait le projet, pour qui, et son contexte metier.

## Stack

- **Framework** : $STACK
- **Architecture** : $ARCH_LABEL
- **Langage** : TypeScript strict / Python 3.12+  ← A adapter
- **Version** : TODO

$STACK_SECTION

## Modules (bounded contexts)

TODO : Liste ici tous les modules/features du projet avec leur statut.

| Module | Description | Statut |
|--------|-------------|--------|
| auth | Authentification, JWT, OTP | 🔲 A faire |
| user | Profil, gestion compte | 🔲 A faire |
| TODO | TODO | 🔲 A faire |

## Commandes

\`\`\`bash
npm run dev        # Demarrer en developpement
npm run build      # Build production
npm run test       # Lancer les tests
npm run lint       # Linter
npm run typecheck  # Verification TypeScript
\`\`\`

## Architecture — OBLIGATOIRE

Lis et applique strictement ces fichiers de regles avant de generer du code :
- $ARCH/context.md (principes generaux)
- $ARCH_RULES ($ARCH_LABEL)
$EXTRA_LINE
- ~/ai-system/rules/scribe-graphify.md (si .agent/ present)

## SCRIBE + Graphify

Initialisation obligatoire au debut de CHAQUE session :
\`\`\`bash
.agent/workflow/scribe/scribe tenor-init --type extension
\`\`\`

Avant chaque implementation :
\`\`\`bash
.agent/workflow/scribe/scribe-rag context
.agent/workflow/scribe/scribe-rag challenge "<ce que tu vas faire>"
\`\`\`
- STOP → ne pas implementer, comprendre le blocage
- REVIEW → lire les warnings, decider avec l'utilisateur
- PROCEED → go

Avant de lire des fichiers pour comprendre le code :
\`\`\`bash
cat graphify-out/GRAPH_REPORT.md
graphify query "<ta question>"
\`\`\`

Apres un bug resolu en > 2 tentatives → SCAR immediat.
Fin de session → "Qu'est-ce qui fera souffrir le prochain LLM ?"

## Workflow obligatoire — sous-agents

Ne jamais coder directement. Toujours passer par les agents.

### Ordre pour chaque module/feature :
1. **project-manager** — cree le plan, decoupe en taches
2. **feature-architect-planner** — planifie les fichiers a creer
3. **$IMPL_AGENT** — implemente (domain → application → infrastructure → presentation)
4. **code-quality-reviewer** — review apres implementation
5. **git-workflow-specialist** — commit avec message conventionnel
6. **project-manager** — marque done, passe au suivant

### Regles absolues :
- Graphify avant grep/lecture de fichiers
- SCRIBE avant implementation
- Jamais git add . → toujours git add <fichiers-specifiques>
- Jamais committer .agent/ scribe-out/ graphify-out/

### Commandes utilisateur :
- "Module suivant" → enchaine automatiquement
- "Stop" → arrete
- "Status" → project-manager donne l'avancement
- "Review" → code-quality-reviewer valide

## Notes specifiques

TODO : Ajoute ici tout ce que les agents doivent savoir sur ce projet
qui n'est pas derive du code (decisions, contraintes, regles metier, etc.)
CLAUDEMD
  echo "✅ CLAUDE.md genere ($ARCH_LABEL)"
else
  echo "⚠️  CLAUDE.md existe deja, ignore"
fi

# ── Resume ───────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ PROJET PRET"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Bundle:     .agent/ $([ -d "$DIR/.agent" ] && echo '✅' || echo '❌')"
echo "  SCRIBE:     scribe-out/ $([ -d "$DIR/scribe-out" ] && echo '✅' || echo '❌')"
echo "  OpenCode:   .opencode/opencode.json ✅"
echo "  CLAUDE.md:  $([ -f "$DIR/CLAUDE.md" ] && echo '✅' || echo '❌')"
echo "  .gitignore: ✅"
echo ""
echo "Prochaine etape :"
echo "  cd $DIR"
echo "  claude"
echo "  → [TENOR INIT::[.agent/skills/init-tenor/SKILL.md]]"
echo ""
