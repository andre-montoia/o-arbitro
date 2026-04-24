import 'package:flutter/material.dart';
import '../../models/dare_state.dart';
import '../../models/player.dart';
import '../../services/haptic_service.dart';
import '../../services/sound_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

class DareVoteCard extends StatelessWidget {
  const DareVoteCard({
    super.key,
    required this.dareState,
    required this.players,
    required this.onVote,
  });

  final DareState dareState;
  final List<Player> players;
  final void Function(String voter, bool pass) onVote;

  @override
  Widget build(BuildContext context) {
    final voters = players.where((p) => p.name != dareState.player).toList();
    final allVoted = dareState.allVoted(players.map((p) => p.name).toList());

    return GlassCard(
      variant: GlassCardVariant.highlighted,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(dareState.player, style: AppTextStyles.heading),
            const Spacer(),
            _CastigoBadge(isPunishment: dareState.isPunishment),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(
            dareState.dare,
            style: AppTextStyles.bodyStrong.copyWith(fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('O GRUPO DECIDE', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          ...voters.map((voter) {
            final vote = dareState.votes[voter.name];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(voter.name, style: AppTextStyles.bodyStrong),
                  ),
                  if (vote == null) ...[
                    _VoteButton(
                      icon: Icons.thumb_up_rounded,
                      color: AppColors.success,
                      onTap: () {
                        SoundService.instance.play(GameSound.votePass);
                        HapticService.instance.light();
                        onVote(voter.name, true);
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _VoteButton(
                      icon: Icons.thumb_down_rounded,
                      color: AppColors.danger,
                      onTap: () {
                        SoundService.instance.play(GameSound.voteFail);
                        HapticService.instance.medium();
                        onVote(voter.name, false);
                      },
                    ),
                  ] else
                    Icon(
                      vote ? Icons.thumb_up_rounded : Icons.thumb_down_rounded,
                      color: vote ? AppColors.success : AppColors.danger,
                      size: 24,
                    ),
                ],
              ),
            );
          }),
          if (allVoted) ...[
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                'A calcular resultado...',
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      );
}

class _CastigoBadge extends StatelessWidget {
  const _CastigoBadge({required this.isPunishment});
  final bool isPunishment;

  @override
  Widget build(BuildContext context) {
    if (!isPunishment) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Text(
        'CASTIGO',
        style: AppTextStyles.label.copyWith(
          color: AppColors.danger,
          fontSize: 10,
        ),
      ),
    );
  }
}
