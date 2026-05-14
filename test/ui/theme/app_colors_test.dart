import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';

void main() {
  test('bg primary is deep dark purple', () {
    expect(AppColors.bgPrimary, const Color(0xFF06060E));
  });

  test('purple brand colour', () {
    expect(AppColors.purple, const Color(0xFF7C3AED));
  });

  test('gradient primary has three stops', () {
    expect(AppColors.gradientPrimary.colors.length, 3);
    expect(AppColors.gradientPrimary.colors.first, const Color(0xFF7C3AED));
    expect(AppColors.gradientPrimary.colors.last, const Color(0xFFEC4899));
  });

  test('gold reward color', () {
    expect(AppColors.gold, const Color(0xFFF59E0B));
  });

  test('emerald success color', () {
    expect(AppColors.emerald, const Color(0xFF10B981));
  });

  test('text muted has good contrast', () {
    expect(AppColors.textMuted, const Color(0xFFB8B8D8));
  });
}
