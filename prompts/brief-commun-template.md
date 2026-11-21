# Modèle de brief commun pour sous-agents (à copier dans le scratchpad en COMMUN.md)

Utilisé par le skill `orchestrer-agents`. Remplacer les <...>. Chaque agent reçoit : « Lis d'abord et applique
<chemin>/COMMUN.md (mission = `<nom>`) » + son brief de mission.

---

# <Chantier> — règles communes à tous les agents

Dépôt : `<chemin du worktree>` (branche `<branche>`). Stack : <...> (lis `CLAUDE.md` du dépôt). D'autres agents
travaillent EN MÊME TEMPS dans ce dossier sur d'autres modules : ne touche que les fichiers de ta mission.

## Première action obligatoire
Appelle l'outil Skill avec `<skill 1>`, puis `<skill 2>`, puis `<skill 3>` (et `animate` si tu ajoutes du
mouvement). Liste les skills invoqués dans ton rapport final.

## Contraintes (obligatoires)
- Desktop : <figé sur la maquette / libre>.
- Mobile : style app native (marges 16 px, cibles >= 44 px, texte >= 11 px, AA, 0 défilement horizontal).
- <Tokens uniquement, taille max des fichiers, règles d'architecture, zéro code mort, langue des textes.>
- Ne supprime jamais une animation existante. Mouvement : transform/opacity, < 300 ms, reduced-motion.
- NE PAS committer, NE PAS `git add`, NE PAS changer de branche.
- Vérifs sur tes fichiers : <typage sans build global>, <lint>, <tests>. Un test de non-régression par bug.

## Voir le résultat (obligatoire)
Front de recette : <URL> (API <URL>). Script Playwright temporaire `e2e/_<mission>.mjs`, supprimé ensuite.
Comptes : <noms des comptes de test, jamais les secrets>. Captures 390x844 (isMobile, hasTouch, DPR 2) + 1440x900
dans `<scratchpad>/<chantier>/<mission>/`. Regarde-les et itère jusqu'à un rendu pro.
Scénarios e2e qui dépendent de ton changement : adapte-les et relance-les.

## Rapport final (court, en français)
Cause trouvée, fichiers modifiés/créés/supprimés, avant/après, chemins des captures, résultats des vérifs,
skills invoqués, ce que tu n'as pas pu faire et pourquoi.
