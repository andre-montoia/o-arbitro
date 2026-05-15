import 'dart:ui';
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

    final (fillColor, borderColor, glowColor) = switch (variant) {
      GlassCardVariant.defaultCard => (
        AppColors.glassFill,
        AppColors.glassBorder,
        null,
      ),
      GlassCardVariant.highlighted => (
        const Color(0x22A855F7),
        const Color(0x80A855F7),
        AppColors.purple,
      ),
      GlassCardVariant.gold => (
        const Color(0x18F59E0B),
        const Color(0x66F59E0B),
        AppColors.gold,
      ),
      GlassCardVariant.danger => (
        const Color(0x18EF4444),
        const Color(0x4DEF4444),
        AppColors.danger,
      ),
      GlassCardVariant.surface => (
        AppColors.surface,
        AppColors.border,
        null,
      ),
    };

    final shadows = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];

    if (glowColor != null) {
      shadows.add(
        BoxShadow(
          color: glowColor.withValues(alpha: 0.25),
          blurRadius: 24,
          spreadRadius: -4,
        ),
      );
    }

    Widget card = Container(
      margin: margin,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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
        ),
      ),
    );

    return card;
  }
}
