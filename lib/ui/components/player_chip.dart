import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'avatar_icon.dart';

class PlayerChip extends StatelessWidget {
  const PlayerChip({super.key, required this.player});
  final Player player;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.glassFill,
      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      border: Border.all(color: AppColors.glassBorder, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AvatarIcon(id: player.avatarId, size: 16),
        const SizedBox(width: 8),
        Text(player.name, style: AppTextStyles.bodyStrong.copyWith(fontSize: 13)),
      ],
    ),
  );
}