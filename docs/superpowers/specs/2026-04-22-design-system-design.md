# O Árbitro — Design System Spec
**Date:** 2026-04-22  
**Status:** Approved  
**Stack:** Flutter (iOS + Android) + Firebase

---

## 1. Brand Identity

**Name:** O Árbitro  
**Tagline:** O destino decide.  
**Market:** PT-PT, Margem Sul / Setúbal district, ages 18–35  
**Personality:** Casino-lite energy, social and irreverent, premium enough to share on Instagram  
**Reference:** Packdraw aesthetic adapted for the EU/PT market — dark, high-contrast, gamified but not sleazy

---

## 2. Colour Palette

### Base

| Token | Hex | Usage |
|---|---|---|
| `color-bg-primary` | `#0d0d1a` | App background |
| `color-surface` | `#13132a` | Card/panel base |
| `color-surface-2` | `#1e1e3a` | Elevated surfaces, inputs |
| `color-border` | `rgba(168,85,247,0.2)` | Glass card borders |

### Brand

| Token | Hex | Usage |
|---|---|---|
| `color-purple` | `#7c3aed` | Primary brand, gradient start |
| `color-purple-light` | `#a855f7` | Labels, icons, hover states |
| `color-pink` | `#ec4899` | Gradient end, accent, CTA highlight |

### Semantic

| Token | Hex | Usage |
|---|---|---|
| `color-gold` | `#f59e0b` | Rare outcomes, premium tier, Golden Contracts |
| `color-success` | `#10b981` | Win states, confirmations |
| `color-danger` | `#ef4444` | Loss states, destructive actions |

### Text

| Token | Value | Usage |
|---|---|---|
| `color-text-primary` | `#ffffff` | Headings, primary content |
| `color-text-muted` | `#a0a0c0` | Secondary text, descriptions |
| `color-text-disabled` | `#555577` | Placeholder, inactive |

### Gradients

| Name | Value | Usage |
|---|---|---|
| `gradient-primary` | `linear-gradient(135deg, #7c3aed, #ec4899)` | CTA buttons, featured highlights |
| `gradient-glass-bg` | `rgba(124,58,237,0.08)` | Glass card fill |
| `gradient-gold` | `linear-gradient(135deg, #f59e0b, #fbbf24)` | Premium/rare item reveals |

---

## 3. Typography

**Font stack:** Google Fonts (free, no license cost)

### Type Scale

| Role | Font | Weight | Size | Usage |
|---|---|---|---|---|
| Display | Syne | 800 | 28–40sp | Screen titles, module names, spin reveals |
| Heading | Syne | 700 | 18–22sp | Section headers, card titles |
| Body | Space Grotesk | 500 | 14–16sp | Descriptions, contract text |
| Body Strong | Space Grotesk | 700 | 14sp | Emphasized body content |
| Label | Space Grotesk | 700 | 10–12sp, uppercase, 1.5px tracking | Tags, badges, metadata |
| Caption | Space Grotesk | 400 | 11sp | Helper text, timestamps |
| Button | Space Grotesk | 700 | 13–15sp | All button labels |

### Rules
- Display text is always Syne 800, never all-caps programmatically (set naturally in copy)
- Labels and badges use uppercase + letter-spacing only, never display font
- Minimum body size: 12sp (accessibility floor)
- Line height: 1.1 for display, 1.4 for body

---

## 4. Component Library

### 4.1 Buttons

**Primary (CTA)**
- Shape: pill (`border-radius: 100px`)
- Background: `gradient-primary`
- Text: white, Space Grotesk 700, 14sp
- Padding: `12px 28px`
- Usage: GIRAR, CONFIRMAR, CRIAR APOSTA

**Secondary (Outline Glass)**
- Shape: pill
- Background: `rgba(124,58,237,0.15)`
- Border: `1px solid rgba(168,85,247,0.3)`
- Text: `color-purple-light`
- Usage: VETO, VER DETALHES

**Ghost**
- Background: `color-surface-2`
- Text: `color-text-muted`
- Usage: CANCELAR, FECHAR

**Destructive**
- Background: `rgba(239,68,68,0.15)`
- Border: `1px solid rgba(239,68,68,0.3)`
- Text: `#ef4444`
- Usage: RECUSAR APOSTA, ABANDONAR

**States:** all buttons have `opacity: 0.5` when disabled, `scale(0.97)` on press

### 4.2 Glass Cards

The primary surface for all module cards, consequence items, and contract previews.

```
background: rgba(124,58,237,0.08)
border: 1px solid rgba(168,85,247,0.2)
border-radius: 12px
backdrop-filter: blur(8px)
```

**Variants:**
- **Default** — as above
- **Highlighted** — border: `1px solid rgba(168,85,247,0.5)`, box-shadow: `0 0 20px rgba(124,58,237,0.2)`
- **Gold (rare)** — border: `1px solid rgba(245,158,11,0.4)`, box-shadow: `0 0 20px rgba(245,158,11,0.15)`
- **Danger** — border: `1px solid rgba(239,68,68,0.3)`

