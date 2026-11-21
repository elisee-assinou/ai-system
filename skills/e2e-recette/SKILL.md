---
name: e2e-recette
description: Recette de bout en bout en vrai navigateur (Playwright, playwright-core) contre le vrai backend local — parcours multi-acteurs (client, prestataire, admin), temps réel (WebSocket, coupure réseau), argent (séquestre, soldes, audit), sécurité entre comptes, accessibilité axe, mobile 375/390 + desktop 1440, captures. Trigger sur "tu as tout testé ?", "teste toutes les fonctionnalités", "recette", "e2e", "est-ce que ça marche vraiment", "le chat en temps réel marche ?".
---

# RECETTE E2E EN VRAI NAVIGATEUR

« Tout est testé » ne veut dire quelque chose que si un vrai navigateur a joué le parcours d'un vrai utilisateur
contre le vrai backend, à la taille mobile ET desktop, et que les captures ont été regardées.

## Organisation recommandée (dossier `e2e/`)
- `lib/config.mjs` : FRONT, URL API, comptes de test (jamais de secrets en dur : variables d'env / fichier d'état
  hors dépôt), tailles d'écran `{ mobile: 375x812, desktop: 1440x900 }`.
- `lib/browser.mjs` : `launchBrowser()`, `newActor(browser, nom, { viewport })` → `{ context, page, viewport }`.
  Un acteur = un contexte isolé (cookies séparés) : indispensable pour 2 utilisateurs qui se parlent.
- `lib/auth.mjs` : connexion par l'UI (OTP lu côté serveur via une commande de gestion, quotas OTP levables).
- `lib/api.mjs` : client API authentifié pour PRÉPARER les données (créer une demande, un message) et VÉRIFIER
  l'état serveur après une action UI.
- `lib/manage.mjs` : commandes serveur (seed, reset quotas, audit des portefeuilles, requête ORM en JSON).
- `lib/checks.mjs` : `createReport(scenario)` → `check(cond, libellé)`, `OK`/`KO` lisibles par un non-dev.
- `scenarios/<rôle>/<lettre>-<parcours>.e2e.mjs` + `run.mjs <filtre...>` qui exécute et résume « 30/31 au vert ».

## Ce que chaque scénario vérifie systématiquement
- Le parcours fonctionne aux DEUX tailles (boucle sur `['mobile','desktop']`).
- `document.documentElement.scrollWidth <= largeur` à chaque capture (pas de défilement horizontal).
- Aucune erreur console hors erreurs attendues (listées explicitement).
- L'état serveur après l'action UI (statut, montant, nombre d'enregistrements : jamais de doublon).
- Captures nommées `<largeur>-<nn>-<étape>.png` dans `e2e/shots/<scénario>/`, et capture `zz-erreur` en cas d'échec.

## Familles de scénarios à couvrir
1. **Invité / landing** : fumée, liens, formulaires publics, accessibilité axe.
2. **Inscription / connexion** de chaque rôle, y compris validation par l'admin.
3. **Parcours métier principal** de bout en bout (demande → proposition → paiement → mission → fin → avis).
4. **Temps réel** : deux acteurs, message reçu sans recharger dans les deux sens ; `context.setOffline(true)` sur
   l'un → bandeau hors ligne, rien n'arrive ; retour réseau → message parti tout seul, livré, enregistré UNE fois,
   aucun message « en échec » ; cloche de notifications qui monte sans recharger ; brouillon par conversation.
5. **Argent** : séquestre, libération, solde crédité du bon montant, double déclaration sans effet, litige qui
   bloque la libération, commande d'audit des portefeuilles = 0 écart avant/après.
6. **Sécurité entre comptes** : chaque endpoint appelé avec l'identifiant d'un autre utilisateur → 403/404,
   WebSocket d'une autre conversation refusée, routes d'un autre rôle redirigées, données inchangées.
7. **Accessibilité** : axe-core sur chaque page clé aux deux tailles ; contrastes AA (piège fréquent :
   `text-white/80` sur une couleur de marque).
8. **Notifications** : marquer lu → disparaît du filtre « non lues », compteur qui baisse, état qui survit au
   rechargement.

## Règles
- Ne jamais créer de données qui notifient de vrais utilisateurs en production ; recette en local ou préprod.
  Pas de vrai paiement sans l'utilisateur ; ne jamais valider un vrai retrait.
- Prestataire de paiement en panne (sandbox en 500) : marquer ces scénarios « non vérifiables », ne pas les
  déclarer verts.
- Données de test qui s'accumulent (plafonds quotidiens consommés) : reseed ou nettoyer avant de conclure à un bug.
- Un test unitaire instable sous charge : relancer seul avant de conclure.
- En prod, `waitUntil: 'load'` (pas `networkidle`, qui ne termine jamais avec un WebSocket ouvert).
- Après chaque changement d'UI, adapter les sélecteurs par rôle/nom accessible (`getByRole`) plutôt que par classe.

## Rapport à l'utilisateur
Ce qui a été joué (parcours, tailles), le score « N/M au vert », chaque KO expliqué simplement, et ce qui reste
à vérifier par un humain (vrai téléphone, réseau mobile, vrai paiement).
