# Workflow — Frontend sans maquette (design from scratch)

Utilise ce workflow quand tu dois construire le frontend **toi-même, sans design fourni**
(pas de Figma, pas d'export Stitch, pas de screenshot). Objectif : un rendu premium,
pas un template IA générique.

Complète `new-frontend-workflow.md` (architecture) — celui-ci couvre le **visuel**.
Règle de référence : `rules/design-frontend.md` §10.

## Phase 0 : Initialisation

```bash
.agent/workflow/scribe/scribe tenor-init --type cli
.agent/workflow/scribe/scribe-rag challenge "design from scratch <projet>"
```

Charger le skill `premium-web-design`.

## Phase 1 : Direction artistique

1. Identifier le type de produit et la cible (SaaS, vitrine, dashboard, e-commerce…)
2. Rassembler 3-5 références (Godly, Land-book, Mobbin, Refero, 21st.dev, sites produits)
3. `/impeccable init` (PRODUCT.md) + `/impeccable shape` → cadrer produit, mode et direction
4. `ui-ux-pro-max` → palette, pairing de polices, style selon le type de produit
   Site vitrine éditorial : `taste-skill` (`scripts/draw.mjs`) pour tirer une direction issue de sites primés
   Style Apple : `apple-design`
5. Skill `frontend-design` → challenger les choix (anti-générique)
6. Écrire `DESIGN.md` (ambiance, typo, palette, radius, densité, mouvement)
7. Si plusieurs directions plausibles → proposer 2-3 options à l'utilisateur, il tranche

## Phase 2 : Maquettes

1. MCP Stitch : `create_project` → `generate_screen_from_text` (écran clé, souvent la home)
2. `generate_variants` → 3 variantes → choix avec l'utilisateur
3. `create_design_system_from_design_md` pour aligner Stitch sur le `DESIGN.md`
4. Générer les autres écrans clés avec le design system appliqué

Alternative rapide : skill `theme-factory` pour un thème de départ.

## Phase 3 : Fondation

1. Tokens (`rules/tailwind-tokens.md`) : couleurs, typo, spacing, radius, shadows, motion
2. Polices chargées via `next/font` (display + text)
3. shadcn/ui initialisé, composants re-thémés sur les tokens
4. Mode sombre défini comme un thème à part entière (pas une inversion)

## Phase 4 : Implémentation

1. Skill `pixel-perfect` sur chaque écran Stitch choisi
2. **Hero** : composant 21st.dev (search → previews → `get_component`) adapté aux tokens,
   puis animé avec **Framer Motion** (`motion-framer`)
3. Autres sections premium via 21st.dev, ré-alignées sur les tokens
4. Animations : `motion-framer` (reveals, micro-interactions), `gsap-scrolltrigger` (scroll storytelling),
   validées par `/impeccable animate`
   Workflow motion : `find-animation-opportunities` → `animate` → `/review-animations`
5. États systématiques : hover, focus visible, loading (skeleton), empty, error
6. Contenu réaliste (pas de lorem ipsum) ; visuels via `nano-banana` / `canvas-design` si besoin

## Phase 5 : Boucle de critique visuelle

Skill `webapp-testing` (Playwright) :

1. Captures full page en 390px / 768px / 1440px, clair + sombre
2. Lire les captures, appliquer la grille de critique du skill `premium-web-design`
3. Corriger → recapturer — **2 à 3 itérations minimum**
4. `/impeccable critique` → `/impeccable audit` → `/impeccable polish`
   Pages vitrines : inspecteur `taste-skill` (`scripts/inspect.mjs`) — conflits arbitrés par le DESIGN.md
   Motion : `/review-animations`
5. Revue finale avec `ui-ux-pro-max` (accessibilité, contraste, UX)

## Phase 6 : Livraison

1. Checklist §8 de `rules/design-frontend.md`
2. **code-quality-reviewer** — architecture + qualité
3. SCRIBE : **GHOST** pour la direction artistique retenue (et pourquoi)
4. **git-workflow-specialist** — commit + push
