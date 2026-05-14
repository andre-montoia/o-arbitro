import 'package:flutter/material.dart';
import 'app_colors.dart';

/// A widget that provides responsive breakpoints
class Responsive extends StatelessWidget {
  const Responsive({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget child;
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static EdgeInsets safePadding(BuildContext context) =>
      MediaQuery.of(context).padding;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 900 && desktop != null) return desktop!;
    if (w >= 600 && tablet != null) return tablet!;
    if (mobile != null) return mobile!;
    return child;
  }
}

/// Animated background with subtle gradient and particle effect
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key, required this.child});
  final Widget child;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A0A15),
                Color(0xFF0E0E1A),
                Color(0xFF080810),
              ],
            ),
          ),
        ),
        // Animated radial glow
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: _BackgroundGlowPainter(_controller.value),
            );
          },
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class _BackgroundGlowPainter extends CustomPainter {
  final double t;
  _BackgroundGlowPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width * 0.5 + size.width * 0.3 * (t * 2 - 1).abs();
    final centerY = size.height * 0.3 + size.height * 0.2 * (t * 1.5 - 0.75).abs();

    // Purple glow
    final purpleGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.purple.withValues(alpha: 0.08),
          AppColors.purple.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: size.width * 0.6,
      ));
    canvas.drawCircle(Offset(centerX, centerY), size.width * 0.6, purpleGlow);

    // Pink glow (offset)
    final pinkGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.pink.withValues(alpha: 0.05),
          AppColors.pink.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width - centerX, size.height * 0.6),
        radius: size.width * 0.5,
      ));
    canvas.drawCircle(
      Offset(size.width - centerX, size.height * 0.6),
      size.width * 0.5,
      pinkGlow,
    );
  }

  @override
  bool shouldRepaint(_BackgroundGlowPainter old) => old.t != t;
}

/// Confetti particle effect for celebrations
class ConfettiEffect extends StatefulWidget {
  const ConfettiEffect({super.key, this.colors});
  final List<Color>? colors;

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    final colors = widget.colors ??
        [AppColors.gold, AppColors.pink, AppColors.purpleLight, AppColors.success];

    _particles = List.generate(30, (i) {
      final rng = i * 7919; // pseudo-random seed
      return _Particle(
        x: (rng % 100) / 100.0,
        y: -0.1 - (rng % 50) / 100.0,
        color: colors[rng % colors.length],
        size: 4.0 + (rng % 4) * 2.0,
        speed: 0.3 + (rng % 30) / 100.0,
        wobble: (rng % 20) / 10.0,
        rotation: (rng % 628) / 100.0,
        rotationSpeed: (rng % 10 - 5) / 10.0,
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_particles, _controller.value),
        );
      },
    );
  }
}

class _Particle {
  final double x, y, size, speed, wobble, rotation, rotationSpeed;
  final Color color;
  _Particle({
    required this.x, required this.y, required this.color,
    required this.size, required this.speed, required this.wobble,
    required this.rotation, required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  _ConfettiPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final progress = t.clamp(0.0, 1.0);
      final px = size.width * p.x + (p.wobble * 20 * (progress * 6 - 3).abs());
      final py = size.height * p.y + progress * p.speed * size.height * 1.2;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      if (py > size.height + 20 || opacity <= 0) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation + progress * p.rotationSpeed * 10);

      // Draw as small rectangle (confetti shape)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          Radius.circular(p.size * 0.2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}

/// Glowing container with animated border
class GlowContainer extends StatefulWidget {
  const GlowContainer({
    super.key,
    required this.child,
    this.color = AppColors.purple,
    this.intensity = 0.5,
    this.radius = 16,
    this.animate = true,
  });

  final Widget child;
  final Color color;
  final double intensity;
  final double radius;
  final bool animate;

  @override
  State<GlowContainer> createState() => _GlowContainerState();
}

class _GlowContainerState extends State<GlowContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.animate) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final glowIntensity = widget.animate
            ? widget.intensity * (0.7 + 0.3 * _controller.value)
            : widget.intensity;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: glowIntensity * 0.6),
                blurRadius: 20,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: widget.color.withValues(alpha: glowIntensity * 0.3),
                blurRadius: 40,
                spreadRadius: -8,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
