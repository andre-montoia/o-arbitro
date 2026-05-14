import 'package:flutter/material.dart';
import 'app_colors.dart';

/// O Árbitro — Typography System
/// 
/// Improved contrast ratios:
/// - Primary text: white on dark bg (21:1)
/// - Secondary text: #E8E8F8 on dark bg (15:1) 
/// - Muted text: #B8B8D8 on dark bg (7:1) — was #A0A0C0 (4.5:1)
/// - Disabled: #6B6B8C on dark bg (3.5:1) — was #555577 (2.8:1)
abstract final class AppTextStyles {
  // ═══════════════════════════════════════════════════════════
  // DISPLAY / HERO — Syne ExtraBold
  // ═══════════════════════════════════════════════════════════
  
  static const TextStyle display = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w800,
    fontSize: 32,
    color: AppColors.textPrimary,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w800,
    fontSize: 24,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  // ═══════════════════════════════════════════════════════════
  // HEADINGS — Syne Bold
  // ═══════════════════════════════════════════════════════════
  
  static const TextStyle heading = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // ═══════════════════════════════════════════════════════════
  // BODY — SpaceGrotesk Medium/Bold
  // ═══════════════════════════════════════════════════════════
  
  static const TextStyle body = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors.textMuted,  // Now #B8B8D8 — much more readable
    height: 1.4,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.textMuted,
    height: 1.4,
  );

  // ═══════════════════════════════════════════════════════════
  // LABELS — SpaceGrotesk Bold, tracked
  // ═══════════════════════════════════════════════════════════
  
  static const TextStyle label = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w700,
    fontSize: 10,
    color: AppColors.purpleLight,
    letterSpacing: 1.5,
    height: 1.0,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w700,
    fontSize: 12,
    color: AppColors.purpleLight,
    letterSpacing: 1.2,
    height: 1.0,
  );

  // ═══════════════════════════════════════════════════════════
  // CAPTION — SpaceGrotesk Regular
  // ═══════════════════════════════════════════════════════════
  
  static const TextStyle caption = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w400,
    fontSize: 11,
    color: AppColors.textMuted,
    height: 1.4,
  );

  // ═══════════════════════════════════════════════════════════
  // BUTTONS — SpaceGrotesk Bold
  // ═══════════════════════════════════════════════════════════
  
  static const TextStyle button = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w700,
    fontSize: 12,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  // ═══════════════════════════════════════════════════════════
  // SCORE / NUMBERS — Syne ExtraBold, gold colored
  // ═══════════════════════════════════════════════════════════
  
  static const TextStyle score = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w800,
    fontSize: 28,
    color: AppColors.gold,
    height: 1.0,
  );

  static const TextStyle scoreSmall = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: AppColors.gold,
    height: 1.0,
  );

  // ═══════════════════════════════════════════════════════════
  // DARE TEXT — SpaceGrotesk SemiBold/Bold
  // ═══════════════════════════════════════════════════════════
  
  static const TextStyle dareText = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle dareTextLarge = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ═══════════════════════════════════════════════════════════
  // RESPONSIVE HELPERS
  // ═══════════════════════════════════════════════════════════
  
  static TextStyle responsive(TextStyle base, double scale) {
    return base.copyWith(
      fontSize: (base.fontSize ?? 14) * scale,
    );
  }
}
