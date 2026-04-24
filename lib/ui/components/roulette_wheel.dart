import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class RouletteWheel extends StatefulWidget {
  const RouletteWheel({
    super.key,
    required this.players,
    required this.onResult,
  });

  final List<String> players;
  final ValueChanged<String> onResult;

  @override
  RouletteWheelState createState() => RouletteWheelState();
}

class RouletteWheelState extends State<RouletteWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentRotation = 0;
  int? _winnerIndex;

  final List<Color> _segmentColors = const [
    AppColors.purple,
    AppColors.pink,
    Color(0xFF3b82f6),
    AppColors.success,
    AppColors.gold,
    Color(0xFF8b5cf6),
    Color(0xFFf97316),
    Color(0xFF06b6d4),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _animation = ConstantTween<double>(0).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_winnerIndex != null) {
          widget.onResult(widget.players[_winnerIndex!]);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void spin() {
    if (_controller.isAnimating) return;

    final random = Random();
    _winnerIndex = random.nextInt(widget.players.length);
    
    // Each segment size in radians
    final segmentAngle = 2 * pi / widget.players.length;
    
    // Calculate the angle to land on the winner.
    // The pointer is at the top (1.5 * pi or -0.5 * pi in standard Cartesian).
    // In Flutter, 0 is at the right, and angles increase clockwise.
    // To land a segment under the top pointer (at -pi/2), we need to rotate the wheel
    // so that the winner segment's center is at -pi/2.
    // Winner segment starts at _winnerIndex * segmentAngle and ends at (_winnerIndex + 1) * segmentAngle.
    // Center of winner segment: (_winnerIndex + 0.5) * segmentAngle.
    // Rotation needed: -pi/2 - ((_winnerIndex + 0.5) * segmentAngle).
    
    final targetWinnerAngle = -(pi / 2) - ((_winnerIndex! + 0.5) * segmentAngle);
    
    // Add multiple full rotations (3 to 6) for effect
    final fullRotations = (3 + random.nextInt(4)) * 2 * pi;
    final totalRotation = targetWinnerAngle - fullRotations;

    _animation = Tween<double>(
      begin: _currentRotation,
      end: totalRotation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    ));

    _currentRotation = totalRotation % (2 * pi);
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.arrow_drop_down_rounded,
          color: AppColors.gold,
          size: 48,
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value,
              child: child,
            );
          },
          child: CustomPaint(
            size: const Size(280, 280),
            painter: _WheelPainter(
              players: widget.players,
              colors: _segmentColors,
            ),
          ),
        ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.players, required this.colors});

  final List<String> players;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final segmentAngle = 2 * pi / players.length;

    final paint = Paint()
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.bgPrimary.withOpacity(0.3)
      ..strokeWidth = 2;

    for (int i = 0; i < players.length; i++) {
      paint.color = colors[i % colors.length];
      
      // Draw segment
      canvas.drawArc(
        rect,
        i * segmentAngle,
        segmentAngle,
        true,
        paint,
      );

      // Draw border
      canvas.drawArc(
        rect,
        i * segmentAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      // Draw text
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * segmentAngle + segmentAngle / 2);
      
      final textSpan = TextSpan(
        text: players[i],
        style: AppTextStyles.bodyStrong.copyWith(
          color: Colors.white,
          fontSize: players.length > 8 ? 10 : 12,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      );
      textPainter.layout(minWidth: 0, maxWidth: radius - 30);
      
      // Position text along the radius
      textPainter.paint(
        canvas,
        Offset(radius - textPainter.width - 20, -textPainter.height / 2),
      );
      
      canvas.restore();
    }

    // Center circle
    canvas.drawCircle(
      center,
      20,
      Paint()..color = AppColors.bgPrimary,
    );
    canvas.drawCircle(
      center,
      18,
      Paint()..color = AppColors.surface2,
    );
    canvas.drawCircle(
      center,
      20,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
