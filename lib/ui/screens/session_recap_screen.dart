import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../models/session.dart';
import '../../models/session_state.dart';
import '../../services/haptic_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../components/glass_card.dart';
import '../components/arbitro_button.dart';
import '../components/avatar_icon.dart';

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
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientDark),
        child: SafeArea(
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
      ),
    );
  }
}

class _MVPCard extends StatelessWidget {
  const _MVPCard({required this.player});
  final Player player;

  @override
  Widget build(BuildContext context) => GlassCard(
    variant: GlassCardVariant.highlighted,
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Column(
      children: [
        const Text('🏆 MVP 🏆', style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.md),
        AvatarIcon(id: player.avatarId, size: 64),
        const SizedBox(height: AppSpacing.md),
        Text(player.name, style: AppTextStyles.display.copyWith(fontSize: 32)),
        const SizedBox(height: AppSpacing.xs),
        Text('${player.score} pontos acumulados', style: AppTextStyles.body),
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
