import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key, this.child});

  final Widget? child;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rng = Random();
  late final List<_Blob> _blobs;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _blobs = List.generate(4, (i) => _Blob(
      radius: 150 + _rng.nextDouble() * 200,
      color: i % 2 == 0 
          ? AppColors.purple.withValues(alpha: 0.15) 
          : AppColors.pink.withValues(alpha: 0.1),
      offset: Offset(_rng.nextDouble(), _rng.nextDouble()),
      speed: 0.2 + _rng.nextDouble() * 0.5,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.gradientDark,
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (ctx, _) => CustomPaint(
              painter: _BlobPainter(_blobs, _ctrl.value),
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _Blob {
  _Blob({
    required this.radius,
    required this.color,
    required this.offset,
    required this.speed,
  });
  final double radius;
  final Color color;
  final Offset offset;
  final double speed;
}

class _BlobPainter extends CustomPainter {
  _BlobPainter(this.blobs, this.t);
  final List<_Blob> blobs;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final blob in blobs) {
      final dx = size.width * (blob.offset.dx + sin(t * 2 * pi * blob.speed) * 0.2);
      final dy = size.height * (blob.offset.dy + cos(t * 2 * pi * blob.speed) * 0.2);
      
      final paint = Paint()
        ..color = blob.color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
      
      canvas.drawCircle(Offset(dx, dy), blob.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.t != t;
}
