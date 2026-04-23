import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color bgPrimary   = Color(0xFF0D0D1A);
  static const Color surface     = Color(0xFF13132A);
  static const Color surface2    = Color(0xFF1E1E3A);
  static const Color border      = Color(0x33A855F7);

  static const Color purple      = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFA855F7);
  static const Color pink        = Color(0xFFEC4899);

  static const Color gold        = Color(0xFFF59E0B);
  static const Color success     = Color(0xFF10B981);
  static const Color danger      = Color(0xFFEF4444);

  static const Color textPrimary  = Color(0xFFFFFFFF);
  static const Color textMuted    = Color(0xFFA0A0C0);
  static const Color textDisabled = Color(0xFF555577);

  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, pink],
  );

  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, Color(0xFFFBBF24)],
  );

  static const Color glassFill   = Color(0x147C3AED);
  static const Color glassBorder = Color(0x33A855F7);
}
