import 'dart:math';
import 'package:flutter/material.dart';
import 'package:o_arbitro/data/dares.dart';
import 'package:o_arbitro/data/truths.dart';
import 'package:o_arbitro/services/haptic_service.dart';
import 'package:o_arbitro/services/achievement_service.dart';
import 'package:o_arbitro/services/share_service.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';
import 'package:o_arbitro/ui/theme/app_text_styles.dart';
import 'package:o_arbitro/ui/theme/app_spacing.dart';
import 'package:o_arbitro/ui/components/arbitro_button.dart';
import 'package:o_arbitro/ui/components/glass_card.dart';

class TruthOrDareWheelScreen extends StatefulWidget {
  final int playerCount;

  const TruthOrDareWheelScreen({Key? key, this.playerCount = 4}) : super(key: key);

  @override
  State<TruthOrDareWheelScreen> createState() => _TruthOrDareWheelScreenState();
}

class _TruthOrDareWheelScreenState extends State<TruthOrDareWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isSpinning = false;
  bool _isTruth = false;
  String? _selectedPrompt;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
    );
  }

  void _spinWheel() {
    if (_isSpinning) return;
    HapticService.instance.medium();
    setState(() {
      _isSpinning = true;
      _selectedPrompt = null;
      _isTruth = _random.nextBool();
    });

    final spins = 5 + _random.nextInt(3);
    final targetAngle = spins * 2 * pi + (_random.nextDouble() * 2 * pi);

    _rotationAnimation = Tween<double>(
      begin: _rotationAnimation.value,
      end: targetAngle,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
    );

    _controller.reset();
    _controller.forward().then((_) {
      HapticService.instance.heavy();
      setState(() {
        _isSpinning = false;
        _selectPrompt();
      });
    });
  }

  void _selectPrompt() {
    if (_isTruth) {
      final truths = allTruths;
      _selectedPrompt = truths[_random.nextInt(truths.length)];
    } else {
      final dares = Dares.allDares;
      _selectedPrompt = dares[_random.nextInt(dares.length)];
    }
  }

  void _completePrompt() {
    HapticService.instance.heavy();
    AchievementService.incrementDaresCompleted();
    setState(() {
      _selectedPrompt = null;
    });
  }

  void _showFinalResults() {
    AchievementService.incrementGamesPlayed();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.purpleLight,
        title: Text('🎡 Fim de Jogo!', style: AppTextStyles.display),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Obrigado por jogar!', style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Truth or Dare: Wheel',
              style: AppTextStyles.heading.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: AppSpacing.md),
            ArbitroButton(
              label: '📤 Compartilhar',
              onPressed: () {
                ShareService.shareGameResult(
                  gameName: 'Truth or Dare Wheel',
                  result: 'Jogado completo!',
                );
              },
              variant: ArbitroButtonVariant.primary,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Voltar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purpleDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('🎡 Truth or Dare', style: AppTextStyles.heading),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              _isTruth ? 'VERDADE' : 'DESAFIO',
              style: AppTextStyles.display.copyWith(
                color: _isTruth ? AppColors.emerald : AppColors.pink,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.purpleLight.withOpacity(0.3),
                              AppColors.purple.withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: _isTruth ? AppColors.emerald : AppColors.pink,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isTruth ? AppColors.emerald : AppColors.pink)
                                  .withOpacity(0.5),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _isTruth ? Icons.visibility : Icons.flash_on,
                            size: 64,
                            color: _isTruth ? AppColors.emerald : AppColors.pink,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_selectedPrompt != null)
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Text(
                      _selectedPrompt!,
                      style: AppTextStyles.heading.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ArbitroButton(
                      label: '✅ Completou!',
                      onPressed: _completePrompt,
                      variant: ArbitroButtonVariant.emerald,
                    ),
                  ],
                ),
              )
            else
              ArbitroButton(
                label: _isSpinning ? 'Girando...' : '🎡 Girar Roda',
                onPressed: _isSpinning ? null : _spinWheel,
                variant: ArbitroButtonVariant.primary,
              ),
            const SizedBox(height: AppSpacing.md),
            ArbitroButton(
              label: '🏆 Finalizar',
              onPressed: _showFinalResults,
              variant: ArbitroButtonVariant.ghost,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
