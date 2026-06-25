# AI System — Startup Context

Charge ce fichier EN PREMIER au début de chaque session.

## Architecture globale

- **Stack complète** : `~/ai-system/architecture/context.md`
- **Backend for-you-platform** : `/Users/eliseeassinou/for-you-platform/src/modules/`

## Règles par stack

| Stack | Fichier |
|-------|---------|
| Flutter | `~/ai-system/rules/flutter.md` |
| Express.js | `~/ai-system/rules/expressjs.md` |
| Django | `~/ai-system/rules/django.md` |
| FastAPI | `~/ai-system/rules/python-fastapi.md` |
| NestJS | `~/ai-system/rules/nestJs.md` |
| Frontend (Next.js) | `~/ai-system/rules/frontend.md` |

## Workflows

| Situation | Workflow |
|-----------|----------|
| Nouveau projet frontend | `~/ai-system/workflows/new-frontend-workflow.md` |
| Nouveau projet backend | `~/ai-system/workflows/new-backend-workflow.md` |
| Reprise projet frontend | `~/ai-system/workflows/existing-frontend-workflow.md` |
| Reprise projet backend | `~/ai-system/workflows/existing-backend-workflow.md` |

## Prompts système

| Rôle | Fichier |
|------|---------|
| Architecte logiciel | `~/ai-system/prompts/system-architect.md` |
| Fullstack developer | `~/ai-system/prompts/system-fullstack.md` |
| Code reviewer | `~/ai-system/prompts/system-review.md` |

## Skills

| Skill | Fichier |
|-------|---------|
| Pixel Perfect (UI) | `~/ai-system/skills/pixel-perfect` |

## Claude Code agents

- **Config** : `~/.claude/settings.json`
- **Agents disponibles** : `~/.claude/agents/` (11 agents)
- **Docs multi-agent** : `~/.claude/ai-docs/multi-agent-system-overview.md`
- **Hooks** : `~/.claude/hooks/` (4 hooks Python)

## SCRIBE + Graphify (infrastructure agentique)

- **Bundle source** : `~/agent-scribe-graphify/.agent/` (upstream Git — `git pull` pour les mises à jour)
- **Réflexes agent** : `~/ai-system/rules/scribe-graphify.md`
- **Installation** : `project-init.sh` copie `.agent/` dans chaque projet automatiquement
- **SCRIBE** : mémoire causale (pourquoi, douleur, décision, cicatrice)
- **Graphify** : graphe structurel AST (navigation code en ~700 tokens vs ~50k)
- **TENOR** : protocole de fiabilité (preuves machine, init obligatoire)

## Projets actifs

- `~/foryou_app/` — App Flutter passager (VTC + Livraison B2C, Bénin)
- `~/for-you-platform/` — Backend Express.js (à vérifier si pertinent)
- `~/miconnect-frontend/` — Frontend Next.js (à vérifier si pertinent)

## Ordre de chargement

1. `~/ai-system/STARTUP.md` (ce fichier)
2. `~/ai-system/architecture/context.md` (vue globale)
3. Règle de la stack concernée dans `~/ai-system/rules/`
4. `~/ai-system/rules/scribe-graphify.md` (si `.agent/` existe dans le projet)
5. Workflow correspondant dans `~/ai-system/workflows/`
6. Prompt système pertinent dans `~/ai-system/prompts/`
7. Skill pertinent dans `~/ai-system/skills/`
8. `CLAUDE.md` du projet (racine du projet)
