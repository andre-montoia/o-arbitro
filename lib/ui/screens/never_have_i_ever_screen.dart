import 'package:flutter/material.dart';
import 'package:o_arbitro/models/never_have_i_ever.dart';
import 'package:o_arbitro/data/never_have_i_ever.dart';
import 'package:o_arbitro/services/haptic_service.dart';
import 'package:o_arbitro/services/achievement_service.dart';
import 'package:o_arbitro/services/share_service.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';
import 'package:o_arbitro/ui/theme/app_text_styles.dart';
import 'package:o_arbitro/ui/theme/app_spacing.dart';
import 'package:o_arbitro/ui/components/arbitro_button.dart';
import 'package:o_arbitro/ui/components/glass_card.dart';

class NeverHaveIEverScreen extends StatefulWidget {
  final int playerCount;

  const NeverHaveIEverScreen({Key? key, this.playerCount = 4}) : super(key: key);

  @override
  State<NeverHaveIEverScreen> createState() => _NeverHaveIEverScreenState();
}

class _NeverHaveIEverScreenState extends State<NeverHaveIEverScreen> {
  late List<NeverHaveIEverStatement> _shuffledStatements;
  int _currentIndex = 0;
  int _fingerCount = 0;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _shuffledStatements = List.from(neverHaveIEverStatements)..shuffle();
  }

  void _playerHasDoneIt() {
    HapticService.instance.light();
    setState(() {
      _fingerCount++;
    });
  }

  void _nextStatement() {
    HapticService.instance.medium();
    setState(() {
      if (_currentIndex < _shuffledStatements.length - 1) {
        _currentIndex++;
        _fingerCount = 0;
        _showResult = false;
      } else {
        AchievementService.incrementGamesPlayed();
        _showFinalResults();
      }
    });
  }

  void _showFinalResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.purpleLight,
        title: Text('🙅 Fim de Jogo!', style: AppTextStyles.display),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Obrigado por jogar!', style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Never Have I Ever',
              style: AppTextStyles.heading.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: AppSpacing.md),
            ArbitroButton(
              label: '📤 Compartilhar',
              onPressed: () {
                ShareService.shareGameResult(
                  gameName: 'Never Have I Ever',
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
    final statement = _shuffledStatements[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.purpleDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('🙅 Never Have I Ever', style: AppTextStyles.heading),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _shuffledStatements.length,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.pink),
              minHeight: 6,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${_currentIndex + 1}/${_shuffledStatements.length}',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🙅',
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      statement.text,
                      style: AppTextStyles.heading.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Quantos já fizeram?',
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Dedos levantados: $_fingerCount',
              style: AppTextStyles.body.copyWith(
                color: AppColors.gold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ArbitroButton(
                    label: '✋ Já fiz!',
                    onPressed: _playerHasDoneIt,
                    variant: ArbitroButtonVariant.destructive,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ArbitroButton(
                    label: _currentIndex < _shuffledStatements.length - 1
                        ? '➡️ Próxima'
                        : '🏆 Resultados',
                    onPressed: _nextStatement,
                    variant: ArbitroButtonVariant.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
