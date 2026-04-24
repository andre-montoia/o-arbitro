import 'package:flutter/material.dart';
import '../../data/dares.dart';
import '../../models/ledger_entry.dart';
import '../../models/session_state.dart';
import '../../models/spin_result.dart';
import '../components/arbitro_button.dart';
import '../components/dare_result_card.dart';
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
  SpinResult? _pendingResult;
  String? _currentDare;

  void _handleSpinResult(SpinResult result) {
    setState(() {
      _currentDare = Dares.random(result.category, result.intensity);
      _pendingResult = SpinResult(
        player: result.player,
        category: result.category,
        intensity: result.intensity,
        dare: _currentDare!,
        accepted: false,
      );
    });
  }

  void _onAccept() {
    if (_pendingResult == null || _currentDare == null) return;
    
    final state = SessionState.of(context);
    final finalResult = SpinResult(
      player: _pendingResult!.player,
      category: _pendingResult!.category,
      intensity: _pendingResult!.intensity,
      dare: _currentDare!,
      accepted: true,
    );

    state.addSpinResult(finalResult);
    state.completeDare(_pendingResult!.player);
    state.addLedgerEntry(ScoreEntry(
      player: _pendingResult!.player,
      source: ScoreSource.slots,
      description: _currentDare!,
    ));

    setState(() {
      _pendingResult = null;
      _currentDare = null;
    });
  }

  void _onVeto() {
    if (_pendingResult == null) return;
    
    final state = SessionState.of(context);
    state.useVeto(_pendingResult!.player);
    
    setState(() {
      _currentDare = Dares.random(_pendingResult!.category, _pendingResult!.intensity);
      _pendingResult = SpinResult(
        player: _pendingResult!.player,
        category: _pendingResult!.category,
        intensity: _pendingResult!.intensity,
        dare: _currentDare!,
        accepted: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionState.of(context).session;
    if (session == null) return const Scaffold(body: Center(child: Text('No session')));

    final player = _pendingResult != null 
        ? session.playerByName(_pendingResult!.player)
        : null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Social Slots', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.xxl),
              SlotMachine(
                key: _machineKey,
                players: session.players.map((p) => p.name).toList(),
                onResult: _handleSpinResult,
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (_pendingResult == null) ...[
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
              ] else if (player != null)
                DareResultCard(
                  dare: _currentDare!,
                  player: _pendingResult!.player,
                  intensity: _pendingResult!.intensity,
                  canVeto: player.canVeto,
                  vetoTokens: player.vetoTokens,
                  onAccept: _onAccept,
                  onVeto: _onVeto,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
