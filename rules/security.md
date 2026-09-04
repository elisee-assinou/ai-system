# Security Rules — Règles transversales de sécurisation (API + Front)

Règle **transversale** exigée pour TOUT code qui expose une API, produit une UI,
ou est livré conteneurisé (Docker) — c'est-à-dire tous les projets.

Complète les règles d'architecture (`expressjs.md`, `nestJs.md`, `django.md`,
`python-fastapi.md`, `frontend.md`, `nextjs.md`, `flutter.md`).
Les règles d'architecture répondent à la structure ; celle-ci répond à la sécurité.

Référentiels : OWASP Top 10, OWASP ASVS L2, OWASP API Security Top 10.

---

## 0. Règle d'or

- **Ne jamais faire confiance au client.** Toute donnée entrante (body, query, params, headers, cookies, fichiers) est hostile par défaut.
- **Défense en profondeur** : chaque couche valide ; la frontière API n'est pas la seule protection.
- **Fail secure** : en cas d'erreur, on refuse l'accès, on ne l'ouvre jamais par défaut.
- **Least privilege** : chaque endpoint, rôle et service n'a que les droits strictement nécessaires.
- **Secrets hors du code** : jamais de secret en dur, jamais de secret commité, jamais de secret dans les logs.

---

## 1. Backend / API — Authentification

### Sessions & JWT
- Tokens signés avec algorithme explicite (`HS256`/`RS256`) — **jamais `alg: none`**, toujours valider l'alg côté serveur.
- Access token court (5–15 min) + refresh token long, rotatif, avec reuse detection.
- Revocation serveur obligatoire : blacklist Redis (Express) / token version / jti blacklist.
- Logout = invalidation côté serveur, pas seulement suppression côté client.
- Hash de mots de passe : **Argon2id** (défaut) ou bcrypt coût ≥ 12. Jamais MD5/SHA1/SHA256 simple.
- Comparaison de tokens/secrets en temps constant (`crypto.timingSafeEqual` / `hmac.compare_digest`).

### Endpoints sensibles
- Rate limiting sur : login, register, OTP, reset-password, refresh, toute route publique.
- Lockout progressif ou verrouillage après N échecs (compteur Redis avec TTL).
- OTP : 6 chiffres max 5 tentatives, TTL ≤ 5 min, mono-usage, rate-limité par téléphone/email.
- Reset password : token mono-usage, TTL ≤ 15 min, invalidé après usage.

---

## 2. Backend / API — Autorisation

- Vérifier l'autorisation **à chaque endpoint**, jamais seulement au login.
- IDOR : ne jamais exposer/accepter un ID sans vérifier la propriété (`resource.ownerId === user.id`). Toute route `GET/PUT/DELETE /:id` doit prouver le droit d'accès.
- Rôles/permissions vérifiés dans un middleware/guard/décorateur central — pas dispersés dans les handlers.
- Élévation de rôle interdite via payload : les champs `role`, `isAdmin`, `verified` sont **filtrés du body** (whitelist DTO, jamais de mass assignment).
- Endpoints admin isolés (préfixe `/admin`, guard dédié, idéalement réseau séparé).

---

## 3. Backend / API — Validation des entrées

- **Toute** entrée validée avec un schéma (zod / class-validator / Pydantic / DRF serializers) à la frontière presentation.
- Whitelist des champs autorisés — jamais `req.body` passé directement à l'ORM.
- Types stricts : rejeter les mauvais types, borner longueurs (strings max), intervalles (nombres), formats (email, phone).
- Requêtes paramétrées uniquement (ORM ou prepared statements) — **jamais** de concaténation SQL/NoSQL.
- NoSQL : rejeter les objets opérateurs (`{"$gt": ""}`) — valider que la valeur est une string.
- Upload fichiers : whitelist d'extensions + vérification MIME réel (magic bytes), taille max, stockage hors webroot, noms de fichiers régénérés.
- Pagination bornée : `limit` max imposé serveur (ex: ≤ 100), jamais laissé libre.

---

## 4. Backend / API — Headers, CORS & transport

- HTTPS obligatoire en production (HSTS).
- CORS : whitelist d'origines explicites — **jamais `Access-Control-Allow-Origin: *`** avec credentials.
- Security headers obligatoires (helmet / middleware dédié) :
  - `X-Content-Type-Options: nosniff`
  - `X-Frame-Options: DENY` (ou CSP frame-ancestors)
  - `Content-Security-Policy`
  - `Referrer-Policy: no-referrer`
  - `Strict-Transport-Security`
  - `Cache-Control: no-store` sur toute réponse contenant des données sensibles.
