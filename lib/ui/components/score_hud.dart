import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ScoreHud extends StatefulWidget {
  const ScoreHud({
    super.key,
    required this.players,
    this.activePlayer,
  });

  final List<Player> players;
  final String? activePlayer;

  @override
  State<ScoreHud> createState() => _ScoreHudState();
}

class _ScoreHudState extends State<ScoreHud> with TickerProviderStateMixin {
  final Map<String, AnimationController> _flashes = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    for (final player in widget.players) {
      if (!_flashes.containsKey(player.name)) {
        _flashes[player.name] = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        );
      }
    }
  }

  @override
  void didUpdateWidget(ScoreHud oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Ensure we have controllers for all current players
    _initControllers();

    // Detect score increases
    for (final player in widget.players) {
      final oldPlayer = oldWidget.players.cast<Player?>().firstWhere(
            (p) => p?.name == player.name,
            orElse: () => null,
          );

      if (oldPlayer != null && player.score > oldPlayer.score) {
        _flashes[player.name]?.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _flashes.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.players.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final player = widget.players[index];
          final isActive = player.name == widget.activePlayer;
          final controller = _flashes[player.name];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: AnimatedBuilder(
              animation: controller ?? kAlwaysDismissedAnimation,
              builder: (context, child) {
                final flashValue = controller?.value ?? 0.0;
                final backgroundColor = flashValue > 0
                    ? Color.lerp(
                        Colors.amber.withValues(alpha: 0.4),
                        Colors.transparent,
                        flashValue,
                      )
                    : Colors.transparent;

                return Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive ? AppColors.gold : AppColors.border,
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name.length > 8
                                  ? '${player.name.substring(0, 8)}...'
                                  : player.name,
                              style: AppTextStyles.caption.copyWith(
                                color: isActive ? AppColors.textPrimary : AppColors.textMuted,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${player.score}',
                                  style: AppTextStyles.bodyStrong,
                                ),
                                if (player.isOnFire)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Text('🔥', style: TextStyle(fontSize: 12)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _VetoDot(isFilled: player.vetoTokens >= 1),
                          const SizedBox(height: 4),
                          _VetoDot(isFilled: player.vetoTokens >= 2),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _VetoDot extends StatelessWidget {
  const _VetoDot({required this.isFilled});

  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? AppColors.purple : Colors.transparent,
        border: Border.all(
          color: AppColors.purple,
          width: 1,
        ),
      ),
    );
  }
}
