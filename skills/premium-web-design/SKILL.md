---
name: premium-web-design
description: Direction artistique premium pour un frontend construit sans maquette — langage visuel style Apple (typo massive, whitespace, scroll storytelling), composants 21st.dev, boucle de critique par captures Playwright. Trigger sur "rends ça beau", "style Apple", "design premium", "landing page", "site vitrine", "pas de maquette", "améliore le design", ou tout nouvel écran sans design fourni.
---

# PREMIUM WEB DESIGN SKILL

## WHEN TO USE

- Projet frontend **sans maquette** (pas de Figma / Stitch / screenshot fourni)
- Demande explicite d'un rendu "très beau", "premium", "style Apple", "comme 21st.dev"
- Refonte visuelle d'un écran existant jugé générique

Si un design EXISTE → utiliser `pixel-perfect` (la fidélité prime sur le goût).

Règles de référence : `~/ai-system/rules/design-frontend.md` (§10 Direction artistique)
Workflow complet : `~/ai-system/workflows/frontend-from-scratch.md`

---

## ROLE

Tu es un directeur artistique + frontend engineer senior. Tu fais des **choix assumés**,
tu enlèves plus que tu n'ajoutes, et tu ne livres jamais sans avoir **regardé** le rendu.

---

## BOÎTE À OUTILS — qui fait quoi

| Outil | Rôle | Quand |
|-------|------|-------|
| `impeccable` (plugin) | Cadrage (`init`, `shape`), critique, audit, polish + hook détecteur | Tout projet UI |
| `taste-skill` (design-taste-frontend) | Directions artistiques issues de 247 sites primés + inspecteur navigateur (`scripts/inspect.mjs`) | Landing / site vitrine / portfolio **éditorial** |
| `ui-ux-pro-max` | Base de palettes, pairings de polices, checklist UX | DESIGN.md + revue finale |
| `apple-design` (Emil Kowalski) | Langage Apple traduit pour le web : springs, gestes, matières, typo optique | Style Apple |
| `emil-design-eng` | Philosophie de finition : détails invisibles, composants, décisions de motion | Polish de composants |
| `find-animation-opportunities` → `animate` → `/review-animations` | Workflow motion d'Emil : trouver → implémenter → auditer | Après le layout, avant livraison |
| 21st.dev MCP | Composants de base (hero, pricing, bento…) | Implémentation |
| `motion-framer` | Framer Motion (implémentation) | Toute animation React |

`review-animations` n'est invocable que par l'utilisateur (`/review-animations`) — le demander
explicitement en fin de boucle.

### Conflits entre outils — ordre de priorité

1. **Le `DESIGN.md` gagne.** Chaque choix stylistique assumé (ex : titre en dégradé, eyebrow,
   filets hairline, ombre sur le produit) y est noté avec sa raison.
2. **Accessibilité et performance ne se négocient pas** : contraste AA, reduced-motion,
   propriétés composite-only — un FAIL de ce type se corrige toujours.
3. Les règles de goût des outils (taste-skill, impeccable) sont des **avertissements à défendre**,
   pas des ordres. Le style Apple contredit volontairement certaines règles de taste-skill
   (eyebrow, dégradés, hairlines, peu de photos) : on les garde si le DESIGN.md les assume.
