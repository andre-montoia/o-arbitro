import 'package:flutter/material.dart';

/// O Árbitro — Premium Party Game Color System
/// 
/// Color psychology for party games:
/// - Warm gold/amber triggers excitement and reward (casino association)
/// - Deep purple/indigo creates luxury and mystery
/// - Hot pink/magenta adds energy and playfulness
/// - Emerald green for success/approval states
/// - Rich gradients create depth and premium feel
abstract final class AppColors {
  // ═══════════════════════════════════════════════════════════
  // BACKGROUND LAYER — Deep, rich, not flat
  // ═══════════════════════════════════════════════════════════
  
  // Primary background — deepest layer, almost black with purple undertone
  static const Color bgPrimary   = Color(0xFF06060E);
  // Secondary background — cards, surfaces
  static const Color bgSecondary = Color(0xFF0C0C18);
  // Tertiary background — elevated surfaces, modals
  static const Color bgTertiary  = Color(0xFF14142A);
  // Surface layers with subtle warmth
  static const Color surface     = Color(0xFF1A1A30);
  static const Color surface2    = Color(0xFF24243E);
  static const Color surface3    = Color(0xFF2E2E4C);
  static const Color border      = Color(0x33A855F7);

  // ═══════════════════════════════════════════════════════════
  // PRIMARY ACCENT — Purple/Indigo (luxury, mystery)
  // ═══════════════════════════════════════════════════════════
  
  static const Color purple      = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFA855F7);
  static const Color purpleDark  = Color(0xFF5B21B6);
  static const Color purpleGlow  = Color(0xFF9333EA);
  static const Color indigo      = Color(0xFF4F46E5);
  static const Color indigoLight = Color(0xFF6366F1);

  // ═══════════════════════════════════════════════════════════
  // ENERGY ACCENT — Pink/Magenta (playfulness, excitement)
  // ═══════════════════════════════════════════════════════════
  
  static const Color pink        = Color(0xFFEC4899);
  static const Color pinkLight   = Color(0xFFF472B6);
  static const Color pinkDark    = Color(0xFFDB2777);
  static const Color magenta     = Color(0xFFD946EF);
  static const Color hotPink     = Color(0xFFF43F5E);

  // ═══════════════════════════════════════════════════════════
  // REWARD ACCENT — Gold/Amber (casino, achievement, excitement)
  // ═══════════════════════════════════════════════════════════
  
  static const Color gold        = Color(0xFFF59E0B);
  static const Color goldLight   = Color(0xFFFBBF24);
  static const Color goldDark    = Color(0xFFD97706);
  static const Color amber       = Color(0xFFF97316);
  static const Color amberLight  = Color(0xFFFB923C);
  static const Color warmYellow  = Color(0xFFFDE047);

  // ═══════════════════════════════════════════════════════════
  // SUCCESS — Emerald Green (approval, positive states)
  // ═══════════════════════════════════════════════════════════
  
  static const Color emerald     = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color success     = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);

  // ═══════════════════════════════════════════════════════════
  // DANGER — Rich Red (punishment, failure)
  // ═══════════════════════════════════════════════════════════
  
  static const Color danger      = Color(0xFFEF4444);
  static const Color dangerDark  = Color(0xFFDC2626);
  static const Color dangerLight = Color(0xFFF87171);
  static const Color warning     = Color(0xFFF59E0B);

  // ═══════════════════════════════════════════════════════════
  // ROULETTE — Classic casino colors
  // ═══════════════════════════════════════════════════════════
  
  static const Color rouletteRed    = Color(0xFFCC0000);
  static const Color rouletteBlack  = Color(0xFF1A1A1A);
  static const Color rouletteGreen  = Color(0xFF00AA44);

  // ═══════════════════════════════════════════════════════════
  // TEXT — High contrast hierarchy
  // ═══════════════════════════════════════════════════════════
  
  static const Color textPrimary    = Color(0xFFFFFFFF);
  static const Color textSecondary  = Color(0xFFE8E8F8);  // Brighter than before
  static const Color textMuted      = Color(0xFFB8B8D8);  // Much brighter for readability
  static const Color textDisabled   = Color(0xFF6B6B8C);  // Brighter disabled
  static const Color textContrast   = Color(0xFFFFFFFF);
  static const Color textGold       = Color(0xFFFBBF24);
  static const Color textEmerald    = Color(0xFF34D399);
  static const Color textOnPurple   = Color(0xFFF0E8FF);

  // ═══════════════════════════════════════════════════════════
  // GLASS MORPHISM — Premium frosted glass effect
  // ═══════════════════════════════════════════════════════════
  
  static const Color glassFill      = Color(0x1AA855F7);
  static const Color glassBorder    = Color(0x4DA855F7);
  static const Color glassHighlight = Color(0x2AA855F7);
  static const Color glassDark      = Color(0xCC0C0C18);

  // ═══════════════════════════════════════════════════════════
  // GRADIENTS — Rich, multi-stop, premium feel
  // ═══════════════════════════════════════════════════════════
  
  /// Primary brand gradient — purple to pink
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

  /// Slot machine chrome gradient
  static const LinearGradient gradientChrome = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB8B8CC), Color(0xFF6B6B8A), Color(0xFF2A2A3E), Color(0xFF6B6B8A), Color(0xFFB8B8CC)],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
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
  static const Color shadowGold   = Color(0x44F59E0B);
  static const Color shadowPink   = Color(0x44EC4899);
  static const Color shadowDark   = Color(0x99000000);

  // ═══════════════════════════════════════════════════════════
  // INTENSITY BADGE COLORS — For dare difficulty levels
  // ═══════════════════════════════════════════════════════════
  
  static const Color intensityCasual  = Color(0xFF6366F1);  // Indigo
  static const Color intensityOusado  = Color(0xFFF59E0B);  // Amber
  static const Color intensityEpico   = Color(0xFFEF4444);  // Red
  static const Color intensityCastigo = Color(0xFFDC2626);  // Dark red
}
