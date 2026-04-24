# O Árbitro — Context

## What this is
Flutter mobile app (iOS + Android) — a party game with 3 mini-games: Social Slots, Roleta do Destino, and Absurdity Ledger. Dark premium UI, Portuguese language. No backend — pure in-memory session state.

## Current state (2026-04-24)
**v0.2.0 complete.** All 3 games fully implemented and merged to master. APK released at:
https://github.com/andre-montoia/o-arbitro/releases/tag/v0.2.0-debug

34 tests passing. Branch `feature/game-mechanics` merged into master. ScoreHud component added.

## Key files
- `lib/main.dart` — app entry, theme wiring
- `lib/navigation/app_router.dart` — bottom nav + SessionState provider + locked tab gate
- `lib/models/session.dart` — immutable Session model
- `lib/models/session_state.dart` — InheritedWidget, use `SessionState.of(context)`
- `lib/models/player.dart` — Player(name, vetoTokens=2, daresCompleted)
- `lib/models/ledger_entry.dart` — sealed class: SocialBet, Prediction, ScoreEntry
- `lib/models/spin_result.dart` — SpinResult + DareCategory/DareIntensity enums
- `lib/data/dares.dart` — 60 hardcoded dares, `Dares.random(category, intensity)`
- `lib/ui/screens/lobby_screen.dart` — session start/reset, links to games
- `lib/ui/screens/slots_screen.dart` — slot machine with dare reveal + veto
- `lib/ui/screens/roulette_screen.dart` — spinning wheel (CustomPainter) + winner reveal
- `lib/ui/screens/ledger_screen.dart` — bets, predictions, scores, leaderboard
- `lib/ui/components/` — ArbitroButton, GlassCard, ArbitroBadge, SlotMachine, DareResultCard, RouletteWheel, PlayerSetupSheet, NewLedgerEntrySheet

## Design tokens
- `lib/ui/theme/app_colors.dart` — AppColors.*
- `lib/ui/theme/app_spacing.dart` — AppSpacing.*
- `lib/ui/theme/app_text_styles.dart` — AppTextStyles.*
- `lib/ui/theme/app_theme.dart` — AppTheme.dark

## Stack
- Flutter 3.x + Dart, phosphor_flutter, rive
- Fonts: Syne (headings) + Space Grotesk (body)
- No state management package — InheritedWidget only

## What's next (Plan 3 — not started)
- Firebase auth + Firestore persistence (sessions survive app close)
- Player avatars
- Sound effects (rive animations for slots)
- Share results to social media

## Key decisions
- All state is in-memory via SessionState InheritedWidget — resets on app close by design (party game)
- Roulette uses CustomPainter (no packages) for the spinning wheel
- Veto system: each player starts with 2 veto tokens, burns one to skip a dare and get a new one
- Ledger entries are a sealed class (SocialBet | Prediction | ScoreEntry) for exhaustive pattern matching
