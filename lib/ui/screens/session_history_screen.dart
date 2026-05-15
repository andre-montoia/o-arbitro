import 'package:flutter/material.dart';
import 'package:o_arbitro/services/achievement_service.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';
import 'package:o_arbitro/ui/theme/app_text_styles.dart';
import 'package:o_arbitro/ui/theme/app_spacing.dart';
import 'package:o_arbitro/ui/components/arbitro_button.dart';
import 'package:o_arbitro/ui/components/glass_card.dart';
import 'package:o_arbitro/models/achievement.dart';

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  Map<String, dynamic> _stats = {};
  List<Achievement> _unlockedAchievements = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await AchievementService.getStats();
    final unlocked = await AchievementService.getNewlyUnlocked();
    setState(() {
      _stats = stats;
      _unlockedAchievements = unlocked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purpleDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('📊 Histórico', style: AppTextStyles.heading),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📈 Estatísticas Gerais',
                    style: AppTextStyles.heading.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildStatRow(
                    '🎮 Jogos jogados',
                    '${_stats['gamesPlayed'] ?? 0}',
                    AppColors.emerald,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildStatRow(
                    '⚡ Pontuação total',
                    '${_stats['totalScore'] ?? 0}',
                    AppColors.gold,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildStatRow(
                    '🏆 Desafios completos',
                    '${_stats['daresCompleted'] ?? 0}',
                    AppColors.pink,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '🏅 Conquistas (${_unlockedAchievements.length})',
              style: AppTextStyles.heading.copyWith(fontSize: 20),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _unlockedAchievements.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma conquista desbloqueada ainda.',
                        style: AppTextStyles.body.copyWith(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _unlockedAchievements.length,
                      itemBuilder: (context, index) {
                        final achievement = _unlockedAchievements[index];
                        return GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Text(
                                achievement.emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      achievement.title,
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      achievement.description,
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.check_circle,
                                color: AppColors.emerald,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            ArbitroButton(
              label: '🔄 Atualizar',
              onPressed: _loadData,
              variant: ArbitroButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body),
        Text(
          value,
          style: AppTextStyles.heading.copyWith(
            color: color,
            fontSize: 24,
          ),
        ),
      ],
    );
  }
}
