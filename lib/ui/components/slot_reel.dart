import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A premium 3D slot machine reel with cylindrical perspective,
/// mechanical deceleration, and neon casino symbols.
class SlotReel extends StatefulWidget {
  const SlotReel({
    super.key,
    required this.items,
    required this.duration,
    this.onComplete,
    this.onTick,
  });

  final List<String> items;
  final Duration duration;
  final VoidCallback? onComplete;
  final VoidCallback? onTick;

  @override
  State<SlotReel> createState() => SlotReelState();
}

class SlotReelState extends State<SlotReel> {
  late final FixedExtentScrollController _scrollController;
  static const _itemExtent = 56.0;
  int _currentIndex = 0;
  int _tickCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void spin(int targetIndex) {
    final total = widget.items.length;
    final extraSpins = 5 * total;
    final destination = _currentIndex +
        extraSpins +
        ((targetIndex - _currentIndex % total) + total) % total;
    _currentIndex = destination;
    _tickCount = 0;

    _scrollController
        .animateTo(
          destination * _itemExtent,
          duration: widget.duration,
          curve: const _SlotDecelerationCurve(),
        )
        .then((_) => widget.onComplete?.call());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: AppColors.slotDivider,
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // 3D reel with cylindrical perspective
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.slotReelBg,
                AppColors.slotReelBg.withValues(alpha: 0.3),
                Colors.transparent,
                AppColors.slotReelBg.withValues(alpha: 0.3),
                AppColors.slotReelBg,
              ],
              stops: const [0.0, 0.12, 0.5, 0.88, 1.0],
            ).createShader(bounds),
            blendMode: BlendMode.dstOut,
            child: ListWheelScrollView.useDelegate(
              controller: _scrollController,
              itemExtent: _itemExtent,
              physics: const NeverScrollableScrollPhysics(),
              perspective: 0.005,
              diameterRatio: 2.0,
              onSelectedItemChanged: (index) {
                _tickCount++;
                if (_tickCount % 2 == 0) {
                  widget.onTick?.call();
                }
              },
              childDelegate: ListWheelChildLoopingListDelegate(
                children: widget.items
                    .map((item) => _ReelSymbol(text: item))
                    .toList(),
              ),
            ),
          ),
          // Top depth shadow
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.slotReelBg,
                    AppColors.slotReelBg.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom depth shadow
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.slotReelBg,
                    AppColors.slotReelBg.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Center pay line — gold neon glow
          Positioned(
            top: 50, left: 4, right: 4,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: AppColors.gold.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.slotPayLine,
                    AppColors.slotWinGlow,
                    AppColors.slotPayLine,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Reel Symbol — Neon casino-themed symbol
// ═══════════════════════════════════════════════════════════

class _ReelSymbol extends StatelessWidget {
  const _ReelSymbol({required this.text});
  final String text;

  /// Emoji icon for this symbol
  String get _icon {
    if (!_isCategory && !_isIntensity) return '🎰';
    if (text == 'Social') return '🎭';
    if (text == 'Físico') return '💪';
    if (text == 'Mental') return '🧠';
    if (text == 'Wild') return '🔥';
    if (text == 'CASUAL') return '⭐';
    if (text == 'OUSADO') return '⚡';
    if (text == 'ÉPICO') return '💎';
    return '🎰';
  }

  bool get _isCategory => ['Social', 'Físico', 'Mental', 'Wild'].contains(text);
  bool get _isIntensity => ['CASUAL', 'OUSADO', 'ÉPICO'].contains(text);

  /// Neon accent color per design system
  Color get _symbolColor {
    if (text == 'Social') return AppColors.slotSocial;
    if (text == 'Físico') return AppColors.slotFisico;
    if (text == 'Mental') return AppColors.slotMental;
    if (text == 'Wild') return AppColors.slotWild;
    if (text == 'CASUAL') return AppColors.slotCasual;
    if (text == 'OUSADO') return AppColors.slotOusado;
    if (text == 'ÉPICO') return AppColors.slotEpico;
    return AppColors.slotPlayer;
  }

  @override
  Widget build(BuildContext context) {
    final color = _symbolColor;
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Neon icon with glow
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 10,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Text(_icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 8),
          // Text with neon glow
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.bodyStrong.copyWith(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                  Shadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Slot Deceleration Curve — mimics real slot machine physics
// ═══════════════════════════════════════════════════════════

class _SlotDecelerationCurve extends Curve {
  const _SlotDecelerationCurve();

  @override
  double transformInternal(double t) {
    if (t < 0.85) {
      final adjusted = t / 0.85;
      return 1 - pow(1 - adjusted, 3).toDouble();
    } else {
      final adjusted = (t - 0.85) / 0.15;
      return 1.0 - 0.03 * sin(adjusted * pi) * (1 - adjusted);
    }
  }
}
