import 'package:flutter/material.dart';
import '../../data/dares.dart';
import '../../models/dare_state.dart';
import '../../models/session_state.dart';
import '../../models/spin_result.dart';
import '../components/arbitro_badge.dart';
import '../components/arbitro_button.dart';
import '../components/dare_timer_card.dart';
import '../components/dare_vote_card.dart';
import '../components/glass_card.dart';
import '../components/slot_machine.dart';
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

    state.onSessionChanged(updatedSession);
  }

  String _intensityLabel(DareIntensity intensity) => switch (intensity) {
        DareIntensity.casual => 'CASUAL',
        DareIntensity.ousado => 'OUSADO',
        DareIntensity.epico => 'ÉPICO',
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
                    label: 'RECUSAR',
                    variant: ArbitroButtonVariant.secondary,
                    onPressed: () => ss.refuseDare(dareState.player),
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
    if (session == null) return const Scaffold(body: Center(child: Text('No session')));

    final dareState = session.currentDareState;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Social Slots', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.xxl),
              if (dareState == null) ...[
                SlotMachine(
                  key: _machineKey,
                  players: session.players.map((p) => p.name).toList(),
                  onResult: _handleSpinResult,
                ),
                const SizedBox(height: AppSpacing.xxl),
                ArbitroButton(
                  label: 'GIRAR',
                  onPressed: () => _machineKey.currentState?.spin(),
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
                    child: Text(p.name, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
                  )).toList(),
                ),
              ] else
                _buildDarePhaseUI(ss, dareState),
            ],
          ),
        ),
      ),
    );
  }
}
