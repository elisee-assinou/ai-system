---
name: fluidite-perf
description: Mesurer objectivement la fluidité et la rapidité d'une appli web — latence du temps réel (chat WebSocket) entre deux utilisateurs, images par seconde au défilement, tâches longues, temps d'ouverture d'un écran, sur build de production avec un téléphone moyen simulé (CPU ralenti x4). Trigger sur "c'est fluide ?", "la fluidité", "ça rame", "c'est lent", "performance", "temps réel rapide ?".
---

# MESURER LA FLUIDITÉ

On ne répond pas « c'est fluide » à l'œil : on mesure, sur la version de PRODUCTION, avec un téléphone moyen simulé.

## 1. Toujours mesurer un build de production
Le serveur de dev (Vite) n'est pas représentatif (modules non groupés, HMR) : chiffres 2 à 3 fois pires.
```bash
VITE_API_URL=<api locale> npx vite build --outDir <scratchpad>/dist-perf
npx vite preview --outDir <scratchpad>/dist-perf --port <port autorisé par le CORS> --strictPort
```
(Si le port est pris par le serveur de dev, l'arrêter, mesurer, puis le relancer à l'identique. Supprimer le
dossier de build à la fin.)

## 2. Simuler un téléphone moyen
Contexte Playwright 390x844, isMobile, hasTouch, puis via CDP :
`(await context.newCDPSession(page)).send('Emulation.setCPUThrottlingRate', { rate: 4 })`.
Optionnel : `Network.emulateNetworkConditions` (3G rapide) pour l'ouverture d'écran.

## 3. Mesures et seuils
| Mesure | Comment | Bon | À corriger |
|---|---|---|---|
| Latence temps réel | 2 acteurs ; `t0` avant le clic Envoyer ; attendre le texte chez l'autre ; 10 messages dans chaque sens ; médiane + max | < 300 ms médiane | > 1 s |
| Affichage de son propre message | même boucle, attente chez l'émetteur (doit être optimiste) | < 100 ms sans ralenti | > 300 ms |
| Défilement | boucle `requestAnimationFrame` qui enregistre les écarts entre images pendant 80 pas de `scrollTop` ; médiane, p95, nombre > 50 ms | médiane 16,7 ms, 0 saccade | p95 > 33 ms |
| Tâches longues | `PerformanceObserver({ type: 'longtask', buffered: true })` posé par `addInitScript` | peu, max < 200 ms | max > 500 ms |
| Ouverture d'un écran chargé (60 messages) | `goto` → dernier élément visible | < 2,5 s CPU x4 | > 4 s |

Préparer les données par l'API (ex. 60 messages d'historique) pour mesurer un cas réaliste, pas un écran vide.

## 4. Lire les résultats
- Latence haute mais affichage local rapide → serveur / WebSocket (broker, sérialisation, requêtes N+1).
- Affichage local lent → pas de mise à jour optimiste, ou re-rendu de toute la liste à chaque message
  (mémoïsation, clé stable, virtualisation au-delà de ~200 éléments).
- Saccades au défilement → ombres/flous animés, images sans dimensions, `will-change` laissé à vie, écouteurs scroll
  non passifs.
- Tâches longues au chargement → bundle trop gros (découpage par route), parsing JSON énorme.

## 5. Rapport
Un tableau simple (mesure, résultat, verdict) en langage non technique, en précisant les conditions
(build de prod, CPU x4, local) et ce que seule une vraie personne peut confirmer (vrais téléphones, réseau mobile).
