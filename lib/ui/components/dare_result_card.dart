import 'package:flutter/material.dart';
import '../../models/spin_result.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'arbitro_badge.dart';
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
    final (label, variant) = switch (intensity) {
      DareIntensity.casual => ('CASUAL', BadgeVariant.purple),
      DareIntensity.ousado => ('OUSADO', BadgeVariant.pink),
      DareIntensity.epico => ('ÉPICO', BadgeVariant.gold),
      DareIntensity.castigo => ('CASTIGO', BadgeVariant.pink),
    };

    return ArbitroBadge(label: label, variant: variant);
  }
}
