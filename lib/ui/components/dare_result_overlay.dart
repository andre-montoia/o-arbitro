import 'package:flutter/material.dart';
import '../../models/dare_state.dart';
import '../../models/session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

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
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPassed = widget.dareState.resolvedPassed ?? false;
    final primaryColor = isPassed ? AppColors.green : AppColors.danger;
    final secondaryColor = isPassed ? const Color(0xff123524) : const Color(0xff351212);

    final String outcomeText = isPassed ? 'APROVADO!' : 'REPROVADO!';
    final IconData outcomeIcon = isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded;

    final sessionState = SessionState.of(context);
    final allPlayers = sessionState.session?.players.map((p) => p.name).toList() ?? [];
    final voters = allPlayers.where((p) => p != widget.dareState.player).toList();
    final passCount = voters.where((p) => widget.dareState.votes[p] == true).length;
    final failCount = voters.where((p) => widget.dareState.votes[p] == false).length;

    return ScaleTransition(
      scale: _scale,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(color: primaryColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: -5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(outcomeIcon, color: primaryColor, size: 80),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.dareState.player,
                style: AppTextStyles.heading.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                outcomeText,
                style: AppTextStyles.display.copyWith(color: primaryColor),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '$passCount ✅ $failCount ❌',
                style: AppTextStyles.bodyStrong.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () {
                  SessionState.of(context).dismissResult();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
                ),
                child: Text(
                  'CONTINUAR',
                  style: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
