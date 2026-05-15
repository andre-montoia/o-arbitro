import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiEffect extends StatefulWidget {
  const ConfettiEffect({
    super.key,
    this.colors = const [
      Color(0xFFF59E0B), // Gold
      Color(0xFFA855F7), // Purple
      Color(0xFFEC4899), // Pink
      Colors.white,
    ],
    this.count = 50,
  });

  final List<Color> colors;
  final int count;

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Confetto> _confetti;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..forward();

    _confetti = List.generate(widget.count, (i) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 100 + _rng.nextDouble() * 250;
      return _Confetto(
        angle: angle,
        speed: speed,
        size: 4 + _rng.nextDouble() * 6,
        color: widget.colors[_rng.nextInt(widget.colors.length)],
        rotationSpeed: _rng.nextDouble() * 10,
        drift: -1.0 + _rng.nextDouble() * 2.0,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (ctx, _) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_confetti, _ctrl.value),
        ),
      ),
    );
  }
}

class _Confetto {
  _Confetto({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.drift,
  });
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double rotationSpeed;
  final double drift;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.confetti, this.t);
  final List<_Confetto> confetti;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final opacity = (1.0 - t).clamp(0.0, 1.0);

    for (final c in confetti) {
      final dist = c.speed * t;
      final x = center.dx + cos(c.angle) * dist + (c.drift * t * 100);
      final y = center.dy + sin(c.angle) * dist + (9.8 * 50 * t * t); // Gravity

      final paint = Paint()
        ..color = c.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(c.rotationSpeed * t);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: c.size, height: c.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
