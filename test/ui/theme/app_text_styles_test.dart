import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/ui/theme/app_text_styles.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';

void main() {
  test('display uses Syne weight 800', () {
    expect(AppTextStyles.display.fontFamily, 'Syne');
    expect(AppTextStyles.display.fontWeight, FontWeight.w800);
    expect(AppTextStyles.display.color, AppColors.textPrimary);
  });

  test('body uses SpaceGrotesk weight 500', () {
    expect(AppTextStyles.body.fontFamily, 'SpaceGrotesk');
  });

  test('label is uppercase tracked', () {
    expect(AppTextStyles.label.letterSpacing, 1.5);
  });
}
