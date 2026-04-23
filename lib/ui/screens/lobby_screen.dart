import 'package:flutter/material.dart';
import '../../models/session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../components/glass_card.dart';
import '../components/arbitro_badge.dart';
import '../components/arbitro_button.dart';
import '../components/player_setup_sheet.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  void _showSetup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.modalRadius)),
      ),
      builder: (_) => const PlayerSetupSheet(),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Nova Sessão?', style: AppTextStyles.heading),
        content: Text('Todos os dados da sessão atual serão apagados.',
          style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCELAR', style: AppTextStyles.button.copyWith(
              color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              SessionState.of(context).endSession();
              _showSetup(context);
            },
            child: Text('CONFIRMAR', style: AppTextStyles.button.copyWith(
              color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = SessionState.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AppBar(),
              const SizedBox(height: AppSpacing.xl),
              if (!state.hasSession) ...[
                _NoSessionBanner(onStart: () => _showSetup(context)),
              ] else ...[
                _SessionBanner(
                  players: state.session!.players.map((p) => p.name).toList(),
                  onReset: () => _confirmReset(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                _FeaturedCard(),
                const SizedBox(height: AppSpacing.md),
                _SecondaryGrid(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      RichText(
        text: TextSpan(
          style: AppTextStyles.heading,
          children: [
            const TextSpan(text: 'O '),
            TextSpan(
              text: 'Árbitro',
              style: AppTextStyles.heading.copyWith(color: AppColors.purpleLight),
            ),
          ],
        ),
      ),
      Container(
        width: 36, height: 36,
        decoration: const BoxDecoration(
          gradient: AppColors.gradientPrimary,
          shape: BoxShape.circle,
        ),
      ),
    ],
  );
}

class _NoSessionBanner extends StatelessWidget {
  const _NoSessionBanner({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => GlassCard(
    variant: GlassCardVariant.highlighted,
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Column(
      children: [
        const Text('🎮', style: TextStyle(fontSize: 48)),
        const SizedBox(height: AppSpacing.md),
        Text('Prontos para jogar?', style: AppTextStyles.heading,
          textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text('Adiciona os jogadores para começar',
          style: AppTextStyles.body, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        ArbitroButton(label: 'INICIAR SESSÃO', onPressed: onStart, fullWidth: true),
      ],
    ),
  );
}

class _SessionBanner extends StatelessWidget {
  const _SessionBanner({required this.players, required this.onReset});
  final List<String> players;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sessão activa', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.xs),
              Text(players.join(' · '), style: AppTextStyles.bodyStrong),
            ],
          ),
        ),
        GestureDetector(
          onTap: onReset,
          child: const Icon(Icons.refresh_rounded, color: AppColors.textMuted),
        ),
      ],
    ),
  );
}

class _FeaturedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GlassCard(
    variant: GlassCardVariant.highlighted,
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Row(
      children: [
        const Text('🎰', style: TextStyle(fontSize: 48)),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Social Slots', style: AppTextStyles.heading),
              const SizedBox(height: AppSpacing.xs),
              Text('Consequências instantâneas', style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.sm),
              const ArbitroBadge(label: 'Em Destaque', variant: BadgeVariant.purple),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SecondaryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🎡', style: TextStyle(fontSize: 32)),
              const SizedBox(height: AppSpacing.sm),
              Text('Roleta do Destino', style: AppTextStyles.bodyStrong),
              const SizedBox(height: AppSpacing.xs),
              Text('Destino', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📜', style: TextStyle(fontSize: 32)),
              const SizedBox(height: AppSpacing.sm),
              Text('Absurdity Ledger', style: AppTextStyles.bodyStrong),
              const SizedBox(height: AppSpacing.xs),
              Text('Apostas', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    ],
  );
}
