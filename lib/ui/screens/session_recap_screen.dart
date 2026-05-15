import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../models/session_state.dart';
import '../../services/haptic_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../components/glass_card.dart';
import '../components/arbitro_button.dart';
import '../components/avatar_icon.dart';
import '../components/animated_background.dart';
import '../components/confetti_effect.dart';

class SessionRecapScreen extends StatefulWidget {
  const SessionRecapScreen({super.key});

  @override
  State<SessionRecapScreen> createState() => _SessionRecapScreenState();
}

class _SessionRecapScreenState extends State<SessionRecapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticService.instance.celebration();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = SessionState.of(context);
    final session = state.session;

    if (session == null) return const SizedBox.shrink();

    final sortedPlayers = [...session.players]
      ..sort((a, b) => b.score.compareTo(a.score));
    
    final mvp = sortedPlayers.first;
    final totalDares = session.players.fold(0, (sum, p) => sum + p.daresCompleted);

    return Scaffold(
      body: AnimatedBackground(
        child: Stack(
          children: [
            const ConfettiEffect(count: 80),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppSpacing.screenPadding(context)),
                      child: Column(
                        children: [
                          const Text('Resumo da Sessão', style: AppTextStyles.display),
                          const SizedBox(height: AppSpacing.xxl),
                          
                          // MVP Card
                          _MVPCard(player: mvp),
                          const SizedBox(height: AppSpacing.lg),
                          
                          // Stats Row
                          Row(
                            children: [
                              Expanded(child: _StatCard(label: 'DESAFIOS', value: '$totalDares')),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: _StatCard(label: 'PONTOS', value: '${mvp.score}')),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          
                          const Text('Classificação Final', style: AppTextStyles.label),
                          const SizedBox(height: AppSpacing.md),
                          
                          ...sortedPlayers.map((p) => _RankRow(player: p, rank: sortedPlayers.indexOf(p) + 1)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.screenPadding(context)),
                    child: Column(
                      children: [
                        ArbitroButton(
                          label: 'PARTILHAR RESULTADOS',
                          onPressed: () {
                            // TODO: Implement image share
                          },
                          fullWidth: true,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: () {
                            state.endSession();
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          child: Text('SAIR', style: AppTextStyles.button.copyWith(color: AppColors.textMuted)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MVPCard extends StatelessWidget {
  const _MVPCard({required this.player});
  final Player player;

  @override
  Widget build(BuildContext context) => GlassCard(
    variant: GlassCardVariant.gold,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
    child: Column(
      children: [
        Text('🏆 MVP DA NOITE 🏆', style: AppTextStyles.label.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold, width: 2),
            boxShadow: AppSpacing.glowGold(intensity: 0.3),
          ),
          child: AvatarIcon(id: player.avatarId, size: 80),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(player.name, style: AppTextStyles.display.copyWith(fontSize: 42, color: AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: Text('${player.score} PONTOS ACUMULADOS', style: AppTextStyles.bodyStrong.copyWith(color: AppColors.gold, fontSize: 12)),
        ),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTextStyles.score),
      ],
    ),
  );
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.player, required this.rank});
  final Player player;
  final int rank;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      children: [
        Text('#$rank', style: AppTextStyles.bodyStrong.copyWith(color: AppColors.textMuted)),
        const SizedBox(width: AppSpacing.md),
        AvatarIcon(id: player.avatarId, size: 24),
        const SizedBox(width: AppSpacing.sm),
        Text(player.name, style: AppTextStyles.bodyStrong),
        const Spacer(),
        Text('${player.score} pts', style: AppTextStyles.caption),
      ],
    ),
  );
}
