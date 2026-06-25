# Next.js — Architecture Rules

## 1. Stack Defaults

- Next.js App Router — Server Components par défaut
- TypeScript `strict: true`
- Tailwind CSS — jamais de style inline statique
- next/font — jamais de CDN Google Fonts
- next/image — jamais de balise `<img>` brute
- Framer Motion pour les animations (si installé)

---

## 2. TypeScript Rules

```ts
// ✅ Toujours typer les props avec une interface dédiée
interface CardProps {
  title: string;
  description?: string;
  className?: string;
}

// ❌ Jamais
const Card = (props: any) => { ... }

// ✅ Utiliser cn() pour les classes conditionnelles
import { cn } from "@/lib/utils";
className={cn("base-class", condition && "conditional-class", className)}

// ❌ Jamais de type assertion hasardeuse
const data = response as unknown as MyType;
```

- `strict: true` dans `tsconfig.json`
- Pas de `any`, pas de `!` non-null assertion sauf cas justifié en commentaire
- Toujours des types explicites sur les retours de fonctions

---

## 3. Tailwind CSS Rules

```tsx
// ✅ Utiliser les tokens définis dans tailwind.config.ts
className="text-primary bg-card rounded-2xl"

// ❌ Jamais de valeur arbitraire si un token existe
className="text-[#FFD600] bg-[#16162a] rounded-[18px]"

// ✅ Valeur arbitraire autorisée uniquement pour des valeurs dynamiques
style={{ animationDelay: `${index * 0.1}s` }}

// ✅ Responsive avec les breakpoints Tailwind
className="text-3xl md:text-5xl lg:text-6xl"
className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3"

// ❌ Jamais de style inline statique
style={{ color: "#FFD600" }}
```

---

## 4. Responsive Design

### Breakpoints
| Breakpoint | Largeur    | Cible                         |
|------------|------------|-------------------------------|
| `default`  | < 640px    | Mobile portrait (prioritaire) |
| `sm`       | ≥ 640px    | Mobile paysage                |
| `md`       | ≥ 768px    | Tablette                      |
| `lg`       | ≥ 1024px   | Desktop                       |
| `xl`       | ≥ 1280px   | Large desktop                 |
| `2xl`      | ≥ 1536px   | Extra large                   |

### Mobile First — toujours

```tsx
// ✅ Mobile first : style de base = mobile, puis agrandir
className="text-3xl md:text-4xl lg:text-6xl"
className="flex-col md:flex-row"
className="grid-cols-1 md:grid-cols-2 xl:grid-cols-3"

// ❌ Desktop first interdit
className="text-6xl md:text-4xl sm:text-3xl"
```

### Typography fluide — clamp sur les titres
```tsx
// ✅ Utiliser clamp via Tailwind ou style pour les titres H1/H2
className="text-[clamp(2.5rem,6vw,5.5rem)]"

// Ou avec variantes Tailwind
className="text-4xl sm:text-5xl lg:text-7xl"
```

### Touch targets (accessibilité mobile)
```tsx
// ✅ Minimum 44x44px sur les éléments cliquables mobile
className="min-h-[44px] min-w-[44px]"

// Boutons full width sur mobile
className="w-full md:w-auto"
```

### Navbar mobile
- Menu hamburger visible sous `md`
- Panel plein écran avec backdrop blur
- Fermeture au clic sur un lien

---

## 5. Framer Motion Rules

```tsx
// ✅ Scroll reveal standard — viewport once:true pour éviter les re-animations
const fadeUp = {
  hidden: { opacity: 0, y: 30 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: "easeOut" } },
};

<motion.div
  variants={fadeUp}
  initial="hidden"
  whileInView="visible"
  viewport={{ once: true, margin: "-40px" }}
>

// ✅ Stagger sur les listes de cards
const container = {
  hidden: {},
  visible: { transition: { staggerChildren: 0.1 } },
};

// ✅ Hover lift sur les cards
whileHover={{ y: -6, transition: { duration: 0.3 } }}

// ❌ Jamais d'animation qui bloque le rendu initial
// ❌ Pas d'animation JS sur les éléments above the fold
//    → utiliser CSS animation-delay à la place
```

### "use client" obligatoire avec Framer Motion
```tsx
"use client";
import { motion } from "framer-motion";
```

---

## 6. Semantic HTML

```tsx
// ✅ Structure obligatoire
<header>   → Navbar
<main>     → contient toutes les sections
<section>  → chaque section avec id pour ancre
<footer>   → Footer
<nav>      → liste de liens de navigation
<h1>       → une seule fois par page
<h2>       → titre de chaque section
<h3>       → titres de cards

// ✅ IDs de section pour les ancres navbar
<section id="about">
<section id="features">
```

---

## 7. SEO

```tsx
// app/layout.tsx — metadata complète obligatoire
export const metadata: Metadata = {
  title: "Titre — Description courte",
  description: "...",
  keywords: [...],
  openGraph: { title, description, type, locale },
  twitter: { card: "summary_large_image", ... },
  robots: { index: true, follow: true },
  authors: [{ name: "..." }],
  viewport: "width=device-width, initial-scale=1",
};
```

---

## 8. Accessibility

```tsx
// ✅ Liens externes
<a target="_blank" rel="noopener noreferrer" aria-label="Description (nouvelle fenêtre)">

// ✅ Boutons sans texte visible
<button aria-label="Ouvrir le menu" aria-expanded={menuOpen}>

// ✅ Images avec alt descriptif
<Image src="..." alt="Description utile de l'image" />

// ✅ Focus visible — ne jamais supprimer outline
// :focus-visible { outline: 2px solid var(--primary); outline-offset: 4px; }

// ✅ Contraste — ratio minimum 4.5:1 pour le texte normal

// ✅ Skip link en haut de page
<a href="#main-content" className="sr-only focus:not-sr-only">
  Aller au contenu principal
</a>
```

---

## 9. Performance

```tsx
// ✅ next/image obligatoire — jamais de <img>
import Image from "next/image";
<Image src="/images/logo.png" alt="..." width={120} height={40} priority />
// priority={true} uniquement pour les images above the fold

// ✅ next/font — jamais de Google Fonts CDN
import { Inter } from "next/font/google";

// ✅ Server Components par défaut = pas de JS inutile côté client

// ✅ "use client" uniquement si :
// - useState / useEffect
// - Framer Motion
// - Event listeners
// - Browser APIs

// ❌ Jamais "use client" sur un composant purement statique
```

---

## 10. Naming Conventions

| Élément              | Convention         | Exemple                        |
|----------------------|--------------------|--------------------------------|
| Composants React     | PascalCase         | `HeroSection.tsx`              |
| Fonctions/variables  | camelCase          | `handleScrollReveal`           |
| Constantes           | SCREAMING_SNAKE    | `API_URL`                      |
| Fichiers non-compo.  | kebab-case         | `use-scroll-reveal.ts`         |
| CSS classes custom   | kebab-case         | `.section-header`              |
| IDs HTML             | kebab-case         | `id="cta-banner"`              |

---
*Elisee ASSINOU*
