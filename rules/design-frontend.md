# Design Frontend — Règles d'Implémentation Visuelle

Règle **transversale** (Next.js, React, Flutter) sur la qualité visuelle : responsivité,
pixel-perfect, MCP design (Stitch/Figma), design tokens, accessibilité.

Complète les règles d'architecture (`frontend.md`, `nextjs.md`, `flutter.md`).
Elle répond AU design ; les règles d'architecture répondent à la structure.

---

## 1. Fondamentaux — l'ordre d'implémentation d'un écran

Avant d'écrire UN pixel d'UI, l'agent DOIT :

1. **Lire le design** (source de vérité) — dans l'ordre de priorité :
   1. Le skill `pixel-perfect` (chargé si Figma/screenshot/design system)
   2. Les exports Stitch locaux : `<screen>/code.html` (layout) + `<screen>/screen.png` (rendu) + `DESIGN.md` (tokens)
   3. Les specs Figma via `use_figma` (figma-developer-mcp)
   4. Le `CLAUDE.md` du projet (mapping écran ↔ module)
2. **Extraire les tokens** (couleurs, spacing, radius, typo) du design → les placer dans le theme/tokens AVANT de coder (jamais en dur dans le widget/composant)
3. **Recenser les composants réutilisables** du design (boutons, cards, inputs, badges…)
4. **Se poser la question responsivité** pour chaque écran (voir §2)
5. **Puis seulement implémenter** (composer depuis shared/ui, jamais tout en dur)

> Si le design a un `DESIGN.md` ou un fichier tokens (ex: `README.md` Stitch), le lire
> **en intégralité** avant de coder. C'est la référence.

---

## 2. Responsivité — mobile-first, toujours

### Mobile-first === priorité au mobile, on agrandit ensuite

- Le style de **base** = mobile (petit écran). On élargit avec les breakpoints.
- **Jamais** "desktop-first" (définir desktop puis rétrécir) sauf impératif métier justifié.

### Breakpoints standard

| Breakpoint | Largeur    | Cible                         |
|------------|------------|-------------------------------|
| `base`     | < 640px    | Mobile portrait (prioritaire) |
| `sm`       | ≥ 640px    | Mobile paysage                |
| `md`       | ≥ 768px    | Tablette                      |
| `lg`       | ≥ 1024px   | Desktop                       |
| `xl`       | ≥ 1280px   | Large desktop                 |
| `2xl`      | ≥ 1536px   | Extra large                   |

### Tailwind / React — mobile-first

```tsx
// ✅ Mobile : 1 colonne → md : 2 → lg : 3
className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3"
// ✅ Taille texte qui grandit
className="text-3xl md:text-4xl lg:text-6xl"
// ❌ Desktop-first interdit
className="text-6xl md:text-4xl sm:text-3xl"
```

### Flutter — adaptatif

- Utiliser `LayoutBuilder`, `MediaQuery` / `Breakpoint`, `GridView` responsive, `CustomScrollView`.
- Pour chaque écran mobile, vérifier qu'il tient entre 320px (petit) et 430px (pro) sans
  overflow ni débordement horizontal.
- Composants réutilisables : `shared/widgets/` avec comportement adaptatif.

### Checklist responsivité (à passer AVANT de livrer)

- [ ] Aucun débordement horizontal sur écran 320px
- [ ] Colonnes/grilles s'empilent correctement en mobile
- [ ] Touch targets ≥ 44×44px (mobile)
- [ ] Textes lisibles sans zoom (pas de texte écrasé)
- [ ] Images/logos ne dépassent pas le viewport
- [ ] Boutons principaux full-width en mobile si pertinent

---

## 3. Pixel-perfect — fidélité au design

### Principe

L'UI générée doit **reproduire le design de référence** (Figma / Stitch / screenshot) le plus
fidèlement possible : mêmes espacements, tailles, couleurs, radius, typographies, ombres.

### Règles

- **Extraire les valeurs EXACTES** du design (spacing, radius, couleurs, font sizes) — pas
  des approximations "au feeling".
- **Jamais de valeur magique inventée** si le design donne la valeur. Si une valeur manque,
  l'inférer cohérente avec le système de tokens, ne pas inventer un style divergent.
- **Espacements** : utiliser la grille de spacing du design (4/8/12/16/24…), pas des valeurs
  arbitraires aléatoires.
