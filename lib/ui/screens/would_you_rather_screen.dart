import 'package:flutter/material.dart';
import 'package:o_arbitro/models/would_you_rather.dart';
import 'package:o_arbitro/data/would_you_rather.dart';
import 'package:o_arbitro/services/haptic_service.dart';
import 'package:o_arbitro/services/achievement_service.dart';
import 'package:o_arbitro/services/share_service.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';
import 'package:o_arbitro/ui/theme/app_text_styles.dart';
import 'package:o_arbitro/ui/theme/app_spacing.dart';
import 'package:o_arbitro/ui/components/arbitro_button.dart';
import 'package:o_arbitro/ui/components/glowing_glass_card.dart';

class WouldYouRatherScreen extends StatefulWidget {
  final int playerCount;

  const WouldYouRatherScreen({Key? key, this.playerCount = 4}) : super(key: key);

  @override
  State<WouldYouRatherScreen> createState() => _WouldYouRatherScreenState();
}

class _WouldYouRatherScreenState extends State<WouldYouRatherScreen> {
  late List<WouldYouRatherQuestion> _shuffledQuestions;
  int _currentIndex = 0;
  bool _showResult = false;
  bool? _selectedOption;

  @override
  void initState() {
    super.initState();
    _shuffledQuestions = List.from(wouldYouRatherQuestions)..shuffle();
  }

  void _vote(bool choseA) {
    if (_showResult) return;
    HapticService.instance.medium();
    setState(() {
      _selectedOption = choseA;
      _showResult = true;
      _shuffledQuestions[_currentIndex].vote('current_player', choseA);
    });
  }

  void _nextQuestion() {
    HapticService.instance.light();
    setState(() {
      if (_currentIndex < _shuffledQuestions.length - 1) {
        _currentIndex++;
        _showResult = false;
        _selectedOption = null;
      } else {
        AchievementService.incrementGamesPlayed();
        _showFinalResults();
      }
    });
  }

  void _showFinalResults() {
    AchievementService.incrementGamesPlayed();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.purpleLight,
        title: Text('🎯 Fim de Jogo!', style: AppTextStyles.display),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Obrigado por jogar!', style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Would You Rather: Chaos',
              style: AppTextStyles.heading.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: AppSpacing.md),
            ArbitroButton(
              label: '📤 Compartilhar',
              onPressed: () {
                ShareService.shareGameResult(
                  gameName: 'Would You Rather',
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
    final question = _shuffledQuestions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.purpleDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('🤔 Would You Rather', style: AppTextStyles.heading),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _shuffledQuestions.length,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.pink),
              minHeight: 6,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${_currentIndex + 1}/${_shuffledQuestions.length}',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.emerald,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  question.category.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _vote(true),
                      child: GlowingGlassCard(
                        initialGlowColor: _showResult && _selectedOption == true
                            ? AppColors.emerald
                            : AppColors.pink.withOpacity(0.3),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              question.optionA.emoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              question.optionA.text,
                              style: AppTextStyles.heading.copyWith(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            if (_showResult) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                '${question.percentageA.toStringAsFixed(0)}%',
                                style: AppTextStyles.display.copyWith(
                                  color: AppColors.gold,
                                  fontSize: 36,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'VS',
                    style: AppTextStyles.heading.copyWith(
                      color: AppColors.gold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _vote(false),
                      child: GlowingGlassCard(
                        initialGlowColor: _showResult && _selectedOption == false
                            ? AppColors.emerald
                            : AppColors.pink.withOpacity(0.3),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              question.optionB.emoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              question.optionB.text,
                              style: AppTextStyles.heading.copyWith(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            if (_showResult) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                '${question.percentageB.toStringAsFixed(0)}%',
                                style: AppTextStyles.display.copyWith(
                                  color: AppColors.gold,
                                  fontSize: 36,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_showResult)
              ArbitroButton(
                label: _currentIndex < _shuffledQuestions.length - 1
                    ? '➡️ Próxima'
                    : '🏆 Resultados',
                onPressed: _nextQuestion,
                variant: ArbitroButtonVariant.primary,
              )
            else
              Center(
                child: Text(
                  'Toque em uma opção!',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
