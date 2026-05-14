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
    final sessionState = SessionState.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.modalRadius)),
      ),
      builder: (_) => SessionState(
        session: sessionState.session,
        onSessionChanged: sessionState.onSessionChanged,
        child: const PlayerSetupSheet(),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    final sessionState = SessionState.of(context);
    showDialog(
      context: context,
      builder: (ctx) => SessionState(
        session: sessionState.session,
        onSessionChanged: sessionState.onSessionChanged,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Nova Sessão?', style: AppTextStyles.heading),
          content: const Text('Todos os dados da sessão atual serão apagados.',
              style: AppTextStyles.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CANCELAR',
                  style: AppTextStyles.button.copyWith(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                sessionState.endSession();
                _showSetup(context);
              },
              child: Text('CONFIRMAR',
                  style: AppTextStyles.button.copyWith(color: AppColors.danger)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = SessionState.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientDark),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.screenPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AppBar(),
                  SizedBox(height: AppSpacing.xl * AppSpacing.fontScale(context)),
                  if (!state.hasSession) ...[
                    _NoSessionBanner(onStart: () => _showSetup(context)),
                  ] else ...[
                    _SessionBanner(
                      players: state.session!.players.map((p) => p.name).toList(),
                      onReset: () => _confirmReset(context),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _FeaturedCard(),
                    const SizedBox(height: AppSpacing.md),
                    const _SecondaryGrid(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

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
        width: 40, height: 40,
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowPurple,
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ],
        ),
        child: const Icon(Icons.sports_martial_arts, color: Colors.white, size: 20),
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
    padding: EdgeInsets.all(AppSpacing.lg * AppSpacing.fontScale(context)),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🎮', style: TextStyle(fontSize: 48)),
        const SizedBox(height: AppSpacing.sm),
        const Text('Prontos para jogar?', style: AppTextStyles.heading,
          textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xs),
        const Text('Adiciona os jogadores para começar',
          style: AppTextStyles.body, textAlign: TextAlign.center),
        SizedBox(height: AppSpacing.lg * AppSpacing.fontScale(context)),
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
              const Text('Sessão activa', style: AppTextStyles.label),
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
  const _FeaturedCard();

  @override
  Widget build(BuildContext context) => const GlassCard(
    variant: GlassCardVariant.highlighted,
    padding: EdgeInsets.all(AppSpacing.xl),
    child: Row(
      children: [
        Text('🎰', style: TextStyle(fontSize: 48)),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Social Slots', style: AppTextStyles.heading),
              SizedBox(height: AppSpacing.xs),
              Text('Consequências instantâneas', style: AppTextStyles.body),
              SizedBox(height: AppSpacing.sm),
              ArbitroBadge(label: 'Em Destaque', variant: BadgeVariant.purple),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SecondaryGrid extends StatelessWidget {
  const _SecondaryGrid();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🎡', style: TextStyle(fontSize: 32)),
              SizedBox(height: AppSpacing.sm),
              Text('Roleta do Destino', style: AppTextStyles.bodyStrong),
              SizedBox(height: AppSpacing.xs),
              Text('Destino', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
      SizedBox(width: AppSpacing.md),
      Expanded(
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📜', style: TextStyle(fontSize: 32)),
              SizedBox(height: AppSpacing.sm),
              Text('Absurdity Ledger', style: AppTextStyles.bodyStrong),
              SizedBox(height: AppSpacing.xs),
              Text('Apostas', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    ],
  );
}
