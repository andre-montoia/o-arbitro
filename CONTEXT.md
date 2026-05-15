# O Árbitro — Context

## What this is
Flutter mobile app (iOS + Android) — a party game with 3 mini-games: Social Slots, Roleta do Destino, and Absurdity Ledger. Dark premium UI, Portuguese language. No backend — pure in-memory session state.

## Current state (2026-05-15)
**v0.3.0 complete.** UX foundation established.
- Comprehensive Design System and Asset Manifest created in `docs/ux/`.
- Player Avatar system implemented (Model + Selection UI + Lobby display).
- API keys configured for high-res asset generation.

## Key files
- `docs/ux/DESIGN_SYSTEM.md` — Visual identity & standards
- `docs/ux/ASSET_MANIFEST.md` — specifications for icons/images
- `lib/models/player.dart` — Updated with `avatarId`
- `lib/ui/components/player_setup_sheet.dart` — Added Avatar Picker
- `lib/ui/screens/lobby_screen.dart` — Updated with Player Chips & Avatars

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
