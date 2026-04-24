# Animation Upgrade — Design Spec
_2026-04-24_

## Overview

Upgrade the three game screens (Social Slots, Roleta do Destino, Absurdity Ledger) with animations that feel closer to the original games they reference. The goal is sensory payoff: every spin, reveal, and entry should feel like an event.

---

## 1. Social Slots — Real Slot Reels

### Current state
Three static labelled boxes (JOGADOR / CATEGORIA / NÍVEL) that swap text instantly.

### Target
A vertical-scrolling slot machine with:
- A purple neon machine frame (`SlotMachineFrame` widget wrapping the reel window)
- Three independent reels (`SlotReel` widget), each a `ListView` that animates vertically
- Each reel shows 3 visible rows: dim item above, **selected item** (full brightness, bordered), dim item below
- Reels stop sequentially: reel 1 at 600 ms, reel 2 at 750 ms, reel 3 at 900 ms (same as current)
- Scanline overlay (subtle repeating gradient) and a horizontal highlight bar at the midpoint
- After all reels stop, the dare result card slides up from the bottom

### Component structure
```
SlotMachineScreen
  └─ SlotMachine (StatefulWidget, GlobalKey)
       ├─ SlotMachineFrame (decorative shell)
       │    └─ Row of 3 × SlotReel (StatefulWidget)
       │         ├─ AnimationController (CurvedAnimation, Curves.decelerate)
       │         └─ AnimatedBuilder → scrollable column of items
       └─ GIRAR button → calls SlotMachine.spin()
```

### SlotReel animation mechanics
- Items list: fixed list for each reel (players / categories / intensities), cycling
- On spin: scroll position animates from 0 → `target * itemHeight` using `Tween<double>`
- `itemHeight` = 44 px (padding 10 px top/bottom, text ~24 px)
- Target index chosen at spin time (the dare result index in each list)
- After the controller completes, selected index is locked in

### Data flow
`SlotMachineScreen` calls `SessionState` to get players, generates a dare, passes player list to `SlotMachine`. `SlotMachine.spin()` returns `Future<DareResult>` that resolves after reel 3 stops.

---

## 2. Roleta do Destino — Winner Explosion Reveal

### Current state
CustomPainter wheel spins, stops, name is shown in a text widget below.

### Target
Keep the existing wheel and spin animation exactly. Add a **winner reveal overlay** that appears after the wheel stops:

- Full-screen semi-transparent dark overlay fades in (200 ms)
- A "winner card" scales up from 0.6→1.0 (300 ms, `Curves.elasticOut`) centered on screen
  - Gold border, gradient background (`#F59E0B` to amber)
  - Label: "O DESTINO DECIDIU" (small caps, letter-spaced)
  - Winner name in large bold white text
  - Particle burst: 20 small circles explode outward from center (simple `AnimatedPositioned` or `CustomPainter` particles)
- Tap anywhere or wait 4 s → overlay dismisses, game state updates

### Implementation approach
- `RouletteScreen` wraps content in a `Stack`
- `_showWinnerOverlay(String name)` is called by `RouletteWheelState` callback after spin completes
- Overlay is a stateful widget (`_WinnerOverlay`) with its own `AnimationController`
- Particles: list of 20 `_Particle` objects with random angle/speed, drawn in `CustomPainter` updated by the controller

### Callback wiring
`RouletteWheel` gains an `onSpinComplete(String winner)` callback. `RouletteScreen` passes this in and calls `setState(() => _winner = winner)` to trigger overlay render.

---

## 3. Absurdity Ledger — Dramatic Entry Reveal

### Current state
New entries appear at the top of the reversed list instantly.

### Target

**New entry animation:**
- Entry card slides in from off-screen top + fades in (400 ms, `Curves.easeOutCubic`)
- A brief gold flash on the card border (200 ms glow, then fades)
- Implemented via `AnimatedList` replacing the current `ListView.separated`

**Pending bet pulse:**
- Cards with `BetStatus.pending` have a pulsing gold border (opacity 0.3 → 1.0 → 0.3, 1.5 s loop)
- Implemented with a `RepeatAnimation` / `AnimationController.repeat(reverse: true)` inside `_BetCard`

**Resolved entry flash:**
- When a bet is resolved (loser selected), the card gets a green border flash (400 ms) then settles to the default card style
- Implemented by detecting the `status` transition in `_BetCard.didUpdateWidget`

### AnimatedList wiring
`LedgerScreen` replaces `ListView.separated` with `AnimatedList`. The `GlobalKey<AnimatedListState>` is used to call `insertItem(0)` when `ledgerEntries` length increases. The `itemBuilder` returns the appropriate `_EntryCard` wrapped in `SlideTransition` + `FadeTransition`.

---

## 4. UAT Test Updates

Tests must pump through new animation durations:

- **Slots**: existing pump pattern (100/700/800/1000 ms) already matches — no change needed
- **Roulette**: add pump after spin for overlay: `pump(300ms)` + `pumpAndSettle()`, then check for winner overlay text
- **Ledger new entry**: after `+ NOVA ENTRADA` flow, pump `400ms` + `pumpAndSettle()`, check entry appears

New test cases:
- `roulette: tapping GIRAR shows winner overlay with player name`
- `roulette: tapping overlay dismisses it`
- `ledger: new entry animates in after adding via sheet`

---

## 5. Out of Scope

- Sound effects
- Haptic feedback
- Persistent leaderboard (lives only for session duration)
- Lobby screen animation changes

---

## Acceptance Criteria

1. Slot reels scroll vertically and stop sequentially — visible in emulator
2. Dare result card appears after all reels stop
3. Roulette winner overlay appears with particle burst after spin
4. Ledger new entries slide in; pending bets pulse gold
5. All existing UAT tests pass; new UAT tests pass
6. `flutter analyze` reports zero errors
