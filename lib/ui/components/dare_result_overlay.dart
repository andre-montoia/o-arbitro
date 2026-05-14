import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/dare_state.dart';
import '../../models/session_state.dart';
import '../../services/haptic_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'arbitro_button.dart';

class DareResultOverlay extends StatefulWidget {
  const DareResultOverlay({
    super.key,
    required this.dareState,
  });

  final DareState dareState;

  @override
  State<DareResultOverlay> createState() => _DareResultOverlayState();
}

class _DareResultOverlayState extends State<DareResultOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final AnimationController _particleCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _particleCtrl, curve: Curves.easeOut);
    
    _scaleCtrl.forward();
    _particleCtrl.forward();
    
    // Trigger celebration haptic
    final isPassed = widget.dareState.resolvedPassed ?? false;
    if (isPassed) {
      HapticService.instance.celebration();
    } else {
      HapticService.instance.failure();
    }
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPassed = widget.dareState.resolvedPassed ?? false;
    final primaryColor = isPassed ? AppColors.emerald : AppColors.danger;
    final gradient = isPassed ? AppColors.gradientSuccess : AppColors.gradientDanger;
    
    final String outcomeText = isPassed ? 'APROVADO!' : 'REPROVADO!';
    final IconData outcomeIcon = isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded;

    final sessionState = SessionState.of(context);
    final allPlayers = sessionState.session?.players.map((p) => p.name).toList() ?? [];
    final voters = allPlayers.where((p) => p != widget.dareState.player).toList();
    final passCount = voters.where((p) => widget.dareState.votes[p] == true).length;
    final failCount = voters.where((p) => widget.dareState.votes[p] == false).length;

    return AnimatedBuilder(
      animation: Listenable.merge([_scale, _fade]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Particle effects
            if (isPassed)
              ...List.generate(12, (i) => _Particle(
                animation: _fade,
                angle: (i * 30.0) * pi / 180,
                color: i % 3 == 0 ? AppColors.gold : (i % 3 == 1 ? AppColors.emerald : AppColors.pink),
                distance: 80 + (i % 4) * 20,
              )),
            // Main card
            ScaleTransition(
              scale: _scale,
              child: Container(
                margin: EdgeInsets.all(AppSpacing.lg * AppSpacing.fontScale(context)),
                padding: EdgeInsets.all(AppSpacing.xl * AppSpacing.fontScale(context)),
                decoration: BoxDecoration(
                  gradient: isPassed 
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0A1F15), Color(0xFF0C1812)],
                        )
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1F0A0A), Color(0xFF180C0C)],
                        ),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: primaryColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: AppColors.shadowDark,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Outcome icon with glow
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: gradient,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(outcomeIcon, color: Colors.white, size: 56),
                    ),
                    SizedBox(height: AppSpacing.lg * AppSpacing.fontScale(context)),
                    // Player name
                    Text(
                      widget.dareState.player,
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 22 * AppSpacing.fontScale(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Outcome text
                    Text(
                      outcomeText,
                      style: AppTextStyles.display.copyWith(
                        color: primaryColor,
                        fontSize: 36 * AppSpacing.fontScale(context),
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg * AppSpacing.fontScale(context)),
                    // Vote breakdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface2.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '$passCount ✅  ·  $failCount ❌',
                        style: AppTextStyles.bodyStrong.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 16 * AppSpacing.fontScale(context),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl * AppSpacing.fontScale(context)),
                    // Continue button
                    ArbitroButton(
                      label: 'CONTINUAR',
                      onPressed: () {
                        SessionState.of(context).dismissResult();
                      },
                      variant: isPassed 
                          ? ArbitroButtonVariant.primary 
                          : ArbitroButtonVariant.destructive,
                      fullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Particle extends StatelessWidget {
  const _Particle({
    required this.animation,
    required this.angle,
    required this.color,
    required this.distance,
  });

  final Animation<double> animation;
  final double angle;
  final Color color;
  final double distance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final dist = distance * t;
        final x = cos(angle) * dist;
        final y = sin(angle) * dist;
        final opacity = 1.0 - t;
        final size = 8.0 * (1.0 - t * 0.5);

        return Transform.translate(
          offset: Offset(x, y),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
