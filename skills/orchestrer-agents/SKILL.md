---
name: orchestrer-agents
description: Piloter un chantier produit avec plusieurs sous-agents en parallèle — découper les retours utilisateurs ou une refonte en missions disjointes, écrire un brief commun + un brief par mission, exiger l'appel des skills design, vérifier ce que les agents ont réellement fait, regrouper, tester, livrer. Trigger sur "retours des testeurs", "plusieurs corrections", "refonte", "fais tout", "finis tout et déploie", "lance des agents", ou toute demande qui touche plusieurs modules à la fois.
---

# ORCHESTRER DES AGENTS (chef de chantier)

Tu es le chef de chantier : tu ne codes pas les missions toi-même, tu les découpes, tu les briefes,
tu vérifies, tu assembles et tu livres. Tu gardes la vue d'ensemble et tu parles à l'utilisateur.

## 1. Comprendre avant de déléguer (toi-même, 5 à 10 appels max)
- Reformule chaque demande en résultat observable (« la carte ne bouge pas de 1 px après 3 clics »).
- Localise chaque point dans le code (grep ciblé, graphify si présent) : fichiers, règle métier, test e2e existant.
- Distingue : bug (reproduire → cause → correctif → test) / évolution UI (avant/après en captures) / contenu (assets, textes).
- Si une demande est déjà satisfaite mais invisible (bouton enterré dans un détail), c'est un problème de
  découvrabilité : traite-le comme tel au lieu de répondre « ça existe déjà ».
- Petit bug isolé (1-2 fichiers) : fais-le toi-même, c'est plus rapide qu'un brief. Voir `chasse-decalage`.

## 2. Découper en missions disjointes
- Une mission = un module / un ensemble de fichiers qu'aucune autre mission ne touche. Plusieurs agents peuvent
  alors travailler dans le MÊME worktree en parallèle. Si deux missions touchent le même fichier : les sérialiser
  ou utiliser des worktrees séparés.
- Interdire aux agents : commit, `git add`, changement de branche, `tsc -b` global (utiliser `tsc -p ... --noEmit`).
- Lancer toutes les missions indépendantes dans UN SEUL message (appels Agent en parallèle, en arrière-plan).

## 3. Brief commun (fichier COMMUN.md dans le scratchpad) — modèle : `~/ai-system/prompts/brief-commun-template.md`
Contenu obligatoire :
1. **Première action obligatoire : appeler l'outil Skill avec X, Y, Z** (ex. `emil-design-eng`, `apple-design`,
   `pixel-perfect`, `animate`). Leçon vécue : un brief qui « cite » les principes HIG/Material sans EXIGER l'appel
   produit des agents qui n'invoquent aucun skill. Exiger la liste des skills invoqués dans le rapport.
2. Contraintes du dépôt (tokens, taille max des fichiers, architecture, zéro code mort, langue).
3. Règles d'or : ne jamais supprimer une animation existante sans accord ; desktop figé si la maquette le fige.
4. Comment voir le résultat : URL du front de recette, comptes de test, script Playwright temporaire, tailles de
   capture (390x844 mobile + 1440x900 desktop), dossier où ranger les captures, obligation de les REGARDER.
5. Vérifications à lancer + test de non-régression pour chaque bug.
6. Format du rapport : cause, fichiers, avant/après, captures, résultats, skills invoqués.

## 4. Brief par mission
Court, autonome : constat (avec les fichiers déjà localisés), résultat attendu observable, ce qui ne doit PAS
bouger, scénarios e2e à adapter/relancer, et ce qu'il faut signaler plutôt que faire (ex. bug backend).

## 5. Pendant que les agents tournent
- Ne fais pas leur travail en double. Avance sur ce qui ne dépend pas d'eux (docs, skills, préparation de la livraison).
- Si l'utilisateur demande où on en est : dire ce qui tourne, sans inventer de résultat.

## 6. Au retour de chaque agent — ne jamais croire le rapport sur parole
- `git diff --stat` : seuls les fichiers attendus ont bougé ?
- Vérifier dans le transcript de l'agent qu'il a vraiment appelé les skills :
  `grep -o '"name":"Skill","input":{"skill":"[^"]*"' <transcript.jsonl> | sort | uniq -c`
- Regarder soi-même 2-3 captures clés (outil Read sur le PNG).
- Relancer tsc, lint, tests unitaires COMPLETS (pas seulement ceux de l'agent) une fois tous les agents revenus.
- Si un point est raté : SendMessage à l'agent avec la correction précise (il garde son contexte).

## 7. Assembler et livrer
- Un commit par mission (message conventionnel en français, fichiers listés explicitement, jamais `git add .`).
- Recette e2e des parcours touchés, puis skill `livrer-verifier`.
- Compte rendu à l'utilisateur : un tableau « demande → ce qui a été fait → vérifié en prod », en langage
  non technique, plus ce qui reste à vérifier par un humain (paiement réel, vrai téléphone).

## Pièges vécus
- Agents coupés en plein travail (réseau) : vérifier `git status` de chaque worktree avant de relancer.
- Deux agents connectés au même compte de test au même moment : l'OTP de l'un invalide l'autre → réessayer.
- Un agent « passe mouvement » a supprimé une inclinaison 3D jugée « trompeuse » : l'utilisateur l'a réclamée.
  Toujours écrire « ne supprime aucun effet existant, améliore seulement ».
