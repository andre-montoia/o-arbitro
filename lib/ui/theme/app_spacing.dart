import 'package:flutter/material.dart';

/// Responsive breakpoint system for O Árbitro
/// Handles everything from iPhone SE (375px) to iPad (1024px+)
abstract final class AppBreakpoints {
  static const double smallPhone = 360;   // iPhone SE, small Android
  static const double phone = 400;        // Standard phones
  static const double largePhone = 600;   // Large phones / small tablets
  static const double tablet = 900;       // Tablets
  static const double desktop = 1200;     // Desktop / large tablets
  
  static bool isSmallPhone(double width) => width < smallPhone;
  static bool isPhone(double width) => width >= smallPhone && width < largePhone;
  static bool isLargePhone(double width) => width >= largePhone && width < tablet;
  static bool isTablet(double width) => width >= tablet && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
}

/// Responsive spacing system
abstract final class AppSpacing {
  // Base spacing scale
  static const double xxs  = 2;
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 24;
  static const double xxl  = 32;
  static const double xxxl = 48;

  // Responsive screen padding
  static double screenPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < AppBreakpoints.smallPhone) return sm;
    if (w < AppBreakpoints.phone) return md;
    if (w < AppBreakpoints.largePhone) return lg;
    if (w < AppBreakpoints.tablet) return xl;
    return xxl;
  }

  static double cardPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < AppBreakpoints.smallPhone) return sm;
    if (w < AppBreakpoints.phone) return md;
    if (w < AppBreakpoints.largePhone) return lg;
    return xl;
  }

  // Component sizes
  static const double cardRadius    = 16;
  static const double buttonRadius  = 100;
  static const double inputRadius   = 12;
  static const double modalRadius   = 24;
  static const double chipRadius    = 100;

  // Responsive font scaling
  static double fontScale(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < AppBreakpoints.smallPhone) return 0.85;
    if (w < AppBreakpoints.phone) return 0.92;
    if (w < AppBreakpoints.largePhone) return 1.0;
    if (w < AppBreakpoints.tablet) return 1.1;
    return 1.2;
  }

  // Responsive widget sizes
  static double rouletteSize(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final minDim = w < h ? w : h;
    if (minDim < AppBreakpoints.smallPhone) return 220;
    if (minDim < AppBreakpoints.phone) return 260;
    if (minDim < AppBreakpoints.largePhone) return 320;
    if (minDim < AppBreakpoints.tablet) return 400;
    return 480;
  }

  static double slotMachineWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < AppBreakpoints.smallPhone) return w * 0.92;
    if (w < AppBreakpoints.phone) return w * 0.88;
    return w * 0.82;
  }

  // ScoreHUD responsive height — larger for readability
  static double scoreHudHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < AppBreakpoints.smallPhone) return 64;
    if (w < AppBreakpoints.phone) return 72;
    if (w < AppBreakpoints.largePhone) return 80;
    return 88;
  }

  static int scoreHudColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < AppBreakpoints.smallPhone) return 2;
    if (w < AppBreakpoints.phone) return 3;
    if (w < AppBreakpoints.largePhone) return 4;
    return 5;
  }

  // ═══════════════════════════════════════════════════════════
  // NEON GLOW — Colored shadow presets for the design system
  // ═══════════════════════════════════════════════════════════

  static List<BoxShadow> glowPurple({double intensity = 0.4}) => [
        BoxShadow(
          color: const Color(0xFF7C3AED).withValues(alpha: intensity),
          blurRadius: 20,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: const Color(0xFF7C3AED).withValues(alpha: intensity * 0.5),
          blurRadius: 40,
          spreadRadius: -8,
        ),
      ];

  static List<BoxShadow> glowGold({double intensity = 0.4}) => [
        BoxShadow(
          color: const Color(0xFFF59E0B).withValues(alpha: intensity),
          blurRadius: 16,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: const Color(0xFFF59E0B).withValues(alpha: intensity * 0.4),
          blurRadius: 32,
          spreadRadius: -8,
        ),
      ];

  static List<BoxShadow> glowPink({double intensity = 0.4}) => [
        BoxShadow(
          color: const Color(0xFFEC4899).withValues(alpha: intensity),
          blurRadius: 16,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: const Color(0xFFEC4899).withValues(alpha: intensity * 0.4),
          blurRadius: 32,
          spreadRadius: -8,
        ),
      ];

  static List<BoxShadow> glowEmerald({double intensity = 0.4}) => [
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: intensity),
          blurRadius: 16,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: intensity * 0.4),
          blurRadius: 32,
          spreadRadius: -8,
        ),
      ];

  static List<BoxShadow> glowDanger({double intensity = 0.4}) => [
        BoxShadow(
          color: const Color(0xFFEF4444).withValues(alpha: intensity),
          blurRadius: 16,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: const Color(0xFFEF4444).withValues(alpha: intensity * 0.4),
          blurRadius: 32,
          spreadRadius: -8,
        ),
      ];
}
