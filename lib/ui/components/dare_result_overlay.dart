import 'package:flutter/material.dart';
import '../../models/dare_state.dart';
import '../../models/session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class DareResultOverlay extends StatelessWidget {
  const DareResultOverlay({
    super.key,
    required this.dareState,
  });

  final DareState dareState;

  @override
  Widget build(BuildContext context) {
    final isPassed = dareState.resolvedPassed ?? false;
    final primaryColor = isPassed ? AppColors.green : AppColors.danger;
    final secondaryColor = isPassed ? const Color(0xff123524) : const Color(0xff351212);

    final String outcomeText = isPassed ? 'APROVADO!' : 'REPROVADO!';
    final IconData outcomeIcon = isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded;

    // Calculate vote breakdown
    final sessionState = SessionState.of(context);
    final allPlayers = sessionState.session?.players.map((p) => p.name).toList() ?? [];
    final voters = allPlayers.where((p) => p != dareState.player).toList();
    final passCount = voters.where((p) => dareState.votes[p] == true).length;
    final failCount = voters.where((p) => dareState.votes[p] == false).length;

    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
        parent: ModalRoute.of(context)!.animation!,
        curve: Curves.elasticOut,
      )),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(color: primaryColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.4),
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
                dareState.player,
                style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                outcomeText,
                style: AppTextStyles.h1.copyWith(color: primaryColor),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '$passCount ✅ $failCount ❌',
                style: AppTextStyles.bodyStrong.copyWith(color: AppColors.textSecondary),
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
