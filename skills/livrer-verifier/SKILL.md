---
name: livrer-verifier
description: Livrer en production et PROUVER que c'est en ligne — vérifications locales, branche, commit conventionnel en français sans mention d'IA, PR, fusion, attente du déploiement automatique (Coolify/Vercel/etc.) en surveillant l'empreinte du bundle, puis contrôle Playwright sur l'URL publique. Trigger sur "déploie", "on déploie tout", "mets en prod", "c'est en ligne ?", "déploye les nouveautés".
---

# LIVRER ET VÉRIFIER EN PRODUCTION

« Déployé » = l'URL publique sert la nouvelle version ET le comportement corrigé y est observé.

## 1. Avant de pousser
- Branche dédiée partant de `main` à jour (jamais de commit direct sur `main`). Si `main` est déjà extrait dans
  un autre worktree : `git fetch <remote> main:refs/remotes/origin/main` puis `git checkout -B <branche> origin/main`.
- Vérifications complètes : typage (`tsc -b`), lint, tests unitaires COMPLETS, build de production ; backend :
  suite de tests. Scénarios e2e des parcours touchés.
- `git status` : ne committer que les fichiers voulus, listés un par un (jamais `git add .`), jamais les dossiers
  d'outillage (`.agent/`, `scribe-out/`, `graphify-out/`), ni les scripts temporaires `e2e/_*.mjs`.

## 2. Commit, PR, fusion
- Message conventionnel en français : `fix(landing): l'éventail ne se décale plus au clic` + un corps qui explique
  la CAUSE en 2-3 lignes. Respecter les consignes de l'utilisateur sur l'attribution (ici : aucune mention
  d'IA, pas de Co-Authored-By, pas de « Generated with »).
- Push en HTTPS avec l'assistant d'identification de `gh` si SSH ne marche pas :
  `git -c credential.helper= -c credential.helper='!gh auth git-credential' push https://github.com/<org>/<repo>.git <branche>`
- `gh pr create` (titre = message du commit, corps = constat, correctif, comment c'est vérifié), puis
  `gh pr merge --merge` UNIQUEMENT si l'utilisateur a demandé de déployer.
- Front + back liés : fusionner le back d'abord (compatible avec l'ancien front), puis le front.

## 3. Attendre le déploiement sans deviner
```bash
ancien=$(curl -s https://<site>/ | grep -o 'assets/index-[^"]*\.js')
# après la fusion :
for i in $(seq 1 40); do h=$(curl -s https://<site>/ | grep -o 'assets/index-[^"]*\.js');
  [ -n "$h" ] && [ "$h" != "$ancien" ] && { echo "en ligne : $h"; break; }; sleep 15; done
```
Backend : appeler la nouvelle route (401 sans authentification = elle existe ; 404 = pas encore déployée).

## 4. Vérifier le comportement en production
Script Playwright temporaire contre l'URL publique (`waitUntil: 'load'`), aux largeurs concernées, qui rejoue la
mesure ou le parcours du correctif. Ne pas créer de données de test en production qui notifient de vrais
utilisateurs ; pas de paiement réel sans l'utilisateur.

## 5. Annoncer
Tableau « changement → PR → heure de fusion → vérifié en prod » ; conseiller de recharger la page (cache / service
worker PWA) ; lister ce qui reste à vérifier par un humain. Ne jamais dire « déployé » sur la seule foi d'une fusion.
