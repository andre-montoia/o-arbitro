import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/dare_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'arbitro_button.dart';
import 'glass_card.dart';

class DareTimerCard extends StatefulWidget {
  const DareTimerCard({
    super.key,
    required this.dareState,
    required this.onTimerEnd,
  });

  final DareState dareState;
  final VoidCallback onTimerEnd; // called when timer hits 0 OR player taps FEITO

  @override
  State<DareTimerCard> createState() => _DareTimerCardState();
}

class _DareTimerCardState extends State<DareTimerCard>
    with SingleTickerProviderStateMixin {
  static const _totalSeconds = 60;
  late final AnimationController _controller;
  late Timer _ticker;
  int _remaining = _totalSeconds;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _totalSeconds),
    )..forward();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        _ticker.cancel();
        widget.onTimerEnd();
      }
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _remaining > 20
        ? AppColors.purpleLight
        : _remaining > 10
            ? AppColors.gold
            : AppColors.danger;

    return GlassCard(
      variant: GlassCardVariant.highlighted,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.dareState.player, style: AppTextStyles.heading),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.dareState.dare,
            style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: 1 - _controller.value,
                  color: color,
                ),
                child: Center(
                  child: Text(
                    '$_remaining',
                    style: AppTextStyles.display.copyWith(
                      color: color,
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ArbitroButton(
            label: 'FEITO',
            onPressed: () {
              _ticker.cancel();
              widget.onTimerEnd();
            },
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});
  final double progress; // 1.0 = full ring, 0.0 = empty
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final trackPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
