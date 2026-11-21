# Workflow — retours utilisateurs / testeurs → correctifs en production

Enchaînement utilisé avec succès sur MiConnect (novembre 2026) : refonte mobile, recette, fluidité, retours testeurs.

| Étape | Qui | Skill / agent |
|---|---|---|
| 1. Lire les retours, les reformuler en résultats observables, localiser chaque point dans le code | chef de chantier (toi) | `orchestrer-agents` |
| 2. Petits bugs visuels isolés (« ça décale ») : mesurer, corriger, tester | toi | `chasse-decalage` |
| 3. Chantiers UI par module, en parallèle, brief commun + brief par mission | sous-agents | `mobile-ux-designer`, `frontend-ui-specialist` (+ skills design obligatoires) |
| 4. Bugs de données / cache (ex. notification lue encore dans « non lues ») | sous-agent | `frontend-ui-specialist` — reproduire, cause, test |
| 5. Assets de la maquette (images Figma) | sous-agent | `pixel-perfect`, MCP Figma (ou prototype + Playwright) |
| 6. Contrôle de ce que les agents ont fait (diff, skills réellement appelés, captures) | toi | `orchestrer-agents` §6 |
| 7. Recette e2e des parcours touchés + fluidité | `e2e-recette-runner` | `e2e-recette`, `fluidite-perf` |
| 8. Commit par mission, PR, fusion, déploiement prouvé en prod | `release-verifier` | `livrer-verifier` |
| 9. Compte rendu non technique + ce qui reste à vérifier par un humain | toi | — |

## Phrases de l'utilisateur → réflexe
- « tu as tout testé ? le chat, la fluidité ? » → `e2e-recette` + `fluidite-perf`, réponse chiffrée.
- « ça décale un peu quand je clique » → `chasse-decalage`, réponse « X px avant, 0 px après ».
- « pas joli sur mobile / comme les grandes applis / trop long / trop d'espace en bas » → `mobile-native-pass`.
- « ils n'ont plus vu le bouton X » → problème de découvrabilité : rendre l'action visible là où on en a besoin
  et expliquer quand elle apparaît.
- « déploie » → `livrer-verifier`, jamais « déployé » sans preuve sur l'URL publique.
