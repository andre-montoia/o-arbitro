import 'package:flutter/material.dart';
import '../../data/dares.dart';
import '../../models/dare_state.dart';
import '../../models/session_state.dart';
import '../../models/spin_result.dart';
import '../../services/haptic_service.dart';
import '../../services/sound_service.dart';
import '../components/arbitro_badge.dart';
import '../components/arbitro_button.dart';
import '../components/dare_result_overlay.dart';
import '../components/dare_timer_card.dart';
import '../components/dare_vote_card.dart';
import '../components/glass_card.dart';
import '../components/slot_machine.dart';
import '../components/avatar_icon.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class SlotsScreen extends StatefulWidget {
  const SlotsScreen({super.key});

  @override
  State<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends State<SlotsScreen> {
  final GlobalKey<SlotMachineState> _machineKey = GlobalKey<SlotMachineState>();
  String? _announcedPlayer;
  int _currentPlayerIndex = 0;


  void _handleSpinResult(SpinResult result) {
    final state = SessionState.of(context);
    final session = state.session!;
    final dareText = Dares.random(result.category, result.intensity);

    final updatedSession = session
        .addSpinResult(SpinResult(
          player: result.player,
          category: result.category,
          intensity: result.intensity,
          dare: dareText,
          accepted: true,
        ))
        .assignDare(
          player: result.player,
          dare: dareText,
          intensity: _intensityLabel(result.intensity),
        );

    SoundService.instance.play(GameSound.dareAssign);
    HapticService.instance.heavy();
    state.onSessionChanged(updatedSession);
    _updateCurrentPlayerIndex(result.player);
  }

  void _updateCurrentPlayerIndex(String currentPlayerName) {
    final session = SessionState.of(context).session!;
    final index = session.players.indexWhere((p) => p.name == currentPlayerName);
    if (index != -1) {
      _currentPlayerIndex = (index + 1) % session.players.length;
    }
  }



  Future<void> _doSpin() async {
    final sessionState = SessionState.of(context);
    if (sessionState.session == null) return;

    final session = sessionState.session!;
    final nextPlayer = session.players[_currentPlayerIndex % session.players.length];
    _currentPlayerIndex++;
    setState(() => _announcedPlayer = nextPlayer.name);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _announcedPlayer = null);

    SoundService.instance.play(GameSound.spin);
    HapticService.instance.medium();
    _machineKey.currentState?.spin();
  }


  String _intensityLabel(DareIntensity intensity) => switch (intensity) {
        DareIntensity.casual => 'CASUAL',
        DareIntensity.ousado => 'OUSADO',
        DareIntensity.epico => 'ÉPICO',
        DareIntensity.castigo => 'CASTIGO',
      };
  BadgeVariant _intensityBadgeVariant(String intensity) => switch (intensity) {
        'CASUAL' => BadgeVariant.purple,
        'OUSADO' => BadgeVariant.pink,
        'ÉPICO' => BadgeVariant.gold,
        'CASTIGO' => BadgeVariant.pink,
        _ => BadgeVariant.purple,
      };

  Widget _buildDarePhaseUI(SessionState ss, DareState dareState) {
    switch (dareState.phase) {
      case DarePhase.assigned:
      case DarePhase.punishment:
        return _buildAssignedUI(ss, dareState);
      case DarePhase.timing:
        return DareTimerCard(
          dareState: dareState,
          onTimerEnd: ss.completeDareAndTriggerVote,
        );
      case DarePhase.voting:
        return DareVoteCard(
          dareState: dareState,
          players: ss.session!.players,
          onVote: ss.submitVote,
        );
      case DarePhase.resolved:
        return DareResultOverlay(
          dareState: dareState,
        );
    }
  }

  Widget _buildAssignedUI(SessionState ss, DareState dareState) {
    final isPunishment = dareState.isPunishment || dareState.phase == DarePhase.punishment;
    
    return GlassCard(
      variant: dareState.intensity == 'ÉPICO' 
          ? GlassCardVariant.highlighted 
          : GlassCardVariant.defaultCard,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dareState.player, style: AppTextStyles.heading),
              ArbitroBadge(
                label: isPunishment ? 'CASTIGO' : dareState.intensity,
                variant: isPunishment ? BadgeVariant.pink : _intensityBadgeVariant(dareState.intensity),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            dareState.dare,
            style: AppTextStyles.bodyStrong.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (isPunishment)
            ArbitroButton(
              label: 'ACEITAR CASTIGO',
              onPressed: ss.startTimer,
              fullWidth: true,
            )
          else
            Row(
              children: [
                Expanded(
                  child: ArbitroButton(
                    label: 'COMEÇAR DESAFIO',
                    onPressed: ss.startTimer,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ArbitroButton(
                    label: 'VETAR ${ss.session!.players.firstWhere((p) => p.name == dareState.player).vetoTokens}',
                    variant: ArbitroButtonVariant.ghost,
                    onPressed: ss.session!.players.firstWhere((p) => p.name == dareState.player).vetoTokens > 0
                        ? () {
                            SoundService.instance.play(GameSound.votePass);
                            HapticService.instance.medium();
                            ss.useVeto(dareState.player);
                          }
                        : null,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ss = SessionState.of(context);
    final session = ss.session;

    if (session == null || session.players.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.group_off_rounded, size: 80, color: AppColors.textDisabled),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Inicia uma sessão primeiro',
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    final dareState = session.currentDareState;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientDark),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.screenPadding(context)),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Social Slots', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.xxl),
              // Turn announcement overlay
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: _announcedPlayer == null
                    ? const SizedBox.shrink()
                    : AspectRatio(
                        aspectRatio: 16 / 9,
                        child: GlassCard(
                          variant: GlassCardVariant.highlighted,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'É A VEZ DE',
                                style: AppTextStyles.label.copyWith(
                                    color: AppColors.textContrast),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AvatarIcon(
                                    id: session.players.firstWhere((p) => p.name == _announcedPlayer).avatarId,
                                    size: 32,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Flexible(
                                    child: Text(
                                      '$_announcedPlayer!',
                                      style: AppTextStyles.display.copyWith(
                                          fontSize: 36, color: AppColors.gold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              if (dareState == null) ...[
                SlotMachine(
                  key: _machineKey,
                  players: session.players.map((p) => p.name).toList(),
                  onResult: _handleSpinResult,
                ),
                const SizedBox(height: AppSpacing.xxl),
                ArbitroButton(
                  label: 'GIRAR',
                  onPressed: _doSpin,
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text('JOGADORES', style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: session.players.map((p) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AvatarIcon(id: p.avatarId, size: 14),
                        const SizedBox(width: 8),
                        Text(p.name, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
                      ],
                    ),
                  )).toList(),
                ),
              ] else
                _buildDarePhaseUI(ss, dareState),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
