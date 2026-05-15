import 'package:flutter/material.dart';
import '../../models/session_state.dart';
import '../../models/player.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../components/glass_card.dart';
import '../components/arbitro_badge.dart';
import '../components/arbitro_button.dart';
import '../components/player_setup_sheet.dart';
import '../components/avatar_icon.dart';
import 'session_recap_screen.dart';

class LobbyScreen extends StatelessWidget {
  final void Function(int)? onGameSelected;
  const LobbyScreen({super.key, this.onGameSelected});

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
                      players: state.session!.players,
                      onReset: () => _confirmReset(context),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GestureDetector(
                      onTap: () => widget.onGameSelected?.call(1),
                      child: const _FeaturedCard(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _GamesGrid(onGameSelected: onGameSelected),
                    const SizedBox(height: AppSpacing.xl),
                    ArbitroButton(
                      label: 'TERMINAR SESSÃO',
                      variant: ArbitroButtonVariant.ghost,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SessionRecapScreen()),
                        );
                      },
                      fullWidth: true,
                    ),
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
          boxShadow: AppSpacing.glowPurple(intensity: 0.4),
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
  final List<Player> players;
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
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: players.map((p) => _PlayerChip(player: p)).toList(),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onReset,
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Icon(Icons.refresh_rounded, color: AppColors.textMuted),
          ),
        ),
      ],
    ),
  );
}

class _PlayerChip extends StatelessWidget {
  const _PlayerChip({required this.player});
  final Player player;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.surface3,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border, width: 0.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AvatarIcon(id: player.avatarId, size: 14),
        const SizedBox(width: 6),
        Text(player.name, style: AppTextStyles.bodyStrong.copyWith(fontSize: 12)),
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

class _GamesGrid extends StatelessWidget {
  final void Function(int)? onGameSelected;
  const _GamesGrid({this.onGameSelected});

  static const _games = [
    (emoji: '🎡', title: 'Roleta do Destino', subtitle: 'Destino', index: 2),
    (emoji: '📜', title: 'Absurdity Ledger', subtitle: 'Apostas', index: 3),
    (emoji: '👥', title: 'Most Likely', subtitle: 'Votação', index: 4),
    (emoji: '⚡', title: 'Speed Dare', subtitle: '30s timer', index: 5),
    (emoji: '👆', title: 'Never Have I Ever', subtitle: 'Finger tracking', index: 6),
    (emoji: '🤔', title: 'Would You Rather', subtitle: 'A/B voting', index: 7),
    (emoji: '🔄', title: 'Truth or Dare Wheel', subtitle: 'Spin-to-win', index: 8),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: _games.map((game) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - AppSpacing.screenPadding(context) * 2 - AppSpacing.md) / 2,
          child: GestureDetector(
            onTap: () => onGameSelected?.call(game.index),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(game.emoji, style: const TextStyle(fontSize: 32)),
                  SizedBox(height: AppSpacing.sm),
                  Text(game.title, style: AppTextStyles.bodyStrong),
                  SizedBox(height: AppSpacing.xs),
                  Text(game.subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
