# O Árbitro — Game Mechanics Design Spec
**Date:** 2026-04-23
**Status:** Approved
**Stack:** Flutter (iOS + Android), pure local state (no backend)

---

## 1. Overview

O Árbitro is a local party game for 2–8 players sharing one device. Three games share a single session with a common player list. No accounts, no persistence — session resets when the app closes.

---

## 2. Session Model

A session is created once per party and shared across all three games.

```
Session
├── players: List<Player>
├── slotsHistory: List<SpinResult>
├── rouletteHistory: List<RouletteResult>
└── ledgerEntries: List<LedgerEntry>

Player
├── name: String
├── vetoTokens: int (default: 2)
└── daresCompleted: int (default: 0)
```

### Session Lifecycle

1. Lobby shows **"INICIAR SESSÃO"** button when no session is active — all game tabs are locked.
2. Tapping opens a bottom sheet for player setup (add names, min 2 max 8).
3. Confirming creates the session and unlocks all tabs.
4. **"NOVA SESSÃO"** button in lobby resets everything after confirmation prompt.

### State Management

Pure in-memory state using Flutter's `StatefulWidget` + `InheritedWidget` (no external package needed). `SessionState` is passed down the widget tree from `AppRouter`.

---

## 3. Module A — Social Slots

### Flow

1. Player taps **"GIRAR"** — 3 reels animate simultaneously.
2. Reels stop one by one with 150ms stagger (Reel 1 → 2 → 3).
3. Result card slides up from bottom showing the dare.
4. Player chooses **ACEITAR** or **VETAR**.

### Reel Definitions

| Reel | Content | Options |
|------|---------|---------|
| Reel 1 | Player | All session player names |
| Reel 2 | Category | Social · Físico · Mental · Wild |
| Reel 3 | Intensity | Casual · Ousado · Épico |

### Dare System

Dares are hardcoded in Dart as a `Map<Category, Map<Intensity, List<String>>>` with ~60 entries total (~5 per bucket). A dare is selected randomly from the matching bucket.

**Example buckets:**

- Social / Casual: "Envia uma mensagem de voz a alguém que não falas há 3 meses"
- Físico / Ousado: "Faz 20 flexões agora mesmo"
- Mental / Épico: "Conta o teu maior segredo ao grupo"
- Wild / Épico: "O grupo decide a tua consequência"

### Veto System

- Each player starts with **2 veto tokens** per session.
- Tapping **VETAR** costs 1 token and draws a new dare from the same bucket.
- When tokens run out, VETAR is disabled (opacity 0.5).
- Veto count shown as small pill next to player name on result card.

### Result Storage

Each spin saves a `SpinResult` to `slotsHistory`:
```
SpinResult
├── player: String
├── category: Category
├── intensity: Intensity
├── dare: String
└── accepted: bool
```

---

## 4. Module B — Roleta do Destino

### Flow

1. Player types a **dispute question** (e.g. "Quem paga a próxima ronda?").
2. Wheel is pre-populated with all session player names as equal segments.
3. Tap wheel or **"GIRAR"** button to spin — minimum 3 full rotations, physics deceleration.
4. Wheel slows and lands on a winner/loser.
5. Result shown with gold glow reveal + player name in Display style.
6. Result auto-logged to Ledger as a "Decisão" entry.

### Wheel Implementation

- Custom `CustomPainter` drawing equal arc segments, each labelled with a player name.
- Segments coloured using a fixed palette cycling through brand colours.
- Pointer (arrow) fixed at top, wheel rotates.
- Animation: `AnimationController` with `CurvedAnimation(curve: Curves.decelerate)`, random final angle ensuring ≥3 full rotations.

### Result Storage

```
RouletteResult
├── question: String
├── winner: String
└── timestamp: DateTime
```

---

## 5. Module C — Absurdity Ledger

### Entry Types

**1. Aposta Social (Social Bet)**
- Creator picks involved players (min 2), writes the bet, sets consequence for loser.
- Status: `pending` → resolved manually via **RESOLVER** button (creator picks loser).
- Loser's `daresCompleted` does NOT increment — bets are tracked separately.

**2. Previsão (Prediction)**
- Creator writes a prediction tied to an external event.
- All players vote (thumbs up/down) when outcome is known.
- Majority vote determines result; minority owes a consequence set at creation.

**3. Pontuação (Score)**
- Auto-logged whenever a Slots dare is accepted or a Roleta result is recorded.
- Displays as a running leaderboard sorted by `daresCompleted`.
- Players can also manually add score entries.

### Feed Layout

- Single scrollable feed, newest entries at top.
- Filter chips at top: **TODOS · APOSTAS · PREVISÕES · PONTUAÇÃO**
- FAB (floating action button): **+ NOVA ENTRADA** → bottom sheet with type selector.

### Entry Data Model

```
LedgerEntry (sealed class)
├── SocialBet
│   ├── description: String
│   ├── players: List<String>
│   ├── consequence: String
│   ├── status: pending | resolved
│   └── loser: String? (set on resolve)
├── Prediction
│   ├── description: String
│   ├── consequence: String
│   ├── votes: Map<String, bool>
│   └── resolved: bool
└── ScoreEntry
    ├── player: String
    ├── source: slots | roulette | manual
    └── description: String
```

---

## 6. Dare Content

Hardcoded in `lib/data/dares.dart` as a constant map. MVP target: 5 dares per bucket = 60 total (4 categories × 3 intensities × 5 dares).

Categories: `social`, `fisico`, `mental`, `wild`
Intensities: `casual`, `ousado`, `epico`

---

## 7. Navigation & Session Gate

- `AppRouter` holds `SessionState` as a field on `_AppRouterState`.
- Tabs for Slots, Roleta, Ledger show a lock icon and "Inicia uma sessão primeiro" overlay when no session active.
- Lobby always accessible.

---

## 8. Screens Summary

| Screen | Key Widgets |
|--------|-------------|
| Lobby | SessionBanner, GameCards, NewSessionButton |
| PlayerSetup | BottomSheet, NameInputList, ConfirmButton |
| Social Slots | SlotMachine (3 reels), SpinButton, DareResultCard, VetoButton |
| Roleta | QuestionInput, WheelPainter, SpinButton, ResultReveal |
| Ledger | FilterChips, EntryFeed, NewEntryFAB, EntryDetailSheet |

---

## 9. Out of Scope (MVP)

- Firebase / multiplayer
- Persistence across sessions
- Custom dare creation by players
- Sound effects
- Rive animations (use Flutter-native animation for MVP)