4. Les remarques sur le **sens** (titre qui ne dit pas ce qu'est le produit, vide non intentionnel)
   sont presque toujours justes : les traiter.

Pour l'inspecteur taste-skill : `CHROME_PATH` est défini dans `~/.claude/settings.json`
(Chromium de Playwright) — `node <skill>/scripts/inspect.mjs <url|index.html>`.

---

## PROCESS (obligatoire, dans l'ordre)

### 1. Direction artistique — AVANT tout code

Produire un `DESIGN.md` à la racine du projet frontend :

```md
# Direction artistique
Ambiance : <une phrase — ex: "éditorial sobre, produit au centre, silence visuel">
Références : <3-5 URLs ou noms de sites>
Typo : display=<police>, text=<police>, scale=12/14/16/20/24/32/48/64/96
Couleurs : bg, surface, text, text-muted, border, accent (UNE seule), success/warn/danger
Radius : <ex: 8 / 12 / 20 / full>
Densité : <aérée | standard | dense>
Mouvement : <durées + easing — ex: 200ms cubic-bezier(0.22,1,0.36,1)>
```

Outils pour remplir le `DESIGN.md` :
- `ui-ux-pro-max` — piocher palette, pairing de polices et style dans sa base (161 palettes,
  57 pairings) selon le type de produit
- `/impeccable init` (PRODUCT.md) puis `/impeccable shape` — cadrer le produit, le mode
  (Persuade / Operate / Read / Experience) et la direction avant le code
- `frontend-design` — challenger la direction (éviter le générique)

Si le choix est structurant et ambigu → proposer 2-3 directions à l'utilisateur.

### 2. Maquette rapide (recommandé)

- MCP Stitch : `generate_screen_from_text` puis `generate_variants` → choisir une variante
- Ou `theme-factory` (skill Anthropic) pour un thème de départ
- Puis implémenter la variante choisie avec `pixel-perfect`

### 3. Implémentation avec des briques premium

Ordre de préférence :
1. **shadcn/ui** — base de composants (accessible, tokenisée)
2. **21st.dev MCP** — composants communautaires haut de gamme (hero, pricing, bento, testimonials…) :
   - `search` (gratuit, `type: "component"`) → métadonnées + `previewUrl`
   - Télécharger et **regarder les previews** avant de choisir
   - `get_component` (id) → code source. **Payant / quota** : vérifier `get_usage` d'abord
     (free tier = 2 récupérations/jour, pas de génération IA) — ne récupérer que le composant retenu
   - Adapter le code : tokens du DESIGN.md, contenu propre (jamais les textes/marques de la démo)
3. **Magic UI / Aceternity UI** — effets ciblés (marquee, spotlight, border beam)
4. Animations : skills `animation-designer`, `motion-framer`, `gsap-scrolltrigger`

**Hero section — ordre imposé :**
1. Base du hero = composant **21st.dev** (search → previews → `get_component`), adapté aux tokens
2. Puis animation avec **Framer Motion** (skill `motion-framer`) : reveal en cascade
   (stagger 60-100ms), entrée du visuel produit, parallax / `useScroll` léger, hover/tap sur les CTA
3. `/impeccable animate` pour vérifier que chaque mouvement a un but (pas d'animation décorative)

**Motion sur le reste de la page — workflow Emil Kowalski :**
1. `find-animation-opportunities` — repère où animer (et où ne PAS animer), avec valeurs exactes
2. `animate` — implémente (Framer Motion via `motion-framer` en React)
3. `/review-animations` (à demander à l'utilisateur) — audit strict : timing < 300ms en UI,
   propriétés GPU, reduced-motion, interruptibilité

Tout composant importé est **ré-aligné sur les tokens du DESIGN.md** (couleurs, radius, typo).
Jamais trois styles d'effets différents sur la même page.

### 4. Boucle de critique visuelle (NON optionnelle)

Avec le skill `webapp-testing` (Playwright) :
1. Lancer le serveur dev, capturer chaque écran en **390px, 768px, 1440px** (full page)
2. Regarder les captures (Read sur les PNG)
3. Critiquer selon la grille ci-dessous, corriger
4. Répéter **2 à 3 itérations minimum** avant de livrer
5. Passes Impeccable avant livraison :
   - `/impeccable critique` — revue UX avec scoring heuristique
   - `/impeccable audit` — a11y, perf, responsive
   - `/impeccable polish` — passe finale de finition
   - Si besoin : `bolder` (trop sage), `quieter` (trop chargé), `typeset`, `layout`
6. Pages vitrines : `node <taste-skill>/scripts/inspect.mjs` — traiter les FAIL selon l'ordre
   de priorité ci-dessus
7. `/review-animations` si la page contient de la motion
8. Revue finale `ui-ux-pro-max` (checklist UX / accessibilité)

Le hook Impeccable signale aussi les défauts après chaque édition UI (gradient text, glow,
contraste, dérive du design system). **Le brief gagne** : un effet assumé dans le `DESIGN.md`
(ex : titre en dégradé style Apple) peut être conservé — le noter dans le DESIGN.md pour
ne pas le re-signaler à chaque passe.

Grille de critique :
- Hiérarchie : l'œil sait-il où aller en < 1s ? Un seul élément dominant par section ?
- Espace : sections respirent-elles (≥ 96px desktop entre sections) ?
- Typo : contraste de taille marqué entre titre et corps ? Interlignage correct ?
- Couleur : un seul accent ? gris cohérents ? contraste AA ?
- Alignements : tout sur la même grille ? bords alignés ?
- États : hover, focus visible, loading, empty, error présents ?
- Générique ? Si la page ressemble à un template IA → recommencer l'étape concernée

---

## LANGAGE VISUEL "STYLE APPLE"

S'inspirer du **langage**, jamais copier le site, le logo, les visuels ou les textes d'Apple.

| Élément | Règle |
|---------|-------|
| Titres hero | 56-96px desktop / 40-48px mobile, `font-semibold`, `tracking-tight` (-0.02em à -0.04em), `leading-[1.05]` |
| Police | SF Pro = licence plateformes Apple uniquement → **Inter Display**, **Geist**, ou **Manrope** |
| Palette | Fond `#fbfbfd` / `#000`, texte `#1d1d1f` / `#f5f5f7`, muted `#6e6e73`, **un** accent (ex: bleu `#0071e3`). Bouton plein texte blanc : `#0071e3` (≈4.6:1) — **pas** `#2997ff` (3:1, échoue AA), réservé aux liens sur fond noir |
| Titre hero | Jamais le nom du produit seul : la ligne suivante dit ce que c'est, pour qui |
| Rythme | Une idée par section, section plein écran, beaucoup de vide |
| Images | Le produit / visuel porte la couleur — fond neutre autour |
| Nav | Sticky, `backdrop-blur-xl bg-white/70 dark:bg-black/60`, hauteur 44-52px, bordure 1px très légère |
| Scroll | Storytelling : sections pinnées, reveals au scroll, parallax léger (GSAP ScrollTrigger) |
| Cards | Radius 20-28px, fond `surface` légèrement contrasté, pas d'ombre lourde |
| CTA | Pill (`rounded-full`), un CTA primaire + un lien secondaire "En savoir plus ›" |
| Mouvement | Lent et doux (400-800ms pour les reveals, 150-250ms pour les interactions), respecter `prefers-reduced-motion` |

---

## ANTI-GÉNÉRIQUE — interdits sans justification

- Police par défaut (Inter regular partout, system-ui) sans contraste display/text
- Dégradé violet → bleu en fond de hero
- Plusieurs couleurs d'accent concurrentes
- Ombres noires lourdes (`shadow-2xl` partout)
- Grilles de 3 cards identiques avec icône + titre + texte comme seul pattern
- Lorem ipsum ou texte marketing creux ("Révolutionnez votre workflow")
- Emojis (cf. règle §7 de design-frontend.md)
- Glassmorphism / néons / glow empilés sans direction

---

## OUTPUT

À la livraison, reporter :
1. Le `DESIGN.md` (direction choisie)
2. Les captures finales (chemins) en 3 tailles
3. Ce qui a été corrigé à chaque itération de critique
4. Les composants externes utilisés (21st.dev, Magic UI…) et leur adaptation aux tokens
