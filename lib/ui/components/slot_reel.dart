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

class SlotReelState extends State<SlotReel> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late CurvedAnimation _curved;
  int _startIndex = 0;
  int _targetIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curved = CurvedAnimation(parent: _controller, curve: Curves.decelerate);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void spin(int targetIndex) {
    _startIndex = _currentDisplayIndex.round() % widget.items.length;
    _targetIndex = targetIndex;
    _controller.forward(from: 0);
  }

  double get _currentDisplayIndex {
    final total = widget.items.length;
    // Scroll at least 2 full rotations plus the distance to target
    final distance = (_targetIndex - _startIndex + total * 3) % (total * 3);
    return _startIndex + distance * _curved.value;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      builder: (_, __) {
        final displayIdx = _currentDisplayIndex;
        final total = widget.items.length;
        final above = ((displayIdx - 1).floor() % total + total) % total;
        final center = displayIdx.round() % total;
        final below = (displayIdx.ceil() % total + total) % total;

        return ClipRect(
          child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row above
              _ReelRow(text: widget.items[above], style: _dimStyle),
              // Selected row
              Container(
                height: 44,
                decoration: const BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(color: Color(0x66A855F7), width: 1),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(widget.items[center], style: _selectedStyle),
              ),
              // Row below
              _ReelRow(text: widget.items[below], style: _dimStyle),
            ],
          ),
          ),
        );
      },
    );
  }

  static const _dimStyle = TextStyle(
    fontSize: 11,
    color: Color(0x40FFFFFF),
    fontWeight: FontWeight.w500,
  );

  static final _selectedStyle = AppTextStyles.bodyStrong.copyWith(fontSize: 15);
}

class _ReelRow extends StatelessWidget {
  const _ReelRow({required this.text, required this.style});
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 32,
        child: Center(
          child: Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      );
}
