import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../components/arbitro_button.dart';
import '../components/arbitro_input.dart';
import '../components/roulette_wheel.dart';
import '../components/avatar_icon.dart';
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
      backgroundColor: AppColors.bgPrimary,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientDark),
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
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);

    final rng = Random();
    _particles = List.generate(20, (i) => _Particle(
      angle: rng.nextDouble() * 2 * pi,
      speed: 60 + rng.nextDouble() * 80,
      radius: 3 + rng.nextDouble() * 4,
      color: [AppColors.gold, AppColors.purpleLight, AppColors.pink, Colors.white][rng.nextInt(4)],
    ));

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
          color: Colors.black54,
          child: Center(
            child: ScaleTransition(
              scale: _scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) => CustomPaint(
                      size: const Size(240, 240),
                      painter: _ParticlePainter(_particles, _ctrl.value),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0x33F59E0B), Color(0x1AFBBF24)],
                      ),
                      border: Border.all(color: AppColors.gold, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Color(0x55F59E0B), blurRadius: 24)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'O DESTINO DECIDIU',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.gold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AvatarIcon(id: player.avatarId, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          widget.winner,
                          style: AppTextStyles.display.copyWith(color: Colors.white, fontSize: 32),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Particle {
  _Particle({required this.angle, required this.speed, required this.radius, required this.color});
  final double angle;
  final double speed;
  final double radius;
  final Color color;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles, this.t);
  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final p in particles) {
      final dist = p.speed * t;
      final pos = center + Offset(cos(p.angle) * dist, sin(p.angle) * dist);
      canvas.drawCircle(pos, p.radius * (1 - t * 0.5), Paint()..color = p.color.withAlpha((255 * (1 - t)).toInt()));
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}
