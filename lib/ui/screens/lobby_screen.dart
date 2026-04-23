import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../components/glass_card.dart';
import '../components/arbitro_badge.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppBar(),
            const SizedBox(height: AppSpacing.xl),
            _FeaturedCard(),
            const SizedBox(height: AppSpacing.md),
            _SecondaryGrid(),
          ],
        ),
      ),
    ),
  );
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      RichText(
        text: TextSpan(
          style: AppTextStyles.heading,
          children: [
            const TextSpan(text: 'O '),
            TextSpan(
              text: 'Árbitro',
              style: AppTextStyles.heading.copyWith(color: AppColors.purpleLight),
            ),
          ],
        ),
      ),
      Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          gradient: AppColors.gradientPrimary,
          shape: BoxShape.circle,
        ),
      ),
    ],
  );
}

class _FeaturedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GlassCard(
    variant: GlassCardVariant.highlighted,
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Row(
      children: [
        const Text('🎰', style: TextStyle(fontSize: 48)),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Social Slots', style: AppTextStyles.heading),
              const SizedBox(height: AppSpacing.xs),
              Text('Consequências instantâneas', style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.sm),
              const ArbitroBadge(label: 'Em Destaque', variant: BadgeVariant.purple),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SecondaryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🎡', style: TextStyle(fontSize: 32)),
              const SizedBox(height: AppSpacing.sm),
              Text('Roleta do Destino', style: AppTextStyles.bodyStrong),
              const SizedBox(height: AppSpacing.xs),
              Text('Destino', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📜', style: TextStyle(fontSize: 32)),
              const SizedBox(height: AppSpacing.sm),
              Text('Absurdity Ledger', style: AppTextStyles.bodyStrong),
              const SizedBox(height: AppSpacing.xs),
              Text('Apostas', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    ],
  );
}
