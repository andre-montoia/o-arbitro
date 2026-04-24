import 'package:flutter/material.dart';
import '../../models/spin_result.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'arbitro_button.dart';
import 'glass_card.dart';

class DareResultCard extends StatelessWidget {
  const DareResultCard({
    super.key,
    required this.dare,
    required this.player,
    required this.intensity,
    required this.canVeto,
    required this.vetoTokens,
    required this.onAccept,
    required this.onVeto,
  });

  final String dare;
  final String player;
  final DareIntensity intensity;
  final bool canVeto;
  final int vetoTokens;
  final VoidCallback onAccept;
  final VoidCallback onVeto;

  @override
  Widget build(BuildContext context) {
    final isEpico = intensity == DareIntensity.epico;

    return GlassCard(
      variant: isEpico ? GlassCardVariant.highlighted : GlassCardVariant.defaultCard,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(player, style: AppTextStyles.heading),
              _IntensityBadge(intensity: intensity),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            dare,
            style: AppTextStyles.bodyStrong.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: ArbitroButton(
                  label: 'ACEITAR',
                  onPressed: onAccept,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ArbitroButton(
                  label: 'VETAR ($vetoTokens)',
                  variant: ArbitroButtonVariant.secondary,
                  onPressed: canVeto ? onVeto : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IntensityBadge extends StatelessWidget {
  const _IntensityBadge({required this.intensity});
  final DareIntensity intensity;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (intensity) {
      DareIntensity.casual => ('CASUAL', const Color(0xFF6b7280)),
      DareIntensity.ousado => ('OUSADO', const Color(0xFF3b82f6)),
      DareIntensity.epico => ('ÉPICO', AppColors.purpleLight),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}