- Désactiver `X-Powered-By` et tout header révélant le framework/la version.

---

## 5. Backend / API — Secrets, logs & données sensibles

- Secrets dans variables d'env / secret manager — jamais dans le repo, jamais dans les logs.
- `.env` au `.gitignore` + fournir un `.env.example` sans vraies valeurs.
- Ne jamais logger : mots de passe, tokens, OTP, cartes, données personnelles complètes. Masquer (ex: `***`, 4 derniers chiffres).
- Réponses d'erreur génériques en production : jamais de stack trace, détail SQL ou chemin de fichier exposé au client.
- Ne jamais révéler si un email existe lors de login/reset (même message, même timing) — anti user enumeration.
- Données sensibles (PII, santé, paiement) : chiffrement au repos, minimisation de collecte.

---

## 6. Backend / API — Abus & robustesse

- Rate limiting global + par route (Redis ou reverse proxy) — 429 avec `Retry-After`.
- Body size limits (ex: `express.json({ limit: '100kb' })`).
- Timeouts sur tous les appels sortants (HTTP, DB) — jamais d'appel infini.
- Protection slowloris/DoS basique : timeouts serveur configurés.
- Idempotence sur les opérations sensibles (paiement, création) — clé d'idempotence.
- Dépendances : audit régulier (`npm audit` / `pip-audit`), verrouillage des versions, pas de packages typosquattés.

---

## 7. Frontend (Next.js / React) — XSS & données

- **Jamais `dangerouslySetInnerHTML`** sans sanitisation stricte (DOMPurify) — si possible, jamais du tout.
- Rendu des données utilisateur toujours via React (échappement automatique) — jamais d'interpolation HTML manuelle.
- URL `href`/`window.open` construits depuis données utilisateur : valider le schéma (`https:` uniquement) — bloquer `javascript:`.
- `target="_blank"` toujours avec `rel="noopener noreferrer"`.
- Markdown/contenu riche : rendu via lib sûre avec sanitisation (rehype-sanitize / DOMPurify).
- Tokens : access token en mémoire uniquement (jamais `localStorage`/`sessionStorage` si XSS possible) ; refresh token en cookie `HttpOnly; Secure; SameSite=Strict` géré par le backend.
- Aucune donnée sensible dans localStorage, URL, ou state exposé.
- CSP définie (via middleware/headers) ; pas d'`unsafe-inline`/`unsafe-eval` sauf nécessité documentée.
- Server Components par défaut ; les secrets API ne vont JAMAIS dans le bundle client (pas de `NEXT_PUBLIC_` sur un secret).
- Formulaires : validation miroir côté client (UX) mais jamais substitut à la validation serveur.

---

## 8. Frontend (Flutter) — stockage & transport

- Secrets/tokens jamais en clair : `flutter_secure_storage` (Keychain/Keystore) — jamais `SharedPreferences` pour du sensible.
- Aucune clé API côté mobile qui ne devrait pas être publique — passer par le backend (proxy) pour les clés tierces.
- Certificate pinning sur les appels sensibles (Dio + pinning) en production.
- Désactiver les logs de tokens/données sensibles (`print`, interceptors) en release.
- Blocage screenshots sur écrans sensibles si requis (flag sécurisé).
- Deep links : valider et borner tous les paramètres reçus.

---

## 9. Configuration & déploiement

- Pas de debug/verbose en production (`NODE_ENV=production`, `DEBUG=False` Django).
- Pas d'endpoints de dev exposés (Swagger en prod = auth ou désactivé ; Django admin protégé).
- Versions de frameworks/ORM à jour ; patching des CVE critiques en priorité.
- Backups DB chiffrés + testés ; secrets de prod distincts de dev.
- CI : lint sécurité + audit dépendances + tests des routes critiques (auth, permissions).

---

## 10. Conteneurisation — Docker (tout doit être conteneurisé)

Tout backend ET frontend est livré conteneurisé : `Dockerfile` + `docker-compose.yml` à la racine de chaque projet, générés durcis par `project-init.sh` (templates dans `project-templates/docker/`).

