import 'package:flutter/material.dart';

/// O Árbitro — Premium Casino Party Game Color System
///
/// Design Philosophy:
/// - Deep purple/black backgrounds create luxury and mystery
/// - Warm gold/amber triggers excitement and reward (casino association)
/// - Hot pink/magenta adds energy and playfulness
/// - Emerald green for success/approval states
/// - Rich gradients create depth and premium feel
///
/// Reference: docs/ux/DESIGN_SYSTEM.md
abstract final class AppColors {
  // ═══════════════════════════════════════════════════════════
  // BACKGROUND LAYER — Deep, rich, not flat
  // ═══════════════════════════════════════════════════════════

  /// Deepest background — almost black with purple undertone
  static const Color bgPrimary = Color(0xFF06060E);
  /// Secondary background — cards, surfaces
  static const Color bgSecondary = Color(0xFF0C0C18);
  /// Tertiary background — elevated surfaces, modals
  static const Color bgTertiary = Color(0xFF14142A);
  /// Surface layers with subtle warmth
  static const Color surface = Color(0xFF1A1A30);
  static const Color surface2 = Color(0xFF24243E);
  static const Color surface3 = Color(0xFF2E2E4C);
  /// Subtle purple border
  static const Color border = Color(0x33A855F7);

  // ═══════════════════════════════════════════════════════════
  // PRIMARY ACCENT — Luxury Purple
  // ═══════════════════════════════════════════════════════════

  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFA855F7);
  static const Color purpleDark = Color(0xFF5B21B6);
  /// Deep purple background alternative name
  static const Color purpleDeep = bgPrimary;
  static const Color purpleGlow = Color(0xFF9333EA);
  static const Color indigo = Color(0xFF4F46E5);
  static const Color indigoLight = Color(0xFF6366F1);

  // ═══════════════════════════════════════════════════════════
  // ENERGY ACCENT — Electric Pink
  // ═══════════════════════════════════════════════════════════

  static const Color pink = Color(0xFFEC4899);
  static const Color pinkLight = Color(0xFFF472B6);
  static const Color pinkDark = Color(0xFFDB2777);
  static const Color magenta = Color(0xFFD946EF);
  static const Color hotPink = Color(0xFFF43F5E);

  // ═══════════════════════════════════════════════════════════
  // REWARD ACCENT — Winner's Gold
  // ═══════════════════════════════════════════════════════════

  static const Color gold = Color(0xFFF59E0B);
  static const Color goldLight = Color(0xFFFBBF24);
  static const Color goldDark = Color(0xFFD97706);
  static const Color amber = Color(0xFFF97316);
  static const Color amberLight = Color(0xFFFB923C);
  static const Color warmYellow = Color(0xFFFDE047);

  // ═══════════════════════════════════════════════════════════
  // SUCCESS — Approval Green
  // ═══════════════════════════════════════════════════════════

  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);

  // ═══════════════════════════════════════════════════════════
  // DANGER — Punishment Red
  // ═══════════════════════════════════════════════════════════

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerDark = Color(0xFFDC2626);
  static const Color dangerLight = Color(0xFFF87171);
  static const Color warning = Color(0xFFF59E0B);

  // ═══════════════════════════════════════════════════════════
  // ROULETTE — Classic casino colors
  // ═══════════════════════════════════════════════════════════

  static const Color rouletteRed = Color(0xFFCC0000);
  static const Color rouletteBlack = Color(0xFF1A1A1A);
  static const Color rouletteGreen = Color(0xFF00AA44);

  // ═══════════════════════════════════════════════════════════
  // TEXT — High contrast hierarchy
  // ═══════════════════════════════════════════════════════════

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE8E8F8);
  static const Color textMuted = Color(0xFFB8B8D8);
  static const Color textDisabled = Color(0xFF6B6B8C);
  static const Color textContrast = Color(0xFFFFFFFF);
  static const Color textGold = Color(0xFFFBBF24);
  static const Color textEmerald = Color(0xFF34D399);
  static const Color textOnPurple = Color(0xFFF0E8FF);

  // ════════════════════════════════════════════════════════
  // GLASS MORPHISM — Premium frosted glass effect
  // ════════════════════════════════════════════════════════

  /// Glass fill — 10% alpha (research: 5-15% range)
  static const Color glassFill = Color(0x1AA855F7);
  
  /// Glass border — 20% opacity (research: 10-25% for premium)
  static const Color glassBorder = Color(0x33A855F7);
  
  /// Glass highlight — 15% opacity for specular edge
  static const Color glassHighlight = Color(0x26A855F7);
  
  /// Glass dark fill — for elevated surfaces
  static const Color glassDark = Color(0xCC0C0C18);

  // ════════════════════════════════════════════════════════
  // SLOT MACHINE — Premium casino chrome & neon
  // ═══════════════════════════════════════════════════════════
  //
  // The slot machine uses a distinct sub-palette:
  // - Body: dark gunmetal with purple tint (not the app purple)
  // - Chrome: polished gold/brass metallic
  // - Reels: near-black with colored neon accents per symbol
  // - Lights: cycling neon (pink, gold, cyan, purple, green)
  // - Lever: metallic shaft with glowing pink ball

  /// Slot machine body — dark gunmetal with subtle purple tint
  static const Color slotBody = Color(0xFF12101E);
  static const Color slotBodyLight = Color(0xFF1E1A30);
  static const Color slotBodyDark = Color(0xFF0A0812);

  /// Slot machine chrome — polished gold/brass metallic
  static const Color slotChrome = Color(0xFFD4A843);
  static const Color slotChromeLight = Color(0xFFF0D080);
  static const Color slotChromeDark = Color(0xFF8B6914);

  /// Slot reel background — near-black
  static const Color slotReelBg = Color(0xFF080810);

  /// Slot reel divider — thin gold lines
  static const Color slotDivider = Color(0x44D4A843);

  /// Slot lever — metallic silver
  static const Color slotLever = Color(0xFF9B9BB8);
  static const Color slotLeverDark = Color(0xFF5A5A72);

  /// Slot lever ball — glowing neon pink
  static const Color slotLeverBall = Color(0xFFFF3377);
  static const Color slotLeverBallGlow = Color(0x66FF3377);

  /// Animated light strip — cycling neon colors
  static const List<Color> slotLights = [
    Color(0xFFFF3377), // neon pink
    Color(0xFFFBBF24), // gold
    Color(0xFF00E5FF), // cyan
    Color(0xFFA855F7), // purple
    Color(0xFF39FF14), // neon green
    Color(0xFFFF6B35), // orange
    Color(0xFFEC4899), // hot pink
  ];

  /// Pay line highlight — gold glow
  static const Color slotPayLine = Color(0x22FBBF24);

  // ── Symbol colors per category — neon casino style ──

  static const Color slotSocial = Color(0xFFA855F7);   // purple — social/masks
  static const Color slotFisico = Color(0xFFFF3377);    // neon pink — physical
  static const Color slotMental = Color(0xFF00E5FF);    // cyan — mental
  static const Color slotWild = Color(0xFFFBBF24);      // gold — wild
  static const Color slotPlayer = Color(0xFF39FF14);    // neon green — player names

  // ── Intensity symbol colors — escalating warmth ──

  static const Color slotCasual = Color(0xFF00E5FF);    // cyan — easy
  static const Color slotOusado = Color(0xFFFBBF24);    // gold — bold
  static const Color slotEpico = Color(0xFFFF3377);     // neon pink — epic

  // ── Win celebration colors ──

  static const Color slotWinGlow = Color(0x44FBBF24);
  static const Color slotJackpot = Color(0xFFFFD700);

  // ═══════════════════════════════════════════════════════════
  // GRADIENTS — Rich, multi-stop, premium feel
  // ═══════════════════════════════════════════════════════════

  /// Primary brand gradient — purple → magenta → pink
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF9333EA), Color(0xFFEC4899)],
    stops: [0.0, 0.5, 1.0],
  );

  /// Gold reward gradient — warm casino feel
  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24), Color(0xFFFDE047)],
    stops: [0.0, 0.6, 1.0],
  );

  /// Emerald success gradient
  static const LinearGradient gradientSuccess = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
    stops: [0.0, 0.5, 1.0],
  );

  /// Danger/punishment gradient
  static const LinearGradient gradientDanger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDC2626), Color(0xFFEF4444), Color(0xFFF87171)],
    stops: [0.0, 0.5, 1.0],
  );

  /// Dark background gradient — adds depth
  static const LinearGradient gradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0C0C18), Color(0xFF06060E), Color(0xFF0A0A1A)],
    stops: [0.0, 0.5, 1.0],
  );

  /// Surface gradient — subtle depth for cards
  static const LinearGradient gradientSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A30), Color(0xFF24243E)],
  );

  /// Highlighted surface — for featured cards
  static const LinearGradient gradientSurfaceHighlight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E2E4C), Color(0xFF3A3A5A)],
  );

  /// Slot machine body gradient — dark gunmetal with purple tint
  static const LinearGradient gradientSlotBody = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1A30), Color(0xFF12101E), Color(0xFF0A0812)],
  );

  /// Slot machine chrome trim gradient — polished gold metallic
  static const LinearGradient gradientSlotChrome = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF0D080), Color(0xFFD4A843), Color(0xFF8B6914)],
  );

  /// Slot lever shaft gradient — metallic silver
  static const LinearGradient gradientSlotLever = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF5A5A72), Color(0xFF9B9BB8), Color(0xFF5A5A72)],
  );

  /// Slot lever ball gradient — glowing neon pink
  static const RadialGradient gradientSlotLeverBall = RadialGradient(
    center: Alignment(-0.3, -0.3),
    colors: [Color(0xFFFF6699), Color(0xFFFF3377), Color(0xFFCC0044)],
  );

  /// Neon glow gradient for active/spinning elements
  static const LinearGradient gradientNeon = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00A855F7), Color(0x66A855F7)],
  );

  /// Warm ambient glow — for celebration moments
  static const RadialGradient gradientCelebration = RadialGradient(
    center: Alignment.center,
    radius: 0.8,
    colors: [Color(0x33F59E0B), Color(0x11EC4899), Color(0x0006060E)],
  );

  /// Subtle background pattern overlay
  static const LinearGradient gradientBgPattern = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x05A855F7), Color(0x0006060E), Color(0x03EC4899)],
    stops: [0.0, 0.5, 1.0],
  );

  // ═══════════════════════════════════════════════════════════
  // SHADOWS — Colored shadows for depth
  // ═══════════════════════════════════════════════════════════

  static const Color shadowPurple = Color(0x667C3AED);
  static const Color shadowGold = Color(0x44F59E0B);
  static const Color shadowPink = Color(0x44EC4899);
  static const Color shadowDark = Color(0x99000000);

  /// Premium glow shadow — for addictive neon effects (research: 32px blur)
  static List<BoxShadow> glowShadowPurple = [
    BoxShadow(
      color: shadowPurple.withValues(alpha: 0.3),
      blurRadius: 32,
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> glowShadowPink = [
    BoxShadow(
      color: shadowPink.withValues(alpha: 0.3),
      blurRadius: 32,
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> glowShadowGold = [
    BoxShadow(
      color: shadowGold.withValues(alpha: 0.3),
      blurRadius: 32,
      spreadRadius: -4,
    ),
  ];

  // ═══════════════════════════════════════════════════════════
  // INTENSITY BADGE COLORS — For dare difficulty levels
  // ═══════════════════════════════════════════════════════════

  static const Color intensityCasual = Color(0xFF6366F1);  // Indigo
  static const Color intensityOusado = Color(0xFFF59E0B);  // Amber
  static const Color intensityEpico = Color(0xFFEF4444);   // Red
  static const Color intensityCastigo = Color(0xFFDC2626); // Dark red
}