- **Typographie** : respecter la scale (titres, corps, caption) et la graisse du design.
- **Ombres / elevation / blur** : reproduire les valeurs (pas de blur/sombre au hasard).
- En cas d'**écart** impossible à reproduire (design non-fourni, valeur absente) : utiliser
  le bon sens + tokens cohérents, et le **signaler** plutôt que de deviner silencieusement.

---

## 4. MCP design — Stitch & Figma

### Stitch (exports locaux)

- Chemin type : `~/Downloads/stitch_<projet>/<screen_name>/`
  - `code.html` → layout Tailwind avec specs exactes
  - `screen.png` → rendu visuel
  - `DESIGN.md` (ou similaire) → design tokens
- Pour un composant/écran demandé : **aller lire le dossier du screen** correspondant et
  extraire layout + tokens + rendu AVANT de coder.

### Figma

- Utiliser `use_figma` (figma-developer-mcp) pour extraire : dimensions, couleurs, spacing,
  typography, assets, auto-layout.
- Charger le skill `figma-use` avant tout appel `use_figma` (prérequis MANDATORY).
- Fichier Figma par projet indiqué dans `CLAUDE.md` ou config MCP.

### Si aucun design fourni

- Écrans existants avec un design system en place → l'appliquer (tokens), en cohérence.
- Sinon (nouveau projet / nouvel écran sans maquette) → suivre
  `workflows/frontend-from-scratch.md` avec le skill `premium-web-design` :
  direction artistique (`DESIGN.md`) → maquettes Stitch → implémentation → critique par captures.
- Poser une question à l'utilisateur si plusieurs directions visuelles sont plausibles.

---

## 5. Design tokens — un seul point de vérité

### Principe

Les couleurs, spacing, radius, typographies sont définis **une seule fois** dans le système
de tokens du projet — jamais codés en dur dans les widgets/composants.

### React / Next.js (Tailwind)

```css
:root {
  --color-bg:      #…;   /* valeur EXACTE du design */
  --color-primary: #…;
  --radius-md:     …;
  --font-heading:  …;
}
```
Puis mapper dans `tailwind.config.ts` → utiliser `text-primary`, `bg-surface`, `rounded-md`.
**Jamais** `text-[#FFD600]` si un token existe.

### Flutter

- `core/theme/app_colors.dart`, `app_text_styles.dart`, et éventuellement
  `app_spacing.dart`, `app_radius.dart`.
- Utiliser les constantes du theme, **jamais** de `Color(0x…)` dispersé dans les screens.

### Règle

- Toujours utiliser les tokens. Valeur brute autorisée UNIQUEMENT si absente du design system.
- Ne pas dupliquer les valeurs (un seul fichier source de vérité).

---

## 6. Accessibilité

Ces règles s'appliquent à tout le code frontend/mobile. Elles ne sont pas optionnelles.

### React / web

- Contraste texte normal ≥ 4.5:1 (WCAG AA)
- `aria-label` sur les boutons sans texte visible, `aria-expanded` sur les menus
- `alt` descriptif sur toutes les images
- Focus visible conservé (jamais `outline: none` sans alternative)
- Skip link pour accéder au contenu
- HTML sémantique (`header`, `main`, `section`, `nav`, `footer`, un seul `h1`)

### Flutter

