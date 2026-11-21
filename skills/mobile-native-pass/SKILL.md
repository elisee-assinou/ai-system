---
name: mobile-native-pass
description: Transformer la version mobile d'une appli web en expérience « app native » (Uber, Airbnb, Revolut, WhatsApp) sans toucher au desktop pixel-perfect. Barre d'onglets, en-tête 56 px, listes compactes, feuilles du bas, boutons collants, écrans d'auth illustrés, footer replié. Trigger sur "mobile pas joli", "comme les grandes applications", "responsive", "ça fait site rétréci", "refonte mobile", "trop d'espace en bas", "trop long sur mobile".
---

# PASSE MOBILE « APP NATIVE »

Objectif : sous `lg` (et surtout à 360-390 px), l'appli doit ressembler à une app conçue par des product designers,
pas à un site desktop rétréci. Le desktop ne bouge pas d'un pixel.

## Skills à appeler d'abord
`emil-design-eng`, `apple-design`, `pixel-perfect`, puis `animate` pour chaque mouvement ajouté.

## Méthode
1. **Inventaire** : lister toutes les routes (router), se connecter avec chaque rôle, capturer chaque écran à
   390x844 (isMobile, hasTouch, DPR 2). Faire une planche contact (Pillow) pour voir l'ensemble d'un coup d'œil.
2. **Diagnostic par écran** : ce qui fait « site » (paragraphes d'intro, tableaux, boutons alignés à droite,
   burger, cartes empilées hétéroclites, espaces morts, actions secondaires partout).
3. **Isoler le desktop** : uniquement des classes `max-lg:` / `max-md:`, ou un rendu alternatif conditionné par un
   hook `useBreakpoint`. Capture 1440 avant/après pour prouver que rien n'a bougé.
4. **Découper par module** et déléguer (skill `orchestrer-agents`), un cahier des charges commun (ci-dessous).
5. **Recette** : skill `e2e-recette` à 375/390 + 1440, puis `fluidite-perf`.

## Cahier des charges (règles issues de la HIG Apple, Material 3 et des apps de référence)
1. Marges latérales 16 px ; 24-32 px entre sections ; titres de section 13-16 px semibold.
2. Écrans racines : grand titre 24 px bold + sous-titre d'une ligne. Pas de paragraphes d'introduction.
3. Navigation : barre d'onglets en bas (64 px + safe-area), en-tête 56 px (logo, cloche, avatar avec menu compte),
   plus de burger. Tout élément fixé en bas se place AU-DESSUS de la barre d'onglets.
4. Listes homogènes = lignes compactes 64-72 px : avatar/icône 40 px, titre 1-2 lignes, sous-titre « a · b »,
   montant/heure à droite, chevron ; toute la ligne ouvre le détail. Une seule action principale visible.
   ATTENTION découvrabilité : une action importante mais rare (signaler un problème, annuler) ne doit pas
   disparaître dans un détail sans aucun indice ; prévoir un menu « … » ou un lien discret sur la ligne.
5. Cartes réservées aux contenus hétérogènes (KPI, solde, mission en cours, appel à l'action). Si les utilisateurs
   préfèrent la carte riche du desktop (ex. résultats de recherche de prestataires), la rendre responsive plutôt
   que d'inventer une ligne compacte qui perd de l'information.
6. Action principale d'un écran de saisie = bouton collant en bas, pleine largeur, 48-52 px,
   `pb-[max(1rem,env(safe-area-inset-bottom))]`.
7. Filtres / onglets : contrôle segmenté défilant horizontalement, `snap-x`, sans barre visible.
8. Détail court / choix / confirmation = feuille du bas flottante (coins hauts arrondis) ; parcours long = plein écran.
9. Montants en chiffres tabulaires, jamais de devise coupée en fin de ligne.
10. États : squelettes de la forme réelle ; vide = icône + titre + 1 bouton ; erreur avec « Réessayer ».
11. Cibles >= 44 px, texte >= 11 px, champs >= 16 px (évite le zoom iOS), contrastes AA,
    `document.documentElement.scrollWidth <= largeur`.
12. Calendrier : bande de semaine + agenda du jour en liste, mois en matrice compacte, pas de grille d'heures écrasée.

## Écrans d'authentification mobiles
- Pas d'image latérale réduite : un en-tête de marque (dégradé de la couleur primaire, bouton retour rond, logo blanc)
  avec une illustration SVG animée par étape (dessin de trait, flottement léger, `prefers-reduced-motion`).
- Le formulaire occupe le reste, pas d'espace mort en bas ; l'illustration se replie quand le clavier s'ouvre
  (hook `useKeyboardOpen` via `visualViewport`).
- Titres d'étape courts en mobile (« Quelle est votre identité ? »), le titre desktop reste inchangé.

## Landing / pages publiques
- Footer mobile : rubriques repliables (bouton `aria-expanded`, ouverture `grid-rows-[0fr]→[1fr]`, liens `inert`
  quand fermé), contacts en pastilles, logo réduit : viser < 900 px de haut à 390.
- Chiffres clés : icône centrée au-dessus du chiffre ; grilles 2x2 avant `xl`.
- Carrousels / éventails de cartes : texte centré dans la carte, largeur `min(70vw, max)`, et AUCUN décalage au
  clic (voir `chasse-decalage` : focus + overflow).

## Mouvement
Appui `active:scale-[0.97]` (0.98 grandes cartes), cascade de liste 30-40 ms plafonnée, transform/opacity seulement,
< 300 ms, ressorts, jamais depuis scale(0), `prefers-reduced-motion`. Ne jamais supprimer une animation existante.

## Définition de « fini »
Captures 390 + 1440 de chaque écran touché regardées, 0 défilement horizontal, axe sans violation, tests et e2e
verts, et l'utilisateur ne dit plus « ça fait site ».
