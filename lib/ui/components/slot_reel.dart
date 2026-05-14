import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

class SlotReel extends StatefulWidget {
  const SlotReel({
    super.key,
    required this.items,
    required this.duration,
    this.onComplete,
  });

  final List<String> items;
  final Duration duration;
  final VoidCallback? onComplete;

  @override
  State<SlotReel> createState() => SlotReelState();
}

class SlotReelState extends State<SlotReel> {
  late final FixedExtentScrollController _scrollController;
  static const _itemExtent = 44.0;
  int _currentIndex = 0;

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
    // Spin at least 3 full rotations + land on target
    final extraSpins = 3 * total;
    final destination = _currentIndex + extraSpins + ((targetIndex - _currentIndex % total) + total) % total;
    _currentIndex = destination;

    _scrollController
        .animateTo(
          destination * _itemExtent,
          duration: widget.duration,
          curve: Curves.fastOutSlowIn,
        )
        .then((_) => widget.onComplete?.call());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.purpleLight.withValues(alpha: 0.4), width: 1),
        ),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.transparent,
            Colors.transparent,
            Colors.black,
          ],
          stops: [0.0, 0.25, 0.75, 1.0],
        ).createShader(bounds),
        blendMode: BlendMode.dstOut,
        child: ListWheelScrollView.useDelegate(
          controller: _scrollController,
          itemExtent: _itemExtent,
          physics: const NeverScrollableScrollPhysics(),
          perspective: 0.003,
          diameterRatio: 2.5,
          childDelegate: ListWheelChildLoopingListDelegate(
            children: widget.items.map((item) => _ReelItem(text: item)).toList(),
          ),
        ),
      ),
    );
  }
}

class _ReelItem extends StatelessWidget {
  const _ReelItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 44,
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.bodyStrong.copyWith(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
}