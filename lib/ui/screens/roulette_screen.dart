import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../components/arbitro_button.dart';
import '../components/arbitro_input.dart';
import '../components/roulette_wheel.dart';
import '../components/avatar_icon.dart';
import '../components/glass_card.dart';
import '../components/animated_background.dart';
import '../components/confetti_effect.dart';
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
  String? _lastWinner;
  bool _showOverlay = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _onResult(String winner) {
    final state = SessionState.of(context);
    final question = _questionController.text.isEmpty
        ? 'Decisão da Roleta'
        : _questionController.text;

    state.addRouletteResult(RouletteResult(
      question: question,
      winner: winner,
      timestamp: DateTime.now(),
    ));
    state.addLedgerEntry(ScoreEntry(
      player: winner,
      source: ScoreSource.roulette,
      description: question,
    ));
  }

  void _onSpinComplete(String winner) {
    setState(() {
      _winner = winner;
      _lastWinner = winner;
      _showOverlay = true;
    });
  }

  void _dismissOverlay() {
    setState(() => _showOverlay = false);
  }

  void _reset() {
    setState(() {
      _winner = null;
      _showOverlay = false;
      _questionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final players = SessionState.of(context).session?.players.map((p) => p.name).toList() ?? [];

    if (players.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.group_off_rounded, color: AppColors.textDisabled, size: 48),
              SizedBox(height: 16),
              Text('Inicia uma sessão primeiro', style: AppTextStyles.body),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: AnimatedBackground(
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.screenPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Roleta do Destino', style: AppTextStyles.display, textAlign: TextAlign.center),
                    SizedBox(height: AppSpacing.xxl * AppSpacing.fontScale(context)),
                    ArbitroInput(controller: _questionController, hint: 'Qual a questão a decidir?'),
                    SizedBox(height: AppSpacing.xxl * AppSpacing.fontScale(context)),
                    if (_lastWinner != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Última volta: ',
                              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                            AvatarIcon(
                              id: SessionState.of(context).session!.players.firstWhere((p) => p.name == _lastWinner).avatarId,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _lastWinner!,
                              style: AppTextStyles.bodyStrong.copyWith(color: AppColors.gold),
                            ),
                          ],
                        ),
                      ),
                    Center(
                      child: RouletteWheel(
                        key: _wheelKey,
                        players: players,
                        onResult: _onResult,
                        onSpinComplete: _onSpinComplete,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxl * AppSpacing.fontScale(context)),
                    if (_winner == null)
                      ArbitroButton(
                        label: 'GIRAR',
                        onPressed: () => _wheelKey.currentState?.spin(),
                        fullWidth: true,
                        variant: ArbitroButtonVariant.emerald,
                      )
                    else ...[
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
            if (_showOverlay && _winner != null)
              _WinnerOverlay(winner: _winner!, onDismiss: _dismissOverlay),
          ],
        ),
      ),
    );
  }
}

class _WinnerOverlay extends StatefulWidget {
  const _WinnerOverlay({required this.winner, required this.onDismiss});
  final String winner;
  final VoidCallback onDismiss;

  @override
  State<_WinnerOverlay> createState() => _WinnerOverlayState();
}

class _WinnerOverlayState extends State<_WinnerOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionState.of(context).session!;
    final player = session.players.firstWhere((p) => p.name == widget.winner);

    return GestureDetector(
      onTap: widget.onDismiss,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Stack(
            children: [
              const ConfettiEffect(),
              Center(
                child: ScaleTransition(
                  scale: _scale,
                  child: GlassCard(
                    variant: GlassCardVariant.gold,
                    margin: const EdgeInsets.all(AppSpacing.xl),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'O DESTINO DECIDIU',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.gold,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.gold, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.3),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: AvatarIcon(id: player.avatarId, size: 80),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.winner,
                          style: AppTextStyles.display.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 38,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ArbitroButton(
                          label: 'FECHAR',
                          onPressed: widget.onDismiss,
                          variant: ArbitroButtonVariant.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