### Images
- **Multi-stage build** obligatoire : builder → runtime minimal (`node:22-alpine`, `python:3.12-slim`, image Next.js standalone). Les outils de build (gcc, dev deps) ne vont JAMAIS dans l'image finale.
- Image de base taguée précisément (`node:22.11-alpine`) — **jamais `latest`**.
- Utilisateur non-root obligatoire : `USER node` / création d'un user dédié ; jamais `root` au runtime.
- `HEALTHCHECK` défini (route `/health` ou commande dédiée).
- `COPY` uniquement, jamais `ADD` ; pas de `curl | sh` dans le Dockerfile.
- Dépendances installées de manière déterministe (`npm ci` avec lockfile, `pip install --no-cache-dir -r requirements.txt`).
- Pas de secrets dans l'image : jamais d'`ENV SECRET=...`, jamais de `.env` copié dans l'image. Les secrets passent par l'env runtime (`--env-file` / compose `env_file` / secret manager).
- `.dockerignore` obligatoire : `.git`, `.env*`, `node_modules`, `scribe-out/`, `graphify-out/`, `.agent/`, `ai-docs/`.

### Runtime / docker-compose
- `read_only: true` quand possible + `tmpfs` pour `/tmp` ; sinon monter les volumes nécessaires uniquement.
- `no-new-privileges:true` (`security_opt`), drop des capabilities (`cap_drop: ALL` + uniquement celles nécessaires).
- Pas de `privileged: true`, pas de montage du socket Docker (`/var/run/docker.sock`) sauf nécessité absolue documentée.
- Réseau interne par défaut ; seuls les ports nécessaires publiés (`ports: "3000:3000"` jamais `0.0.0.0` non contrôlé). La DB/Redis ne publient JAMAIS leur port en prod (réseau interne uniquement).
- Ressources limitées : `mem_limit` / `cpus` (ou `deploy.resources.limits`) pour éviter l'OOM-kill en cascade.
- `restart: unless-stopped` + healthchecks dépendants (`depends_on.condition: service_healthy`).
- Secrets en prod : Docker secrets / fichiers secrets montés, pas de variables d'env sensibles en clair dans le compose commité. Le compose commité référence `.env` (gitignoré) via `env_file`.
- Logs : driver `json-file` avec rotation (`max-size`, `max-file`) — pas de logs illimités.

### Registre & CI
- Scan d'images dans la CI (`trivy` / `docker scout`) — bloquant sur CVE critique/haute.
- Images de prod immuables (tag par commit/semver, pas de re-tag).
- Pas d'image avec données sensibles poussée sur un registre public.

---

## 11. Checklist sécurité — avant de livrer TOUT module

### API
- [ ] Authentification vérifiée sur chaque route protégée
- [ ] Autorisation (propriété/rôle) vérifiée sur chaque accès à une ressource
- [ ] Entrées validées par schéma (whitelist) à la frontière
- [ ] Pas de SQL/NoSQL injectable (requêtes paramétrées)
- [ ] Rate limiting sur routes sensibles
- [ ] Secrets hors code et hors logs
- [ ] Erreurs génériques en production
- [ ] CORS whitelist explicite + security headers

### Frontend
- [ ] Aucun `dangerouslySetInnerHTML` non sanitizé
- [ ] Tokens hors localStorage (mémoire ou cookie HttpOnly)
- [ ] Aucun secret dans le bundle client
- [ ] Liens externes avec `rel="noopener noreferrer"`
- [ ] Validation miroir côté client uniquement pour l'UX

### Conteneurisation
- [ ] Multi-stage build, image finale minimale, tag précis (pas `latest`)
- [ ] Runtime non-root + `HEALTHCHECK`
- [ ] Aucun secret dans l'image ni le compose commité
- [ ] `.dockerignore` présent (`.env*`, `.git`, `node_modules`, `.agent/`...)
- [ ] `read_only`/`no-new-privileges`/`cap_drop` configurés
- [ ] Ports DB/Redis non publiés en prod
- [ ] Limits mémoire/CPU + rotation des logs
- [ ] Scan d'image (Trivy/Scout) dans la CI

### Transversal
- [ ] Dépendances auditées sans CVE critique
- [ ] `.env` gitignoré + `.env.example` fourni
- [ ] Tests sur les routes critiques (auth, IDOR, permissions)

---
*Elisee ASSINOU*
