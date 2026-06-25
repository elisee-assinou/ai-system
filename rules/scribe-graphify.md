# SCRIBE + Graphify — Réflexes Agent

## Quand utiliser

Ces réflexes s'appliquent quand un projet contient le bundle `.agent/` (copié par `project-init.sh` depuis `~/agent-scribe-graphify/.agent`).

Si `.agent/` n'existe pas dans le projet → ignorer ces réflexes.

---

## Graphify — Navigation structurelle

Avant de lire des fichiers pour comprendre la structure du code :

```bash
cat graphify-out/GRAPH_REPORT.md                        # Carte structurelle (~500 tokens)
graphify query "ta question"                            # ~700 tokens vs ~50k en lisant les fichiers
graphify path "FonctionA" "FonctionB"                   # Chemin exact entre 2 nœuds
graphify explain "NomModule"                            # Explication complète d'un nœud
```

Réflexe :
- SI `graphify-out/GRAPH_REPORT.md` existe → le lire AVANT de parcourir les fichiers sources
- SI tu cherches qui appelle quoi → `graphify path` AVANT `grep`
- SI tu veux comprendre un module → `graphify explain` AVANT de lire > 2 fichiers

---

## SCRIBE — Mémoire causale

### Avant implémentation

```bash
.agent/workflow/scribe/scribe-rag context                # Charger le contexte mémoire
.agent/workflow/scribe/scribe-rag challenge "<plan>"     # Vérifier les risques
```

Verdicts du challenge :
- `PROCEED` → implémenter
- `REVIEW` → lire les warnings, décider avec l'utilisateur
- `STOP` → ne pas implémenter, comprendre pourquoi

### Après un bug résolu (> 2 tentatives)

Créer un SCAR immédiat avec `cause_racine`, `resolution`, `test_binding`.

### Avant fermeture de session

> "Qu'est-ce qui fera souffrir le prochain LLM si je ne le documente pas ?"

Si douleur concrète → SCAR ou GHOST. Sinon → JOURNAL suffit.

---

## Modes de friction

| Mode | Condition | Préflight |
|------|-----------|-----------|
| NANO | < 30 min, 1 fichier, pas de surface partagée | `scribe-rag context` seulement |
| STANDARD | Changement significatif | `scribe-rag build` + `context` + `challenge` |
| CRITICAL | Auth, data, API publique, surface partagée | Workflow complet (read, check, sync, preflight) |

---

## Séparation des responsabilités

- **Graphify** = structure du code (quoi, où, comment)
- **SCRIBE** = causalité (pourquoi, douleur, décision, cicatrice)

Ne pas écrire dans SCRIBE ce que Graphify peut déduire du code.

---

## Git — surfaces agentiques

Ne jamais committer ces dossiers :
```
.agent/
scribe-out/
graphify-out/
```

Toujours `git add <fichiers-spécifiques>`, jamais `git add .`.
