import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shared avatar icon widget for all screens.
/// Eliminates the 6 duplicate _AvatarIcon classes that were copy-pasted.
///
/// Maps avatarId to emoji — will be replaced with custom 3D icons
/// per the Asset Manifest (docs/ux/ASSET_MANIFEST.md).
class AvatarIcon extends StatelessWidget {
  const AvatarIcon({super.key, required this.id, this.size = 20});

  final String id;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(_emojiFor(id), style: TextStyle(fontSize: size));
  }

  static String _emojiFor(String id) => switch (id) {
        'ace'     => '♠️',
        'joker'   => '🃏',
        'king'    => '👑',
        'shadow'  => '👤',
        'spark'   => '✨',
        'guard'   => '🛡️',
        'seer'    => '👁️',
        'gambler' => '🎲',
        _         => '👤',
      };

  /// Get the display name for an avatar id.
  static String nameFor(String id) => switch (id) {
        'ace'     => 'The Ace',
        'joker'   => 'The Joker',
        'king'    => 'The King',
        'shadow'  => 'The Shadow',
        'spark'   => 'The Spark',
        'guard'   => 'The Guard',
        'seer'    => 'The Seer',
        'gambler' => 'The Gambler',
        _         => 'Player',
      };

  /// Get the accent color for an avatar id.
  static Color colorFor(String id) => switch (id) {
        'ace'     => AppColors.purple,
        'joker'   => AppColors.pink,
        'king'    => AppColors.gold,
        'shadow'  => AppColors.indigo,
        'spark'   => AppColors.magenta,
        'guard'   => AppColors.emerald,
        'seer'    => const Color(0xFF06B6D4), // cyan
        'gambler' => AppColors.amber,
        _         => AppColors.textMuted,
      };
}
