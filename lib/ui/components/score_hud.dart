import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
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
  final Map<String, int> _prevScores = {};

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
          duration: const Duration(milliseconds: 800),
        );
        _prevScores[player.name] = player.score;
      }
    }
  }

  @override
  void didUpdateWidget(ScoreHud oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initControllers();

    for (final player in widget.players) {
      final prevScore = _prevScores[player.name] ?? 0;
      if (player.score > prevScore) {
        _flashes[player.name]?.forward(from: 0.0);
      }
      _prevScores[player.name] = player.score;
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
    final hudHeight = AppSpacing.scoreHudHeight(context);
    final fontScale = AppSpacing.fontScale(context);

    return Container(
      height: hudHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgSecondary,
            AppColors.bgPrimary,
          ],
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.players.length,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding(context) * 0.5,
        ),
        itemBuilder: (context, index) {
          final player = widget.players[index];
          final isActive = player.name == widget.activePlayer;
          final controller = _flashes[player.name];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: AnimatedBuilder(
              animation: controller ?? kAlwaysDismissedAnimation,
              builder: (context, child) {
                final flashValue = controller?.value ?? 0.0;
                final bgColor = flashValue > 0
                    ? Color.lerp(
                        AppColors.gold.withValues(alpha: 0.35),
                        Colors.transparent,
                        flashValue,
                      )
                    : (isActive
                        ? AppColors.gold.withValues(alpha: 0.12)
                        : Colors.transparent);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 100 * fontScale,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive ? AppColors.gold : AppColors.border,
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              blurRadius: 8,
                              spreadRadius: -2,
                            ),
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Player name
                      Text(
                        player.name.length > 10
                            ? '${player.name.substring(0, 10)}…'
                            : player.name,
                        style: AppTextStyles.caption.copyWith(
                          color: isActive ? AppColors.textPrimary : AppColors.textMuted,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 10 * fontScale,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      // Score with fire indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${player.score}',
                            style: AppTextStyles.bodyStrong.copyWith(
                              fontSize: 14 * fontScale,
                              color: isActive ? AppColors.gold : AppColors.textPrimary,
                            ),
                          ),
                          if (player.isOnFire) ...[
                            const SizedBox(width: 2),
                            Text(
                              '🔥',
                              style: TextStyle(fontSize: 12 * fontScale),
                            ),
                          ],
                        ],
                      ),
                      // Veto tokens
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _VetoDot(isFilled: player.vetoTokens >= 1, size: 7 * fontScale),
                          SizedBox(width: 3 * fontScale),
                          _VetoDot(isFilled: player.vetoTokens >= 2, size: 7 * fontScale),
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
  const _VetoDot({required this.isFilled, this.size = 8});
  final bool isFilled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? AppColors.purpleLight : Colors.transparent,
        border: Border.all(
          color: isFilled ? AppColors.purpleLight : AppColors.textDisabled,
          width: 1,
        ),
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: AppColors.purpleLight.withValues(alpha: 0.4),
                  blurRadius: 4,
                ),
              ]
            : null,
      ),
    );
  }
}
