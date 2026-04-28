import 'dart:math';
import 'dart:ui'; // For lerpDouble
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class RouletteWheel extends StatefulWidget {
  const RouletteWheel({
    super.key,
    required this.players,
    required this.onResult,
    this.onSpinComplete,
  });

  final List<String> players;
  final ValueChanged<String> onResult;
  final ValueChanged<String>? onSpinComplete;

  @override
  RouletteWheelState createState() => RouletteWheelState();
}

class RouletteWheelState extends State<RouletteWheel> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentRotation = 0;
  int? _winnerIndex;

  late AnimationController _ballController;
  late Animation<double> _ballAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _ballController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200), // Slightly longer than wheel
    );

    _animation = ConstantTween<double>(0).animate(_controller);
    _ballAnimation = ConstantTween<double>(0).animate(_ballController);


    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_winnerIndex != null) {
          final winner = widget.players[_winnerIndex!];
          widget.onResult(winner);
        }
      }
    });

    _ballController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_winnerIndex != null) {
          final winner = widget.players[_winnerIndex!];
          widget.onSpinComplete?.call(winner);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _ballController.dispose();
    super.dispose();
  }

  void spin() {
    if (_controller.isAnimating || _ballController.isAnimating) return;

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

    // Ball animation
    _ballAnimation = Tween<double>(begin: 0, end: totalRotation * 1.05) // counter-rotate
        .animate(CurvedAnimation(parent: _ballController, curve: Curves.easeOutCubic));
    _ballController.forward(from: 0);
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
        Stack(
          alignment: Alignment.center,
          children: [
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
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _ballController,
              builder: (context, _) {
                if (!_ballController.isAnimating && !_ballController.isCompleted) {
                  return const SizedBox.shrink();
                }
                final t = _ballController.value;
                final ballAngle = -_ballAnimation.value; // counter-rotate
                // ballRadius should lerp from outer edge to winning pocket radius
                // Wheel segments are drawn at radius * 0.92, inner chrome is radius * 0.94
                // So ball lands between 0.92 and 0.72 (as per plan instruction example)
                const double wheelCenter = 140; // half of CustomPaint size
                final ballSpawnRadius = wheelCenter * 0.92; // outer edge of segments
                final ballLandRadius = wheelCenter * 0.72; // inner edge where ball settles

                final currentBallRadius = lerpDouble(ballSpawnRadius, ballLandRadius, t)!;

                final cx = wheelCenter + currentBallRadius * cos(ballAngle);
                final cy = wheelCenter + currentBallRadius * sin(ballAngle);
            
                return Positioned(
                  left: cx - 6,
                  top: cy - 6,
                  child: Container(
                    width: 12, height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.players});

  final List<String> players;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / players.length;

    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw outer ring (dark wood) before segments
    final woodPaint = Paint()
      ..color = const Color(0xFF2C1810)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, woodPaint);

    // Draw inner chrome ring  
    final chromePaint = Paint()
      ..color = const Color(0xFF888899)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.94, chromePaint);

    // Draw segments (at radius * 0.92)
    final segmentRadius = radius * 0.92;
    final segmentRect = Rect.fromCircle(center: center, radius: segmentRadius);

    for (int i = 0; i < players.length; i++) {
            final isRed = i % 2 == 0;
            paint.color = isRed ? const Color(0xFFCC0000) : const Color(0xFF1A1A1A);
      
      // Draw segment
      canvas.drawArc(
        segmentRect, // Use segmentRect for drawing arcs
        i * segmentAngle,
        segmentAngle,
        true,
        paint,
      );

      // Draw border
      // No explicit border specified in the plan for segments,
      // but the original code had one. Let's keep a subtle one if desired,
      // or remove it. For now, removing to match classic roulette visual.
      // If needed, can add:
      // final segmentBorderPaint = Paint()
      //   ..style = PaintingStyle.stroke
      //   ..color = AppColors.bgPrimary.withAlpha((0.1 * 255).round())
      //   ..strokeWidth = 1;
      // canvas.drawArc(segmentRect, i * segmentAngle, segmentAngle, true, segmentBorderPaint);


      // Draw text
      canvas.save();
      canvas.translate(center.dx, center.dy);
      // Adjust rotation to align text properly within the segment, considering the outer ring
      canvas.rotate(i * segmentAngle + segmentAngle / 2 + pi / 2); // Rotate to bring text upright if needed
      
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
      textPainter.layout(minWidth: 0, maxWidth: segmentRadius - 30);
      
      // Position text along the radius inside the segment
      canvas.rotate(-pi / 2); // Rotate back to keep text horizontal relative to painter
      textPainter.paint(
        canvas,
        Offset(segmentRadius * 0.5 - textPainter.width / 2, -textPainter.height / 2),
      );
      
      canvas.restore();
    }

    // Center circle (unchanged from original for now)
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
