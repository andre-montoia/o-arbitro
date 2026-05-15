import 'package:flutter/material.dart';
import 'package:o_arbitro/models/theme_pack.dart';
import 'package:o_arbitro/services/haptic_service.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';
import 'package:o_arbitro/ui/theme/app_text_styles.dart';
import 'package:o_arbitro/ui/theme/app_spacing.dart';
import 'package:o_arbitro/ui/components/arbitro_button.dart';
import 'package:o_arbitro/ui/components/glass_card.dart';

class ThemePacksScreen extends StatefulWidget {
  const ThemePacksScreen({Key? key}) : super(key: key);

  @override
  State<ThemePacksScreen> createState() => _ThemePacksScreenState();
}

class _ThemePacksScreenState extends State<ThemePacksScreen> {
  String? _selectedPackId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purpleDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('📦 Theme Packs', style: AppTextStyles.heading),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Escolha um tema para esta sessão:',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView.builder(
                itemCount: themePacks.length,
                itemBuilder: (context, index) {
                  final pack = themePacks[index];
                  final isSelected = _selectedPackId == pack.id;
                  return GestureDetector(
                    onTap: () {
                      HapticService.instance.light();
                      setState(() {
                        _selectedPackId = isSelected ? null : pack.id;
                      });
                    },
                    child: GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.purpleLight.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: AppColors.gold, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                pack.emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pack.name,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppColors.gold : null,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  pack.description,
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${pack.dares.length} desafios • ${pack.truthPrompts.length} verdades',
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 11,
                                    color: AppColors.emerald,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppColors.gold,
                              size: 28,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_selectedPackId != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.purpleLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '📦',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Pack "${themePacks.firstWhere((p) => p.id == _selectedPackId).name}" selecionado!',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            ArbitroButton(
              label: _selectedPackId != null
                  ? '🎮 Iniciar com Tema'
                  : '⚠️ Nenhum tema selecionado',
              onPressed: _selectedPackId != null
                  ? () {
                      HapticService.instance.heavy();
                      // TODO: Pass selected pack to game screens
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tema ativado! Inicie um jogo.',
                            style: AppTextStyles.body,
                          ),
                          backgroundColor: AppColors.emerald,
                        ),
                      );
                    }
                  : null,
              variant: ArbitroButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}
