# Prompts Stitch — Écrans Auth

## Palette exacte du design actuel

```json
{
  "background": "#faf9ff",
  "surface": "#faf9ff",
  "surface-container": "#e9edff",
  "surface-container-low": "#f1f3ff",
  "on-surface": "#051a3e",
  "on-surface-variant": "#434652",
  "primary": "#00296d",
  "on-primary": "#ffffff",
  "primary-container": "#003d9b",
  "on-primary-container": "#91afff",
  "secondary": "#0050cd",
  "secondary-container": "#0966ff",
  "on-secondary-container": "#f9f7ff",
  "outline": "#747783",
  "outline-variant": "#c4c6d4",
  "success-green": "#22c55e",
  "error-red": "#ba1a1a"
}
```

**Typo :** Hanken Grotesk (titres), Inter (corps), JetBrains Mono (labels)
**Style :** Glassmorphic-Corporate — pill-shaped (boutons/inputs arrondis), backdrop-blur, ombres douces, fond clair #faf9ff

---

## Prompt 1 — Écran Connexion

> Crée un écran de connexion mobile pour l'app "FORYOU" (VTC + livraison Bénin). Design glassmorphic-corporate, fond clair (#faf9ff), surface-container (#e9edff) pour les inputs, primary (#00296d) pour les actions, primary-container (#003d9b) pour les accents, success-green (#22c55e) pour les statuts. Polices : Hanken Grotesk (titres), Inter (corps), JetBrains Mono (labels). Boutons et inputs pill-shaped (arrondis complets). Style général : fin, aérien, beaucoup de backdrop-blur et d'ombres douces.
>
> **Éléments :**
> - En haut : logo ou badge "FORYOU" + tagline "Votre trajet, notre priorité" en on-surface-variant (#434652)
> - Champ "Numéro de téléphone" : fond surface-container-low (#f1f3ff), bordure outline-variant (#c4c6d4), indicatif +229 pré-rempli en début de champ, icône téléphone à gauche
> - Champ "Mot de passe" : même style, icône cadenas à gauche, œil à droite pour afficher/masquer
> - Lien "Mot de passe oublié ?" en secondary (#0050cd), aligné à droite
> - Bouton "Se connecter" : fond primary (#00296d), texte blanc, pill-shaped, ombre douce primary/20
> - Texte "Ou" avec lignes horizontales de part et d'autre
> - Texte "Pas encore de compte ?" + lien "Créer un compte" en secondary (#0050cd)
> - Le tout centré dans un container max-w-[430px], padding mobile 16px
>
> Export en Tailwind HTML, même format que les autres screens FORYOU.

---

## Prompt 2 — Écran Inscription

> Crée un écran d'inscription mobile pour l'app "FORYOU" (VTC + livraison Bénin). Design glassmorphic-corporate, fond clair (#faf9ff), surface-container (#e9edff) pour les inputs, primary (#00296d) pour les actions, primary-container (#003d9b) pour les accents. Polices : Hanken Grotesk (titres), Inter (corps), JetBrains Mono (labels). Boutons et inputs pill-shaped. Formulaire scrollable en une colonne dans un container max-w-[430px], padding mobile 16px.
>
> **Éléments :**
> - Titre "Créer un compte" (Hanken Grotesk, #00296d) + sous-titre "Remplissez vos informations" (Inter, #434652)
> - Champ "Numéro de téléphone" : fond surface-container-low (#f1f3ff), icône téléphone à gauche, badge vert "Vérifié" (success-green #22c55e) à droite (verrouillé, modification désactivée)
> - Deux colonnes côte à côte : champ "Prénom" | champ "Nom"
> - Sélecteur de genre : deux boutons "Masculin" / "Féminin" en forme de pills, l'actif en primary (#00296d) avec texte blanc, l'inactif en outline-variant (#c4c6d4)
> - Champ "Email" (optionnel) : icône envelope à gauche
> - Champ "Mot de passe" : icône cadenas à gauche + œil à droite + barre d'indicateur de force sous le champ (faible=rouge, moyen=orange, fort=success-green)
> - Champ "Code de parrainage" (optionnel) : icône gift à gauche
> - Section "Adresse" avec tiret "Adresse de résidence" en Hanken Grotesk small :
>   - Champ "Ville" (ex: Cotonou)
>   - Champ "Quartier" (ex: Akpakpa)
>   - Champ "Rue" (optionnel)
>   - Champ "Complément d'adresse" (optionnel)
> - Bouton "S'inscrire" : fond primary (#00296d), texte blanc, pill-shaped, large, ombre douce
> - Texte "Déjà un compte ?" + lien "Se connecter" en secondary (#0050cd)
>
> Champs de formulaire : fond #f1f3ff, bordure #c4c6d4, rounded-full, padding 16px.
>
> Export en Tailwind HTML, même format que les autres screens FORYOU.

---
*Elisee ASSINOU*
