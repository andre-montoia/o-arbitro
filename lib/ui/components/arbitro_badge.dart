import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

enum BadgeVariant { purple, pink, green, gold }

class ArbitroBadge extends StatelessWidget {
  const ArbitroBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.purple,
  });

  final String label;
  final BadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, glow) = switch (variant) {
      BadgeVariant.purple => (
        const Color(0x33A855F7),
        AppColors.purpleLight,
        AppColors.purple,
      ),
      BadgeVariant.pink => (
        const Color(0x33EC4899),
        AppColors.pink,
        AppColors.pink,
      ),
      BadgeVariant.green => (
        const Color(0x3310B981),
        AppColors.success,
        AppColors.emerald,
      ),
      BadgeVariant.gold => (
        const Color(0x33F59E0B),
        AppColors.gold,
        AppColors.gold,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.label.copyWith(color: fg),
      ),
    );
  }
}
