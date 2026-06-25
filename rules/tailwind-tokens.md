# Tailwind Design Tokens — Architecture Rules

## 1. Principe

Les design tokens (couleurs, spacing, radius, typographie) sont extraits du Figma et définis en **deux endroits** — jamais codés en dur dans les composants.

---

## 2. CSS Variables dans `globals.css`

```css
:root {
  /* Couleurs — valeurs exactes du Figma */
  --color-bg:       #...;
  --color-surface:  #...;
  --color-primary:  #...;
  --color-text:     #...;
  --color-muted:    #...;
  --color-border:   #...;

  /* Spacing */
  --section-px:     6%;
  --section-py:     100px;

  /* Border radius */
  --radius-sm:      /* valeur Figma */;
  --radius-md:      /* valeur Figma */;
  --radius-lg:      /* valeur Figma */;
}
```

---

## 3. Extension dans `tailwind.config.ts`

```ts
theme: {
  extend: {
    colors: {
      // Mapper chaque couleur Figma vers un token sémantique
      bg:      "var(--color-bg)",
      surface: "var(--color-surface)",
      primary: "var(--color-primary)",
      // ...
    },
    fontFamily: {
      sans:    ["var(--font-body)"],
      display: ["var(--font-heading)"],
    },
    borderRadius: {
      sm: "var(--radius-sm)",
      md: "var(--radius-md)",
      lg: "var(--radius-lg)",
    },
    // Animations custom si nécessaire
  }
}
```

---

## 4. Règles d'usage

- **Toujours utiliser les tokens** : `className="text-primary bg-surface"`, jamais `text-[#FFD600]`
- **Valeurs arbitraires Tailwind** autorisées uniquement pour des valeurs dynamiques ou absentes du design system
- **Un seul fichier source** pour les tokens (globals.css) — ne pas dupliquer les valeurs dans les composants
- **Extraire les tokens du Figma en premier** avant de coder un composant
- **Nommer sémantiquement** : `--color-primary` et non `--color-blue`
