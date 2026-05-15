import 'package:flutter/material.dart';
import 'package:o_arbitro/services/haptic_service.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';
import 'glass_card.dart';

class GlowingGlassCard extends StatefulWidget {
  const GlowingGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.initialGlowColor,
    this.glowDuration = const Duration(seconds: 2),
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? initialGlowColor;
  final Duration glowDuration;

  @override
  State<GlowingGlassCard> createState() => _GlowingGlassCardState();
}

class _GlowingGlassCardState extends State<GlowingGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Research: 600-800ms pulse for addictive feel, 700ms sweet spot
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    
    // Research: cubic curve for premium snappy feel
    final curve = CurvedAnimation(
      parent: _controller,
          curve: Cubic(0.23, 1, 0.32, 1), // Research-backed snap curve
    );
    
    // Glow pulse: 0.8 → 1.2 (research: subtle but noticeable)
    _glowAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(curve);
    
    // Scale pulse: slight 3% expansion (research: tactile button press feel)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowColor = (widget.initialGlowColor ?? AppColors.pink)
            .withValues(alpha: 0.25 * _glowAnimation.value);
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GlassCard(
            variant: GlassCardVariant.glowing,
            padding: widget.padding,
            onTap: () {
              widget.onTap?.call();
              HapticService.instance.light(); // Addictive tactile response
            },
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: glowColor,
                    blurRadius: 32 * _glowAnimation.value, // Research: 32px blur
                    spreadRadius: -4 * _glowAnimation.value,
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
