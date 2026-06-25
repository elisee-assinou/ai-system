# AI System — Infrastructure Agentique

## Description

Ce repo EST le cerveau de tous les projets. Il contient les règles d'architecture,
les agents Claude Code, les workflows, les skills et les templates.

Ce n'est pas une application — c'est un système de configuration et de connaissances
qui s'applique à tous les projets via des symlinks et des références.

## Stack

- **Langage** : Markdown + Bash
- **Pas de framework applicatif** — ce repo ne tourne pas, il est lu
- **Git** : source de vérité, poussé sur GitHub

## Repos liés

- **Ce repo** : https://github.com/elisee-assinou/ai-system
- **Bundle SCRIBE + Graphify** : https://github.com/jackjosias/agent-scribe-graphify
- **Agents Claude Code** : `~/.claude/agents/` (non versionné ici — personnel)

## Structure du repo

```
rules/              → règles d'architecture par stack (les plus importants)
workflows/          → procédures par situation
prompts/            → system prompts pour rôles spécifiques
project-templates/  → project-init.sh + CLAUDE.md templates
skills/             → skills Claude Code (symlinked dans ~/.claude/skills/)
architecture/       → context.md (vue globale de toutes les stacks)
```

## Règles pour modifier ce repo

### Ajouter une règle de stack
1. Créer `rules/<stack>.md` en suivant la structure des fichiers existants
2. Ajouter l'entrée dans `architecture/context.md`
3. Ajouter le case dans `project-templates/project-init.sh`
4. Créer le template JSON dans `project-templates/`
5. Mettre à jour `STARTUP.md` et `README.md`

### Ajouter un skill
```bash
cp -r ~/mon-skill ~/ai-system/skills/mon-skill
ln -sf ~/ai-system/skills/mon-skill ~/.claude/skills/mon-skill
git add skills/mon-skill && git commit -m "feat(skills): add mon-skill" && git push
```

### Modifier un agent Claude Code
Les agents sont dans `~/.claude/agents/` — pas dans ce repo.
Le `CLAUDE.md` partagé des agents est dans `~/.claude/agents/CLAUDE.md`.

### Modifier les workflows
Les workflows sont lus par les agents à chaque session.
Toute modification s'applique immédiatement à la prochaine session.

## SCRIBE + Graphify

Initialisation obligatoire au début de CHAQUE session :
```bash
.agent/workflow/scribe/scribe tenor-init --type extension
```

Avant chaque modification de ce repo :
```bash
.agent/workflow/scribe/scribe-rag context
.agent/workflow/scribe/scribe-rag challenge "<ce que tu vas modifier>"
```

Avant de naviguer dans les fichiers :
```bash
cat graphify-out/GRAPH_REPORT.md
graphify query "<ta question>"
```

Après une décision importante → **GHOST** dans SCRIBE.
Après un problème résolu → **SCAR** dans SCRIBE.
Après un pattern identifié → **PAT** dans SCRIBE.

Consulter la mémoire avant toute modification :
```bash
.agent/workflow/scribe/scribe-rag query "décisions architecture"
.agent/workflow/scribe/scribe-rag query "ne pas reproposer"
```

## Workflow sous-agents

### Modifier les règles d'architecture
1. **documentation-specialist** — rechercher les best practices si besoin
2. Modifier directement le fichier `rules/<stack>.md`
3. **code-quality-reviewer** — vérifier la cohérence avec les autres stacks
4. **git-workflow-specialist** — commit + push

### Ajouter/modifier un workflow
1. Modifier directement le fichier `workflows/<workflow>.md`
2. **git-workflow-specialist** — commit + push

### Mettre à jour le README ou STARTUP
1. Modifier directement le fichier
2. **git-workflow-specialist** — commit + push

## Commandes Git

```bash
git add <fichiers-specifiques>
git commit -m "type(scope): message"
git push

# Ne jamais committer :
# .agent/  scribe-out/  graphify-out/  ai-docs/
```

## Notes importantes

- `prompts/project-specific/` → personnel, ne pas partager
- `~/.claude/agents/` → non versionné ici, personnel
- `.agent/` → géré par `~/agent-scribe-graphify/`, ne pas modifier manuellement
- Les chemins dans les JSON templates utilisent `$HOME` — dynamiques
