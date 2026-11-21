---
name: chasse-decalage
description: Reproduire, mesurer et corriger un bug visuel signalé avec des mots vagues — "ça décale un peu", "ça saute", "ça bouge quand je clique", "c'est pas centré", "il y a un espace en bas", "ça déborde sur mobile", "l'animation se déclenche trop tôt". Mesure les positions avant/après l'interaction à plusieurs largeurs, trouve la cause, corrige, test de non-régression, vérifie en production.
---

# CHASSE AU DÉCALAGE (bugs visuels vagues)

Un « ça décale un peu » se transforme en un CHIFFRE avant d'être corrigé, et le correctif se prouve par le même chiffre.

## 1. Reproduire en mesurant (Playwright, 3-4 largeurs : 360, 390, 768/1024, 1440)
Avant puis après chaque interaction (clic, balayage, survol, focus clavier), relever :
```js
() => {
  const el = document.querySelector(SELECTEUR); const r = el.getBoundingClientRect();
  const sec = el.closest('section');
  return { x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width),
           scrollY, secScrollLeft: sec?.scrollLeft, docScrollLeft: document.documentElement.scrollLeft,
           scrollWidth: document.documentElement.scrollWidth }
}
```
Répéter l'interaction 3 à 5 fois (un décalage peut s'accumuler). Capturer l'écran. Si les chiffres bougent :
bug reproduit, et on sait à quelle largeur.

## 2. Causes classiques (vérifier dans cet ordre)
1. **Focus qui fait défiler** : `element.focus()` déplacé par le code (accessibilité clavier) fait défiler le
   conteneur le plus proche, Y COMPRIS un `overflow: hidden` (défilable par le code). Correctif :
   `focus({ preventScroll: true })` + `overflow: clip` (`overflow-clip`) sur la section, qui n'est pas défilable.
2. **Barre de défilement** qui apparaît/disparaît (ouverture de modale) → `scrollbar-gutter: stable`.
3. **`100vw`** qui inclut la barre de défilement → `100%` / `inset-x-0`.
4. **Images sans `width`/`height`** ou `aspect-ratio` → saut au chargement.
5. **Changement de police** (FOUT) → `font-display` + métriques de repli.
6. **Élément absolu/transformé qui dépasse** → défilement horizontal de page (`scrollWidth > largeur`).
7. **Animation déclenchée trop tôt/tard** : `useInView` / IntersectionObserver posé sur un élément de hauteur 0
   (liste à enfants absolus) → observer le bloc qui a une vraie hauteur.
8. **Contenu qui change de taille** (texte qui passe sur 2 lignes, badge qui apparaît) → réserver la place.
9. **Espace mort en bas** : `min-h-screen` + padding de barre d'onglets cumulés, `pb-*` fixe pour un clavier.

## 3. Corriger au plus petit endroit
Un correctif de 1-2 lignes vaut mieux qu'une réécriture. Ne pas toucher au rendu desktop si le bug est mobile
(sauf si la cause est commune et le correctif neutre).

## 4. Verrouiller
- Test unitaire ciblé sur la cause (ex. espionner `HTMLElement.prototype.focus` et attendre
  `{ preventScroll: true }`).
- Re-mesurer : les chiffres doivent être identiques avant/après à toutes les largeurs.

## 5. Vérifier en production
Après déploiement (skill `livrer-verifier`), rejouer la même mesure sur l'URL publique. Annoncer à l'utilisateur
le chiffre avant/après (« la carte glissait de 185 px, maintenant 0 px à 360, 390, 1024 et 1440 »).