- Utiliser les widgets sémantiques (`Semantics`, `Tooltip`, labels d'accessibilité)
- `TextScaler` / media query pour gérer les grandes tailles de police système
- Touch targets ≥ 48dp sur mobile
- Contraste suffisant dans le theme

---

## 7. Icônes — zéro emoji dans le code frontend

### Règle absolue

**Aucun emoji ne doit apparaître dans le code frontend** (ni dans les composants, ni dans les
textes, ni dans les tooltips, ni dans les labels). Utiliser systématiquement des **icônes
vectorielles** issues d'une lib d'icônes dédiée.

### Pourquoi

- Les emojis ne sont **pas fiables** : rendu variable selon OS/device, pas de controlleur
  de taille/graisse/couleur, inaccessibles (pas d'aria-label natif), moche en production.
- Une icône vectorielle = même rendu partout, tailable, colorable, accessible.

### React / Next.js (Tailwind)

- **Lucide React** (recommandé) : `<Icon className="w-5 h-5 text-primary" />`
- Autres options valides : Heroicons (`@heroicons/react`), Phosphor Icons
- **Jamais** `<span>🔥</span>` ou `🔥` dans du JSX
- **Jamais** de string contenant un emoji rendue dans l'UI

```tsx
// ❌ Jamais
<span>🔥 Populaire</span>
<button>✅ Valider</button>

// ✅ Toujours
<Flame className="w-4 h-4 text-orange-500" />
<CheckCircle className="w-5 h-5 text-green-500" />
```

### Flutter

- **`flutter_svg`** avec des icônes SVG du design system OU
- **`Icons`** de Material (`Icons.check_circle`, `Icons.flame`)
- **Jamais** de `Text('🔥')` ou d'emoji dans un widget

```dart
// ❌ Jamais
Text('🔥 Populaire')
Icon(Icons.check)  // ✅ Material icon OK
SvgPicture.asset('assets/icons/flame.svg')  // ✅ SVG custom OK
```

### Bibliothèques d'icônes recommandées

| Stack | Lib | Usage |
|-------|-----|-------|
| React/Next.js | `lucide-react` | `<Icon className="..." />` |
| React/Next.js | `@heroicons/react/24/outline` | `<HeroIcon className="..." />` |
| React/Next.js | `@phosphor-icons/react` | `<PhIcon className="..." />` |
| Flutter | `flutter_svg` (SVG custom) | `SvgPicture.asset(...)` |
| Flutter | Material `Icons` | `Icon(Icons.xxx)` |
| Flutter | Phosphor Icons Flutter | `PhosphorIcons.xxx` |

### Règle de consistance

- Un seul choix d'icônes par projet (ne pas mélanger Lucide + Heroicons + emoji)
- Les icônes suivent les design tokens (couleur, taille) — pas de style custom
- Les icônes décoratives ont `aria-hidden="true"`, les icônes fonctionnelles ont `aria-label`

---

## 8. Checklist finale avant de livrer un écran/composant

L'agent DOIT vérifier (et reporter) :

- [ ] Le design a été lu (source de vérité identifiée) — pas d'UI inventée à l'aveugle
- [ ] Tokens extraits du design AVANT le code, pas de couleur/kadre en dur
- [ ] Responsif — testé mobile (320-430px) + tablette + desktop, sans overflow
- [ ] Fidèle au design (spacing, typo, radius, ombres corrects)
- [ ] Composants réutilisables extraits dans shared/ui (pas de duplication)
- [ ] Accessible (contraste, labels, focus / sémantique)
- [ ] Zéro emoji — toutes les icônes sont vectorielles (Lucide/Heroicons/Material/SVG)
- [ ] Architecture respectée (pas de business logic dans l'UI — cf. règles d'archi)

Toute valeur non-fournie par le design et devinée doit être **signalée**, pas masquée.

---

## 9. Interactions & animation (l'accent du design)

- Reproduire les états : hover, active, pressed, disabled, loading (skeleton), empty, error.
- Animations si le design l'exige (Framer Motion / Flutter animations) — cf. skills
  `animation-designer`, `motion-framer`, `gsap-scrolltrigger`.
- Micro-interactions de feedback (bouton qui valide, écran de chargement) cohérentes avec
  le style.
- Ajouter les états **empty / error / loading** même si le design ne les montre pas —
  c'est la qualité pro que le code doit garantir.

---

## 10. Direction artistique & anti-générique (sans maquette)

S'applique quand aucun design n'est fourni. Détails : skill `premium-web-design`.

### Exigé

- Un `DESIGN.md` écrit AVANT le code (ambiance, références, typo, palette, radius, mouvement)
- 3-5 références visuelles réelles identifiées
- Typo : une police display + une police texte, scale stricte, contraste de taille marqué
- Couleur : neutres cohérents + **un seul** accent + couleurs sémantiques
- Espace : grille 4/8, sections aérées (≥ 96px desktop entre sections)
- Tous les états (hover, focus, loading, empty, error)
- Boucle de critique par captures (390 / 768 / 1440px) — 2-3 itérations minimum

### Interdit sans justification

- Police par défaut sans hiérarchie, dégradé violet → bleu, plusieurs accents
- Ombres lourdes partout, grilles de 3 cards identiques comme seul pattern
- Lorem ipsum, texte marketing creux, effets empilés (glass + glow + néon)
- Copier un site existant (logo, visuels, textes) — s'inspirer du langage, pas cloner

---
*Elisee ASSINOU*
