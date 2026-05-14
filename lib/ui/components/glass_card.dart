import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum GlassCardVariant { defaultCard, highlighted, gold, danger, surface }

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.variant = GlassCardVariant.defaultCard,
    this.padding,
    this.onTap,
    this.margin,
  });

  final Widget child;
  final GlassCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final cardPad = padding ?? EdgeInsets.all(AppSpacing.cardPadding(context));

    final (fillColor, borderColor, shadows) = switch (variant) {
      GlassCardVariant.defaultCard => (
        AppColors.glassFill,
        AppColors.glassBorder,
        <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      GlassCardVariant.highlighted => (
        const Color(0x22A855F7),
        const Color(0x80A855F7),
        <BoxShadow>[
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      GlassCardVariant.gold => (
        const Color(0x18F59E0B),
        const Color(0x66F59E0B),
        <BoxShadow>[
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.25),
            blurRadius: 20,
            spreadRadius: -4,
          ),
        ],
      ),
      GlassCardVariant.danger => (
        const Color(0x18EF4444),
        const Color(0x4DEF4444),
        <BoxShadow>[
          BoxShadow(
            color: AppColors.danger.withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      GlassCardVariant.surface => (
        AppColors.surface,
        AppColors.border,
        <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    };

    return Container(
      margin: margin,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: cardPad,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}
