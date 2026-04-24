import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ScoreHud extends StatefulWidget {
  const ScoreHud({
    super.key,
    required this.players,
    this.activePlayerName,
  });

  final List<Player> players;
  final String? activePlayerName;

  @override
  State<ScoreHud> createState() => _ScoreHudState();
}

class _ScoreHudState extends State<ScoreHud> with TickerProviderStateMixin {
  final Map<String, AnimationController> _flashes = {};
  final Map<String, int> _previousScores = {};

  @override
  void initState() {
    super.initState();
    _initializePlayers(widget.players);
  }

  @override
  void didUpdateWidget(covariant ScoreHud oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.players != oldWidget.players) {
      _initializePlayers(widget.players);
      _detectScoreIncreases(oldWidget.players, widget.players);
    }
  }

  void _initializePlayers(List<Player> currentPlayers) {
    for (var player in currentPlayers) {
      if (!_flashes.containsKey(player.name)) {
        _flashes[player.name] = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        );
        _previousScores[player.name] = player.score;
      }
    }

    // Clean up controllers for players no longer present
    _flashes.keys
        .where((name) => !currentPlayers.any((p) => p.name == name))
        .toList()
        .forEach((name) {
      _flashes[name]?.dispose();
      _flashes.remove(name);
      _previousScores.remove(name);
    });
  }

  void _detectScoreIncreases(
      List<Player> oldPlayers, List<Player> newPlayers) {
    for (var newPlayer in newPlayers) {
      final oldPlayer = oldPlayers.firstWhere(
        (p) => p.name == newPlayer.name,
        orElse: () => Player(name: newPlayer.name, score: _previousScores[newPlayer.name] ?? 0),
      );

      if (newPlayer.score > oldPlayer.score) {
        _flashes[newPlayer.name]?.reset();
        _flashes[newPlayer.name]?.forward();
      }
      _previousScores[newPlayer.name] = newPlayer.score;
    }
  }

  @override
  void dispose() {
    _flashes.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.players.length,
        itemBuilder: (context, index) {
          final player = widget.players[index];
          final bool isActive = player.name == widget.activePlayerName;

          return AnimatedBuilder(
            animation: _flashes[player.name]!,
            builder: (context, child) {
              final Color flashColor = ColorTween(
                begin: AppColors.gold.withAlpha(0),
                end: AppColors.gold.withAlpha((255 * 0.5).toInt()),
              ).animate(CurvedAnimation(
                parent: _flashes[player.name]!,
                curve: Curves.easeOut,
              )).value!;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: flashColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? AppColors.purpleLight : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Player Name
                      Text(
                        player.name.length > 8
                            ? '${player.name.substring(0, 8)}...'
                            : player.name,
                        style: AppTextStyles.bodyStrong.copyWith(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      // Score
                      Text(
                        player.score.toString(),
                        style: AppTextStyles.heading.copyWith(
                            color: AppColors.textPrimary, fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      // Streak Fire Emoji
                      if (player.isOnFire)
                        Text('🔥', style: AppTextStyles.body.copyWith(fontSize: 14)),
                      const SizedBox(width: 4),
                      // Veto Dots
                      Row(
                        children: List.generate(
                          2,
                          (dotIndex) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: Icon(
                              dotIndex < player.vetoTokens
                                  ? Icons.circle
                                  : Icons.circle_outlined,
                              color: dotIndex < player.vetoTokens
                                  ? AppColors.purple
                                  : AppColors.textMuted,
                              size: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
