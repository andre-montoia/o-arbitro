# UX Analysis Report: O Árbitro

## Current State Assessment
- **UI Quality:** High. The use of glassmorphism and the defined color palette creates a premium feel.
- **Consistency:** Strong. The theme is consistently applied across the 3 mini-games.
- **Assets:** Weak point. Current app icons and marketing assets show AI-generation artifacts (distorted text). The use of emojis in the lobby screen is functional but lowers the "premium" perception.
- **UX Flow:** The lobby-centric navigation is appropriate for a party game.

## Recommendations

### 1. Visual Upgrade
- Replace emojis (🎰, 🎡, 📜) with custom-rendered 3D icons as specified in `ASSET_MANIFEST.md`.
- Replace the `Icons.sports_martial_arts` in the AppBar with a custom SVG of the "Golden Whistle" brand mark.

### 2. Player Personalization
- Implement the "Player Avatars" system. Each player should be able to pick one of the 8 themed avatars.
- This adds a sense of "identity" and makes the leaderboard more engaging.

### 3. Feedback & Delights
- Add subtle haptic feedback on slot spins and roulette stops.
- Use `Rive` for more complex interactive animations (already mentioned in `CONTEXT.md`).

### 4. Shareability
- Create a "Session Recap" screen that generates a social-media-ready image showing the MVP (Most Valuable Player) and the most "absurd" dare completed.

## Implementation Plan (UX Perspective)
1.  **Generate Assets:** Use the prompts in `ASSET_MANIFEST.md` to create the high-res PNGs.
2.  **Theme Wiring:** Ensure all new icons are placed in `assets/icon/` and correctly referenced in `pubspec.yaml`.
3.  **Avatar Selection:** Add a horizontal avatar picker in the `PlayerSetupSheet`.

---
*Created by UX Designer Analyst Agent*
