import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

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

class SlotReelState extends State<SlotReel>
    with SingleTickerProviderStateMixin {
  static const _itemExtent = 44.0;

  late final FixedExtentScrollController _scrollController;
  late final AnimationController _animController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(
      initialItem: 0, // Start at the beginning of the infinite list
    );
    _animController = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void spin(int targetIndex) {
    final int totalItems = widget.items.length;

    // Calculate how many items to spin past to reach the target index,
    // ensuring at least a few full rotations.
    // We need to determine the offset from the *current* item to the *target* item.
    final int currentLogicalIndex = _scrollController.selectedItem % totalItems;
    final int distanceToTarget = (targetIndex - currentLogicalIndex + totalItems) % totalItems;

    // Spin for at least 5 full loops to make the animation clear and realistic
    final int destinationItem = _scrollController.selectedItem + (5 * totalItems) + distanceToTarget;

    _scrollController.animateToItem(
      destinationItem,
      duration: widget.duration,
      curve: Curves.decelerate, // Keep decelerate for realistic physics
    ).then((_) {
      setState(() {
        _currentIndex = targetIndex;
      });
      widget.onComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = widget.items.length;
    return ListWheelScrollView.useDelegate(
      controller: _scrollController,
      itemExtent: _itemExtent,
      physics: const NeverScrollableScrollPhysics(),
      perspective: 0.003,
      diameterRatio: 1.8,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: null, // infinite
        builder: (context, index) {
          final item = widget.items[index % totalItems];
          return Center(
            child: Text(
              item,
              style: AppTextStyles.bodyStrong.copyWith(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}
