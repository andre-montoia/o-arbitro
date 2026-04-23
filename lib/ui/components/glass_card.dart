import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum GlassCardVariant { defaultCard, highlighted, gold, danger }

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.variant = GlassCardVariant.defaultCard,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final GlassCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (fillColor, borderColor, shadow) = switch (variant) {
      GlassCardVariant.defaultCard => (
        AppColors.glassFill,
        AppColors.glassBorder,
        <BoxShadow>[],
      ),
      GlassCardVariant.highlighted => (
        AppColors.glassFill,
        const Color(0x80A855F7),
        [const BoxShadow(color: Color(0x337C3AED), blurRadius: 20)],
      ),
      GlassCardVariant.gold => (
        const Color(0x14F59E0B),
        const Color(0x66F59E0B),
        [const BoxShadow(color: Color(0x26F59E0B), blurRadius: 20)],
      ),
      GlassCardVariant.danger => (
        const Color(0x14EF4444),
        const Color(0x4DEF4444),
        <BoxShadow>[],
      ),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: borderColor),
          boxShadow: shadow,
        ),
        child: child,
      ),
    );
  }
}
