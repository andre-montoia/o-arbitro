import 'dart:async';
import 'package:flutter/material.dart';
import 'package:o_arbitro/data/speed_dares.dart';
import 'package:o_arbitro/services/haptic_service.dart';
import 'package:o_arbitro/services/achievement_service.dart';
import 'package:o_arbitro/services/share_service.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';
import 'package:o_arbitro/ui/theme/app_text_styles.dart';
import 'package:o_arbitro/ui/theme/app_spacing.dart';
import 'package:o_arbitro/ui/components/arbitro_button.dart';
import 'package:o_arbitro/ui/components/glowing_glass_card.dart';

class SpeedDareScreen extends StatefulWidget {
  final int playerCount;

  const SpeedDareScreen({Key? key, this.playerCount = 4}) : super(key: key);

  @override
  State<SpeedDareScreen> createState() => _SpeedDareScreenState();
}

class _SpeedDareScreenState extends State<SpeedDareScreen> {
  late List<String> _shuffledDares;
  int _currentIndex = 0;
  int _streak = 0;
  int _score = 0;
  int _timeLeft = 30;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _shuffledDares = List.from(speedDares)..shuffle();
  }

  void _startTimer() {
    HapticService.instance.medium();
    setState(() {
      _isRunning = true;
      _timeLeft = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          if (_timeLeft <= 5) {
            HapticService.instance.light();
          }
        } else {
          _timer?.cancel();
          _isRunning = false;
          _showRoundEnd();
        }
      });
    });
  }

  void _completeDare() {
    HapticService.instance.heavy();
    setState(() {
      _streak++;
      _score += 10 * _streak;
      _currentIndex++;
      if (_streak % 5 == 0) {
        HapticService.instance.selection();
      }
    });
  }

  void _skipDare() {
    HapticService.instance.light();
    setState(() {
      _streak = 0;
      _currentIndex++;
    });
  }

  void _showRoundEnd() {
    AchievementService.incrementGamesPlayed();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.purpleLight,
        title: Text('⚡ Tempo Esgotado!', style: AppTextStyles.display),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pontuação: $_score', style: AppTextStyles.heading.copyWith(color: AppColors.gold)),
            const SizedBox(height: AppSpacing.md),
            Text('Maior sequência: $_streak', style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            ArbitroButton(
              label: '📤 Compartilhar',
              onPressed: () {
                ShareService.shareGameResult(
                  gameName: 'Speed Dare',
                  result: 'Pontuação: $_score',
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
    if (_currentIndex >= _shuffledDares.length) {
      return Scaffold(
        backgroundColor: AppColors.purpleDeep,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('⚡ Speed Dare', style: AppTextStyles.heading),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🎉', style: const TextStyle(fontSize: 64)),
              const SizedBox(height: AppSpacing.lg),
              Text('Todos os desafios completos!', style: AppTextStyles.heading),
              const SizedBox(height: AppSpacing.md),
              Text('Pontuação final: $_score', style: AppTextStyles.display.copyWith(color: AppColors.gold)),
            ],
          ),
        ),
      );
    }

    final dare = _shuffledDares[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.purpleDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('⚡ Speed Dare', style: AppTextStyles.heading),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pontos: $_score', style: AppTextStyles.body.copyWith(color: AppColors.gold)),
                Text('Sequência: $_streak', style: AppTextStyles.body.copyWith(color: AppColors.emerald)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: _timeLeft / 30,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(
                _timeLeft > 10 ? AppColors.emerald : AppColors.pink,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$_timeLeft s',
              style: AppTextStyles.body.copyWith(
                color: _timeLeft > 10 ? AppColors.emerald : AppColors.pink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: GlowingGlassCard(
                initialGlowColor: AppColors.pink.withOpacity(0.3),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '⚡',
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      dare,
                      style: AppTextStyles.heading.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (!_isRunning)
              ArbitroButton(
                label: '▶️ Iniciar Rodada',
                onPressed: _startTimer,
                variant: ArbitroButtonVariant.primary,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ArbitroButton(
                      label: '✅ Completou!',
                      onPressed: _completeDare,
                      variant: ArbitroButtonVariant.emerald,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ArbitroButton(
                      label: '⏭️ Pular',
                      onPressed: _skipDare,
                      variant: ArbitroButtonVariant.ghost,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
