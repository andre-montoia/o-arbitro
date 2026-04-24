import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/spin_result.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'slot_reel.dart';

const _categories = ['Social', 'Físico', 'Mental', 'Wild'];
const _intensities = ['CASUAL', 'OUSADO', 'ÉPICO'];


class SlotMachine extends StatefulWidget {
  const SlotMachine({
    super.key,
    required this.players,
    required this.onResult,
  });

  final List<String> players;
  final ValueChanged<SpinResult> onResult;

  @override
  State<SlotMachine> createState() => SlotMachineState();
}

class SlotMachineState extends State<SlotMachine> {
  final _reel1Key = GlobalKey<SlotReelState>();
  final _reel2Key = GlobalKey<SlotReelState>();
  final _reel3Key = GlobalKey<SlotReelState>();
  bool _isSpinning = false;
  final _random = Random();

  Future<void> spin() async {
    if (_isSpinning) return;
    setState(() => _isSpinning = true);

    final playerIdx = _random.nextInt(widget.players.length);
    final categoryIdx = _random.nextInt(_categories.length);
    final intensityIdx = _random.nextInt(_intensities.length);

    _reel1Key.currentState?.spin(playerIdx);
    await Future.delayed(const Duration(milliseconds: 150));
    _reel2Key.currentState?.spin(categoryIdx);
    await Future.delayed(const Duration(milliseconds: 150));
    _reel3Key.currentState?.spin(intensityIdx);

    // Wait for the longest reel (reel3 duration = 900ms, started 300ms late)
    await Future.delayed(const Duration(milliseconds: 1050));
    setState(() => _isSpinning = false);

    final categoryStr = _categories[categoryIdx];
    final intensityStr = _intensities[intensityIdx];

    widget.onResult(SpinResult(
      player: widget.players[playerIdx],
      category: _parseDareCategory(categoryStr),
      intensity: _parseDareIntensity(intensityStr),
      dare: '',
      accepted: false,
    ));
  }

  DareCategory _parseDareCategory(String s) => switch (s) {
        'Social' => DareCategory.social,
        'Físico' => DareCategory.fisico,
        'Mental' => DareCategory.mental,
        _ => DareCategory.wild,
      };

  DareIntensity _parseDareIntensity(String s) => switch (s) {
        'CASUAL' => DareIntensity.casual,
        'OUSADO' => DareIntensity.ousado,
        _ => DareIntensity.epico,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2a1a4e), Color(0xFF1a0a3e)],
        ),
        border: Border.all(color: AppColors.purple, width: 3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x667C3AED), blurRadius: 30, spreadRadius: -4),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reel labels
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Expanded(child: Center(child: Text('JOGADOR', style: AppTextStyles.label))),
              const SizedBox(width: 1),
              Expanded(child: Center(child: Text('CATEGORIA', style: AppTextStyles.label))),
              const SizedBox(width: 1),
              Expanded(child: Center(child: Text('NÍVEL', style: AppTextStyles.label))),
            ]),
          ),
          // Reel window
          Container(
            height: 112,
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              border: Border.all(color: AppColors.purpleLight, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                // Scanline overlay
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _ScanlinePainter()),
                  ),
                ),
                // Center highlight bar
                Positioned(
                  top: 0, bottom: 0, left: 0, right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 44, decoration: BoxDecoration(
                        color: AppColors.purple.withOpacity(0.08),
                      )),
                    ],
                  ),
                ),
                // Reels
                Row(
                  children: [
                    Expanded(
                      child: SlotReel(
                        key: _reel1Key,
                        items: widget.players,
                        duration: const Duration(milliseconds: 600),
                      ),
                    ),
                    Container(width: 1, color: AppColors.purple.withOpacity(0.4)),
                    Expanded(
                      child: SlotReel(
                        key: _reel2Key,
                        items: _categories,
                        duration: const Duration(milliseconds: 750),
                      ),
                    ),
                    Container(width: 1, color: AppColors.purple.withOpacity(0.4)),
                    Expanded(
                      child: SlotReel(
                        key: _reel3Key,
                        items: _intensities,
                        duration: const Duration(milliseconds: 900),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Decorative lever line
          Row(children: [
            Expanded(child: Container(height: 1, color: AppColors.purple.withOpacity(0.3))),
            const SizedBox(width: 12),
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                color: AppColors.purpleLight,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Container(height: 1, color: AppColors.purple.withOpacity(0.3))),
          ]),
        ],
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.purpleLight.withOpacity(0.04)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter oldDelegate) => false;
}
