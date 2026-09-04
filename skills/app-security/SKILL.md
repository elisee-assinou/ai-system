---
name: app-security
description: Sécurise les applications frontend et backend. Audit sécurité d'un projet (API, Next.js, Flutter), hardening de nouveaux modules, revue sécurité avant livraison. Trigger sur "audit sécurité", "sécurise", "security review", "hardening", ou toute tâche touchant auth, tokens, validation, uploads, CORS. Référence les règles ~/ai-system/rules/security.md (OWASP Top 10 / ASVS L2 / API Security Top 10).
---

# APP SECURITY SKILL

**Trigger :** `/app-security`, "audit sécurité", "sécurise cette app/API", "security review", "hardening", ou toute tâche impliquant authentification, autorisation, tokens, validation d'entrées, upload de fichiers, CORS, secrets.

**Référence canonique :** `~/ai-system/rules/security.md` — lire ce fichier EN PREMIER avant toute action de ce skill.

---

## MODES

| Mode | Quand | Action |
|------|-------|--------|
| **AUDIT** | Projet existant, "audit sécurité" | Scan complet → rapport scoré |
| **HARDEN** | Nouveau module/endpoint en cours d'écriture | Appliquer les règles pendant l'implémentation |
| **REVIEW** | Avant commit/PR | Checklist sécurité du module modifié |

Détecter le mode depuis la demande ; en cas de doute, demander.

---

## MODE AUDIT — processus

Exécuter sans demander confirmation. Lire les fichiers concernés et produire le rapport complet en un passage.

### 1. Identifier le périmètre

- Backend : détecter la stack (Express / NestJS / Django / FastAPI) via `package.json`, `pyproject.toml`, `requirements.txt`, structure du projet.
- Frontend : Next.js / React / Flutter.
- Lister les routes/endpoints exposés, les middlewares globaux, la config CORS.

### 2. Checks backend / API

Pour chaque catégorie de `rules/security.md` (§1–6), vérifier dans le code :

- **Auth** : algo JWT explicite, durée tokens, rotation refresh, revocation serveur, Argon2id/bcrypt, comparaison temps constant.
- **Autorisation** : guards par endpoint, vérification de propriété (IDOR), filtrage des champs de rôle (mass assignment).
- **Validation** : schémas sur toutes les routes (zod/class-validator/Pydantic), whitelist DTO, requêtes paramétrées, upload contrôlé, pagination bornée.
- **Headers/CORS** : helmet ou équivalent, CORS whitelist (pas `*` avec credentials), HSTS, nosniff, CSP, cache no-store sur le sensible.
- **Secrets & logs** : aucun secret en dur, `.env` gitignoré, pas de données sensibles loggées, erreurs génériques en prod.
- **Abus** : rate limiting (global + routes sensibles), body size limit, timeouts, idempotence paiements.

### 3. Checks frontend

- **XSS** : `dangerouslySetInnerHTML`, `innerHTML`, `v-html`, interpolation HTML manuelle, markdown non sanitizé.
- **Tokens** : access token en localStorage ? refresh token en cookie HttpOnly ?
- **Secrets client** : clés sensibles dans le bundle (`NEXT_PUBLIC_*`, constantes hardcodées dans Flutter).
- **Liens** : `target="_blank"` sans `rel="noopener noreferrer"`, URLs construites depuis l'utilisateur.
- **Flutter** : SharedPreferences pour du sensible, logs de tokens en release, absence de pinning.

### 4. Checks conteneurisation (Docker)

Lire `Dockerfile`, `docker-compose*.yml`, `.dockerignore` (s'ils manquent → finding ÉLEVÉ : "projet non conteneurisé", générer depuis `~/ai-system/project-templates/docker/`) :

- **Images** : multi-stage build ? image de base taguée précisément (pas `latest`) ? runtime non-root ? `HEALTHCHECK` ? `COPY` (pas `ADD`) ? deps déterministes (`npm ci` / lockfile) ?
- **Secrets** : aucun `ENV SECRET=...`, aucun `.env` copié dans l'image, aucun secret en clair dans le compose commité ?
- **`.dockerignore`** : présent et couvre `.env*`, `.git`, `node_modules`, `.agent/`, `scribe-out/`, `graphify-out/` ?
- **Compose** : `read_only`/`no-new-privileges`/`cap_drop` ? ports DB/Redis publiés en prod ? `privileged: true` ou socket Docker monté ? limits mem/CPU ? rotation des logs ? `depends_on` avec healthchecks ?
- **CI** : scan d'image (Trivy/Docker Scout) configuré ?

### 5. Checks transversaux

- Dépendances : `npm audit` / `pip-audit` (lancer la commande si disponible, sinon vérifier lockfiles).
- `.gitignore` couvre `.env`.
- Tests sur les routes critiques (auth, permissions, paiement).
- Config prod : debug off, Swagger/admin protégés.

### 6. Rapport

Format du rapport :

```
# Audit Sécurité — <projet>
Score global : X/100

## CRITIQUE (bloquant)
- [fichier:ligne] description → fix concret

## ÉLEVÉ
- ...

## MOYEN
- ...

## FAIBLE / RECO
- ...

## Déjà conforme
- liste rapide des points OK
```

**Scoring :** départ 100. CRITIQUE = −25, ÉLEVÉ = −10, MOYEN = −5, FAIBLE = −1.
Planche par catégorie (Auth, Autorisation, Validation, CORS/Headers, Secrets, Frontend, Conteneurisation, Dépendances).

**Sévérités :**
- CRITIQUE : injection possible, secret exposé/commité, auth bypass, `alg: none`, CORS `*` + credentials, token sensible en localStorage.
- ÉLEVÉ : IDOR, mass assignment, absence rate limiting sur auth, erreurs verbeuses en prod, XSS potentiel.
- MOYEN : headers manquants, validation partielle, logs trop verbeux.
- FAIBLE : reco d'amélioration, dette.

---

## MODE HARDEN — processus

Pendant l'implémentation d'un module :

1. Lire `~/ai-system/rules/security.md` et la règle d'archi de la stack.
2. Chaque endpoint créé : auth guard + autorisation + schéma de validation + rate limit si sensible.
3. Chaque modèle/DTO : whitelist des champs, pas de champ de rôle mutable.
4. Middleware sécurité global vérifié (helmet/headers, CORS, body limit).
5. Chaque écran/composant : règles §7/§8 de `rules/security.md`.
6. Docker : si absent, générer depuis `~/ai-system/project-templates/docker/` et appliquer §10 ; jamais de secret dans l'image/compose.
7. Passer la checklist §11 du fichier de règles avant de déclarer le module terminé.

---

## MODE REVIEW — processus

1. `git diff` de la branche / fichiers modifiés.
2. Passer la checklist §11 de `rules/security.md` limitée au périmètre modifié (API, Front, Docker).
3. Verdict : `SHIP` / `FIX` (avec liste des fix), jamais `SHIP` si un point CRITIQUE est ouvert.

---

## RÈGLES DU SKILL

- Toute finding doit citer `fichier:ligne` et proposer le fix concret (pas de constat vague).
- Ne jamais modifier de code en mode AUDIT — rapport seulement (sauf demande explicite).
- Ne jamais logger, copier ou afficher un secret rencontré pendant l'audit → signaler "secret exposé à <fichier>" et recommander rotation immédiate.
- Bug sécurité résolu après > 2 tentatives → SCAR dans SCRIBE (`cause_racine`, `resolution`, `test_binding`).
- Décision de sécurité structurante (choix de stockage de tokens, stratégie de sessions) → GHOST dans SCRIBE.

---

*Elisee ASSINOU*
