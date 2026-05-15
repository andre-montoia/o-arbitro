import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum GlassCardVariant { defaultCard, highlighted, gold, danger, surface, glowing }

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
      GlassCardVariant.glowing => (
        AppColors.glassFill, // Deep purple from theme
        AppColors.purpleLight, // Lighter purple border
        AppColors.pink, // Bright pink glow color
      ),
    };

    final shadows = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 32, // Research: 15-25% blur, 32px for premium
        offset: const Offset(0, 8), // Research: deeper shadow for depth
      ),
    ];

    if (glowColor != null) {
      shadows.add(
        BoxShadow(
          color: glowColor.withValues(alpha: 0.3),
          blurRadius: 32, // Research: 32px for addictive glow
          spreadRadius: -4,
        ),
      );
    }

    Widget card = Container(
      margin: margin,
      child: GestureDetector(
        onTap: () {
          onTap?.call();
          // Add haptic feedback for addictive feel
          // HapticFeedback.lightImpact(); // Uncomment when haptic_service is integrated
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), // Research: 12-20 range, 16 for premium
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
