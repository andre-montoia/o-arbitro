import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/spin_result.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

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

class SlotMachineState extends State<SlotMachine> with TickerProviderStateMixin {
  late final AnimationController _reel1Controller;
  late final AnimationController _reel2Controller;
  late final AnimationController _reel3Controller;

  String _currentPlayer = '---';
  String _currentCategory = '---';
  String _currentIntensity = '---';
  
  bool _isSpinning = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _reel1Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _reel2Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _reel3Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _reel1Controller.addStatusListener(_onReel1StatusChanged);
    _reel2Controller.addStatusListener(_onReel2StatusChanged);
    _reel3Controller.addStatusListener(_onReel3StatusChanged);
  }

  @override
  void dispose() {
    _reel1Controller.dispose();
    _reel2Controller.dispose();
    _reel3Controller.dispose();
    super.dispose();
  }

  void _onReel1StatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && _isSpinning) {
      _reel1Controller.reset();
      _reel1Controller.forward();
      setState(() {
        _currentPlayer = widget.players[_random.nextInt(widget.players.length)];
      });
    }
  }

  void _onReel2StatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && _isSpinning) {
      _reel2Controller.reset();
      _reel2Controller.forward();
      setState(() {
        _currentCategory = _getCategoryLabel(DareCategory.values[_random.nextInt(DareCategory.values.length)]);
      });
    }
  }

  void _onReel3StatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && _isSpinning) {
      _reel3Controller.reset();
      _reel3Controller.forward();
      setState(() {
        _currentIntensity = _getIntensityLabel(DareIntensity.values[_random.nextInt(DareIntensity.values.length)]);
      });
    }
  }

  String _getCategoryLabel(DareCategory category) {
    return switch (category) {
      DareCategory.social => 'Social',
      DareCategory.fisico => 'Físico',
      DareCategory.mental => 'Mental',
      DareCategory.wild => 'Wild',
    };
  }

  String _getIntensityLabel(DareIntensity intensity) {
    return switch (intensity) {
      DareIntensity.casual => 'CASUAL',
      DareIntensity.ousado => 'OUSADO',
      DareIntensity.epico => 'ÉPICO',
    };
  }

  Color _getIntensityColor(String label) {
    return switch (label) {
      'CASUAL' => const Color(0xFF6b7280),
      'OUSADO' => const Color(0xFF3b82f6),
      'ÉPICO' => AppColors.purpleLight,
      _ => AppColors.textMuted,
    };
  }

  Future<void> spin() async {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    _reel1Controller.forward();
    _reel2Controller.forward();
    _reel3Controller.forward();

    // Final result selection
    final player = widget.players[_random.nextInt(widget.players.length)];
    final category = DareCategory.values[_random.nextInt(DareCategory.values.length)];
    final intensity = DareIntensity.values[_random.nextInt(DareIntensity.values.length)];

    await Future.delayed(const Duration(milliseconds: 2000));
    _isSpinning = false;

    setState(() {
      _currentPlayer = player;
    });
    await Future.delayed(const Duration(milliseconds: 300));
    
    setState(() {
      _currentCategory = _getCategoryLabel(category);
    });
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _currentIntensity = _getIntensityLabel(intensity);
    });

    widget.onResult(SpinResult(
      player: player,
      category: category,
      intensity: intensity,
      dare: '',
      accepted: false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SlotBox(label: 'JOGADOR', value: _currentPlayer),
        const SizedBox(width: AppSpacing.md),
        _SlotBox(label: 'CATEGORIA', value: _currentCategory),
        const SizedBox(width: AppSpacing.md),
        _SlotBox(
          label: 'NÍVEL',
          value: _currentIntensity,
          valueColor: _getIntensityColor(_currentIntensity),
        ),
      ],
    );
  }
}

class _SlotBox extends StatelessWidget {
  const _SlotBox({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: 100,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            value,
            style: AppTextStyles.bodyStrong.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
