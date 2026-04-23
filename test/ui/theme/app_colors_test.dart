import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';

void main() {
  test('bg primary is midnight navy', () {
    expect(AppColors.bgPrimary, const Color(0xFF0D0D1A));
  });

  test('purple brand colour', () {
    expect(AppColors.purple, const Color(0xFF7C3AED));
  });

  test('gradient primary has two stops', () {
    expect(AppColors.gradientPrimary.colors.length, 2);
    expect(AppColors.gradientPrimary.colors.first, const Color(0xFF7C3AED));
    expect(AppColors.gradientPrimary.colors.last, const Color(0xFFEC4899));
  });
}