### 4.3 Tags / Badges

```
background: rgba(168,85,247,0.2)
color: #a855f7
font: Space Grotesk 700, 10sp, uppercase, 1.5px tracking
padding: 3px 8px
border-radius: 20px
```

Special variants: `EM DESTAQUE` (purple), `POPULAR` (pink), `NOVO` (green), `RARO` (gold)

### 4.4 Bottom Navigation

4 tabs: Lobby · Social Slots · Roleta · Ledger  
Active tab: `color-purple-light` icon + label  
Inactive: `color-text-disabled`  
Background: `color-surface` with `border-top: 1px solid color-border`

### 4.5 Input Fields

```
background: color-surface-2
border: 1px solid color-border
border-radius: 10px
color: color-text-primary
font: Space Grotesk 500, 14sp
padding: 12px 16px
```

Focus state: border `color-purple-light`, box-shadow `0 0 0 3px rgba(168,85,247,0.15)`

### 4.6 Modals / Bottom Sheets

- Background: `color-surface`
- Top handle: `4px × 36px`, `color-surface-2`, `border-radius: 2px`
- Border-radius top: `20px`
- Overlay: `rgba(0,0,0,0.7)` with blur

---

## 5. Lobby Screen Layout

**Pattern:** Grid Destacado

```
┌─────────────────────────────────┐
│  App Bar: Logo + Avatar/Balance │
├─────────────────────────────────┤
│                                 │
│   [Featured Module — Full Width]│
│   Social Slots (rotating daily) │
│                                 │
├──────────────┬──────────────────┤
│  Roleta do   │  Absurdity       │
│  Destino     │  Ledger          │
├──────────────┴──────────────────┤
│  Active Bets Strip (if any)     │
└─────────────────────────────────┘
```

- Featured module rotates (can be any of the three)
- Active Bets strip shows count + quick-access CTA
- All cells are Glass Cards with Highlighted variant for featured

---

## 6. Motion & Animation

- **Micro-interactions:** `200ms ease-out` for button press, card hover, tab switch
- **Screen transitions:** Shared element transitions (Flutter Hero widget) between lobby and module screens
- **Roulette spin:** Physics-based deceleration curve, minimum 3 full rotations before stop
- **Slot machine:** Reel-by-reel reveal with 150ms stagger between reels
- **Win reveal:** Gold glow pulse — `box-shadow` expands and fades over `600ms`
- **Contract seal:** Lottie animation for Golden Contract wax seal stamp
- **Engine:** Flutter's built-in animation framework + Rive for slot/roulette assets

---

## 7. Iconography

- **Style:** Rounded, filled — consistent with the soft glass aesthetic
- **Library:** Flutter's `lucide_icons` or `phosphor_flutter` package
- **Module icons:** Custom illustrated emoji-style icons for the three modules (🎰 🎡 📜 as placeholders for MVP)
- **Size:** 24sp UI icons, 32sp module cards, 48sp featured module

---

## 8. Spacing & Layout

| Token | Value |
|---|---|
| `space-xs` | 4px |
| `space-sm` | 8px |
| `space-md` | 12px |
| `space-lg` | 16px |
| `space-xl` | 24px |
| `space-2xl` | 32px |

- Screen horizontal padding: `space-lg` (16px) on all sides
- Card internal padding: `space-md` (12px) to `space-lg` (16px)
- Section gaps: `space-xl` (24px)

---

## 9. Rarity Tier System (Slot Machine & Consequences)

Used in Module A (Social Slots) to colour-code consequence intensity:

| Tier | Colour | Border | Label |
|---|---|---|---|
| Casual | `#6b7280` (grey) | grey glass | CASUAL |
| Ousado | `#3b82f6` (blue) | blue glass | OUSADO |
| Épico | `#a855f7` (purple) | purple glass | ÉPICO |
| Lendário | `#f59e0b` (gold) | gold glass + glow | LENDÁRIO |

---

## 10. Dark Mode

The app is **dark-mode only**. No light mode. This is intentional — the glassmorphism and neon palette require a dark background to function correctly. System light/dark preference is ignored.

---

## 11. Assets & Fonts (Flutter pubspec)

```yaml
fonts:
  - family: Syne
    fonts:
      - asset: assets/fonts/Syne-Bold.ttf
        weight: 700
      - asset: assets/fonts/Syne-ExtraBold.ttf
        weight: 800
  - family: SpaceGrotesk
    fonts:
      - asset: assets/fonts/SpaceGrotesk-Regular.ttf
        weight: 400
      - asset: assets/fonts/SpaceGrotesk-Medium.ttf
        weight: 500
      - asset: assets/fonts/SpaceGrotesk-Bold.ttf
        weight: 700

dependencies:
  rive: ^0.12.0          # slot + roulette animations
  firebase_core: ^2.x
  firebase_auth: ^4.x
  cloud_firestore: ^4.x
  phosphor_flutter: ^2.x  # iconography
```
