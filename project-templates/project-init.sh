#!/usr/bin/env bash
# Usage: source project-init.sh <stack> [project-dir] [project-name]
# Stacks: express, nestjs, fastapi, django, fullstack, nextjs, flutter
#
# Ce script fait TOUT en une commande :
# 1. Copie le bundle .agent/ (SCRIBE + Graphify + TENOR)
# 2. Ajoute .agent/ scribe-out/ graphify-out/ ai-docs/ au .gitignore
# 3. Lance le bootstrap SCRIBE
# 4. Configure opencode.json
# 5. Genere le CLAUDE.md avec les bonnes regles d'archi selon le stack

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

  cat > "$DIR/CLAUDE.md" << CLAUDEMD
# $NAME

## Stack
- $STACK
- Architecture: $ARCH_LABEL

## Architecture — OBLIGATOIRE

Lis et applique strictement ces fichiers de regles avant de generer du code :
- $ARCH/context.md (principes generaux)
- $ARCH_RULES ($ARCH_LABEL)
$EXTRA_LINE

## Workflow obligatoire — sous-agents

Tu DOIS utiliser les sous-agents pour chaque tache. Ne jamais coder directement sans passer par eux.

### Ordre d'execution pour chaque module/feature :
1. **project-manager** — cree le plan, decoupe en taches, suit l'avancement
2. **feature-architect-planner** — planifie l'implementation technique
3. **frontend-ui-specialist** ou **backend-engineer** — implemente le code
4. **code-quality-reviewer** — review apres implementation
5. **project-manager** — marque done, passe au module suivant

### Regles des sous-agents :
- Toujours planifier avant de coder
- Toujours reviewer apres avoir code
- Tous les sous-agents doivent lire et respecter les regles d'architecture dans ~/ai-system/rules/
- Si .agent/ existe : lire ~/ai-system/rules/scribe-graphify.md et appliquer les reflexes
- Consulte le SCRIBE avant chaque implementation (scribe-rag context + challenge)
- Consulte Graphify avant de modifier du code (graphify query)
- Si un bug prend > 2 tentatives : ecris une SCAR dans le SCRIBE

### Comportement attendu :
- Apres chaque tache : met a jour le plan, marque done, dis ce qui reste
- Enchaine automatiquement sur la tache suivante sauf si l'utilisateur dit "stop"

### Commandes utilisateur :
- "Module suivant" → enchaine
- "Stop" → arrete
- "Status" → project-manager donne l'avancement
- "Review" → code-quality-reviewer valide
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
