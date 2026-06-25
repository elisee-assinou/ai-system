# Utilisation des Templates de Projet

## Principe

Chaque template contient :
- **`.opencode/opencode.json`** — config opencode (contextes à charger, permissions)
- **`CLAUDE.md`** — instructions Claude Code (Flutter uniquement)

Au démarrage d'une session, opencode/Claude Code charge automatiquement les fichiers listés dans `instructions` → plus besoin de tout réexpliquer.

---

## 1. Nouveau projet backend (Express, NestJS, FastAPI, Django)

```bash
# 1. Créer le projet
mkdir mon-api && cd mon-api
git init
npm init -y   # ou poetry init, etc.

# 2. Initialiser le template
source ~/ai-system/project-templates/project-init.sh express mon-api

# 3. Ouvrir avec opencode
opencode
```

### Stacks disponibles

| Commande | Stack |
|----------|-------|
| `project-init.sh express` | Express.js + MongoDB |
| `project-init.sh nestjs` | NestJS + PostgreSQL |
| `project-init.sh fastapi` | FastAPI + PostgreSQL |
| `project-init.sh django` | Django + PostgreSQL |
| `project-init.sh fullstack` | Next.js + NestJS + FastAPI |

---

## 2. Nouveau projet Flutter

```bash
# 1. Créer l'app Flutter
flutter create --org com.foryou mon_app

# 2. Initialiser le template (3e param = nom du projet)
source ~/ai-system/project-templates/project-init.sh flutter mon_app "MonApp"

# 3. Résultat
#   - .opencode/opencode.json  → instructions + permissions
#   - CLAUDE.md                → startup, archi, règles, workflow pré-remplis

# 4. Ouvrir
code mon_app
```

Le `CLAUDE.md` généré contient :
- Section `## Startup` qui charge `~/ai-system/` automatiquement
- Architecture DDD complète
- Règles absolues (Result pattern, domain pure, etc.)
- Workflow de dev étape par étape

---

## 3. Reprendre un projet existant

Si le projet a déjà `.opencode/opencode.json` ou `CLAUDE.md`, rien à faire — les instructions sont chargées automatiquement.

Sinon :

```bash
# Depuis la racine du projet existant
source ~/ai-system/project-templates/project-init.sh express .
```

---

## 4. Ajouter manuellement

Si tu préfères ne pas utiliser le script, copie simplement le fichier JSON à la main :

```bash
mkdir -p mon-projet/.opencode
cp ~/ai-system/project-templates/express-mongodb.json mon-projet/.opencode/opencode.json
```

---

## 5. Personnaliser un template

Édite directement les fichiers JSON dans `~/ai-system/project-templates/` :

- **`instructions`** : chemins vers les fichiers de contexte à charger
- **`permission.bash`** : commandes autorisées sans demande
- **`CLAUDE.flutter.md`** : template CLAUDE.md (utilise `{{PLACEHOLDERS}}` pour les variables)

---

## Structure complète de `~/ai-system/`

```
~/ai-system/
├── project-templates/
│   ├── express-mongodb.json     ← Template Express.js
│   ├── nestjs-postgres.json     ← Template NestJS
│   ├── fastapi-postgres.json    ← Template FastAPI
│   ├── django-postgres.json     ← Template Django
│   ├── nextjs-nestjs-fastapi.json ← Template Fullstack
│   ├── flutter.json             ← Template Flutter (opencode)
│   ├── CLAUDE.flutter.md        ← Template Flutter (CLAUDE.md)
│   ├── project-init.sh          ← Script d'initialisation
│   └── USAGE.md                 ← Ce fichier
├── architecture/context.md      ← Architecture globale
├── rules/                       ← Règles par stack
├── prompts/                     ← Prompts système
├── workflows/                   ← Workflows
└── skills/                      ← Skills
```

---
*Elisee ASSINOU*
