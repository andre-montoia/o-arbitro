import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/spin_result.dart';
import '../../services/haptic_service.dart';
import '../../services/sound_service.dart';
import '../theme/app_colors.dart';
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

class SlotMachineState extends State<SlotMachine>
    with TickerProviderStateMixin {
  final _reel1Key = GlobalKey<SlotReelState>();
  final _reel2Key = GlobalKey<SlotReelState>();
  final _reel3Key = GlobalKey<SlotReelState>();
  bool _isSpinning = false;
  final _random = Random();

  late final AnimationController _lightController;
  late final Animation<double> _lightAnim;
  late final AnimationController _leverController;
  late final Animation<double> _leverAnim;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _lightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..repeat(reverse: true);
    _lightAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_lightController);

    _leverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _leverAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _leverController, curve: Curves.elasticOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _lightController.dispose();
    _leverController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> spin() async {
    if (_isSpinning) return;
    setState(() => _isSpinning = true);

    _leverController.forward();
    HapticService.instance.slotSpin();
    SoundService.instance.play(GameSound.spin);
    _glowController.forward();

    final playerIdx = _random.nextInt(widget.players.length);
    final categoryIdx = _random.nextInt(_categories.length);
    final intensityIdx = _random.nextInt(_intensities.length);

    _reel1Key.currentState?.spin(playerIdx);
    await Future.delayed(const Duration(milliseconds: 200));
    _reel2Key.currentState?.spin(categoryIdx);
    await Future.delayed(const Duration(milliseconds: 200));
    _reel3Key.currentState?.spin(intensityIdx);

    await Future.delayed(const Duration(milliseconds: 1400));

    _leverController.reverse();
    _glowController.reverse();
    HapticService.instance.slotResult();

    setState(() => _isSpinning = false);

    widget.onResult(SpinResult(
      player: widget.players[playerIdx],
      category: _parseDareCategory(_categories[categoryIdx]),
      intensity: _parseDareIntensity(_intensities[intensityIdx]),
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
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnim, _pulseAnim]),
      builder: (context, child) {
        final glowIntensity = 0.2 + _glowAnim.value * 0.5;
        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.gradientSlotBody,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color.lerp(
                AppColors.slotChrome,
                AppColors.goldLight,
                _glowAnim.value * 0.7,
              )!,
              width: 2.5,
            ),
            boxShadow: [
              // Purple ambient glow
              BoxShadow(
                color: AppColors.purple.withValues(alpha: glowIntensity * 0.6),
                blurRadius: 30 + _glowAnim.value * 20,
                spreadRadius: -4 + _glowAnim.value * 4,
              ),
              // Gold rim glow
              BoxShadow(
                color: AppColors.gold.withValues(alpha: glowIntensity * 0.25),
                blurRadius: 50 + _glowAnim.value * 30,
                spreadRadius: -10,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated neon light strip
            _AnimatedLightStrip(
              animation: _isSpinning ? _lightAnim : _pulseAnim,
              isSpinning: _isSpinning,
            ),
            const SizedBox(height: 8),
            // Reel labels
            _buildReelLabels(),
            const SizedBox(height: 8),
            // Reel window + lever
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildReelWindow()),
                const SizedBox(width: 12),
                _buildLever(),
              ],
            ),
            const SizedBox(height: 12),
            // Chrome trim bar
            _buildChromeTrim(),
          ],
        ),
      ),
    );
  }

  Widget _buildReelLabels() {
    return Row(
      children: [
        _ReelLabel(icon: Icons.person_rounded, label: 'JOGADOR', color: AppColors.slotPlayer),
        const SizedBox(width: 4),
        _ReelLabel(icon: Icons.category_rounded, label: 'CATEGORIA', color: AppColors.pink),
        const SizedBox(width: 4),
        _ReelLabel(icon: Icons.speed_rounded, label: 'NÍVEL', color: AppColors.gold),
      ],
    );
  }

  Widget _buildReelWindow() {
    return Container(
      height: 156,
      decoration: BoxDecoration(
        color: AppColors.slotReelBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slotChrome, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.slotChrome.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.slotReelBg,
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Scanline overlay for CRT feel
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ScanlinePainter()),
            ),
          ),
          // Reels
          Row(
            children: [
              Expanded(
                child: SlotReel(
                  key: _reel1Key,
                  items: widget.players,
                  duration: const Duration(milliseconds: 800),
                  onTick: () {
                    if (_isSpinning) HapticService.instance.selection();
                  },
                ),
              ),
              _ReelDivider(),
              Expanded(
                child: SlotReel(
                  key: _reel2Key,
                  items: _categories,
                  duration: const Duration(milliseconds: 1000),
                  onTick: () {
                    if (_isSpinning) HapticService.instance.selection();
                  },
                ),
              ),
              _ReelDivider(),
              Expanded(
                child: SlotReel(
                  key: _reel3Key,
                  items: _intensities,
                  duration: const Duration(milliseconds: 1200),
                  onTick: () {
                    if (_isSpinning) HapticService.instance.selection();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLever() {
    return _SlotLever(
      animation: _leverAnim,
      isSpinning: _isSpinning,
    );
  }

  Widget _buildChromeTrim() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: AppColors.gradientSlotChrome.scale(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Gold rivet
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [AppColors.slotChromeLight, AppColors.slotChromeDark],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.3),
                blurRadius: 6,
                spreadRadius: -1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: AppColors.gradientSlotChrome.scale(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Reel Label
// ═══════════════════════════════════════════════════════════

class _ReelLabel extends StatelessWidget {
  const _ReelLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: color,
                fontSize: 9,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Reel Divider — thin gold line
// ═══════════════════════════════════════════════════════════

class _ReelDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.slotDivider,
            AppColors.slotChrome.withValues(alpha: 0.3),
            AppColors.slotDivider,
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Animated Light Strip — cycling neon dots
// ═══════════════════════════════════════════════════════════

class _AnimatedLightStrip extends StatelessWidget {
  const _AnimatedLightStrip({
    required this.animation,
    required this.isSpinning,
  });

  final Animation<double> animation;
  final bool isSpinning;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (i) {
            final phase = (animation.value * 7 + i) % 7;
            final brightness = isSpinning
                ? 0.4 + 0.6 * (1 - (phase / 7)).clamp(0.0, 1.0)
                : 0.3 + 0.4 * sin(animation.value * 2 * pi + i * 0.9);
            final color = AppColors.slotLights[i % AppColors.slotLights.length];
            return Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color.withValues(alpha: brightness),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: brightness * 0.5),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Slot Lever — metallic shaft with glowing pink ball
// ═══════════════════════════════════════════════════════════════════

class _SlotLever extends StatelessWidget {
  const _SlotLever({required this.animation, required this.isSpinning});

  final Animation<double> animation;
  final bool isSpinning;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = -animation.value * 0.61;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lever shaft
            Transform.rotate(
              angle: angle,
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 14,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientSlotLever,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
            // Lever ball — glowing neon pink
            Transform.rotate(
              angle: angle * 0.5,
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientSlotLeverBall,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.slotLeverBallGlow,
                      blurRadius: isSpinning ? 16 : 10,
                      spreadRadius: isSpinning ? 3 : 1,
                    ),
                  ],
                ),
              ),
            ),
            // Lever base
            Container(
              width: 20,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.slotLeverDark, AppColors.slotLever],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Scanline Painter — subtle CRT effect
// ═══════════════════════════════════════════════════════════

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
