import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w800,
    fontSize: 32,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors.textMuted,
    height: 1.4,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w700,
    fontSize: 10,
    color: AppColors.purpleLight,
    letterSpacing: 1.5,
    height: 1.0,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w400,
    fontSize: 11,
    color: AppColors.textMuted,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
}
