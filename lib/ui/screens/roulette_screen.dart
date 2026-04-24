import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../components/arbitro_button.dart';
import '../components/arbitro_input.dart';
import '../components/glass_card.dart';
import '../components/roulette_wheel.dart';
import '../../models/session_state.dart';
import '../../models/roulette_result.dart';
import '../../models/ledger_entry.dart';

class RouletteScreen extends StatefulWidget {
  const RouletteScreen({super.key});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> {
  final _questionController = TextEditingController();
  final _wheelKey = GlobalKey<RouletteWheelState>();
  String? _winner;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _onResult(String winner) {
    final state = SessionState.of(context);
    final question = _questionController.text.isEmpty 
        ? "Decisão da Roleta" 
        : _questionController.text;

    final result = RouletteResult(
      question: question,
      winner: winner,
      timestamp: DateTime.now(),
    );

    final scoreEntry = ScoreEntry(
      player: winner,
      source: ScoreSource.roulette,
      description: question,
    );

    state.addRouletteResult(result);
    state.addLedgerEntry(scoreEntry);

    setState(() {
      _winner = winner;
    });
  }

  void _reset() {
    setState(() {
      _winner = null;
      _questionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = SessionState.of(context);
    final players = state.session?.players.map((p) => p.name).toList() ?? [];

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Roleta do Destino',
                style: AppTextStyles.display,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              ArbitroInput(
                controller: _questionController,
                hint: 'Qual a questão a decidir?',
              ),
              const SizedBox(height: AppSpacing.xxl),

              Center(
                child: RouletteWheel(
                  key: _wheelKey,
                  players: players,
                  onResult: _onResult,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              if (_winner == null)
                ArbitroButton(
                  label: 'GIRAR',
                  onPressed: () => _wheelKey.currentState?.spin(),
                  fullWidth: true,
                )
              else ...[
                GlassCard(
                  variant: GlassCardVariant.gold,
                  child: Column(
                    children: [
                      Text(
                        'O destino decidiu!',
                        style: AppTextStyles.heading.copyWith(color: AppColors.gold),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _winner!,
                        style: AppTextStyles.display.copyWith(color: AppColors.gold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ArbitroButton(
                  label: 'NOVA QUESTÃO',
                  variant: ArbitroButtonVariant.secondary,
                  onPressed: _reset,
                  fullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
