import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../../services/haptic_service.dart';

enum ArbitroButtonVariant { primary, secondary, ghost, destructive }

class ArbitroButton extends StatefulWidget {
  const ArbitroButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ArbitroButtonVariant.primary,
    this.fullWidth = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final ArbitroButtonVariant variant;
  final bool fullWidth;
  final bool isLoading;

  @override
  State<ArbitroButton> createState() => _ArbitroButtonState();
}

class _ArbitroButtonState extends State<ArbitroButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    Widget child = Semantics(
      button: true,
      label: widget.label,
      enabled: !isDisabled,
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: isDisabled ? null : (_) {
          setState(() => _pressed = false);
          HapticService.instance.selection();
          widget.onPressed?.call();
        },
        onTapCancel: isDisabled ? null : () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: _buildInner(),
        ),
      ),
    );

    if (isDisabled) child = Opacity(opacity: 0.5, child: child);
    if (widget.fullWidth) child = SizedBox(width: double.infinity, child: child);

    return child;
  }

  Widget _buildInner() {
    return switch (widget.variant) {
      ArbitroButtonVariant.primary     => _GradientButton(label: widget.label, isLoading: widget.isLoading),
      ArbitroButtonVariant.secondary   => _SecondaryButton(label: widget.label, isLoading: widget.isLoading),
      ArbitroButtonVariant.ghost       => _GhostButton(label: widget.label, isLoading: widget.isLoading),
      ArbitroButtonVariant.destructive => _DestructiveButton(label: widget.label, isLoading: widget.isLoading),
    };
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    child: const SizedBox(
      width: 24, // Adjust size as needed
      height: 24, // Adjust size as needed
      child: CircularProgressIndicator(
        color: AppColors.textPrimary,
        strokeWidth: 2.5,
      ),
    ),
  );
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.isLoading});
  final String label;
  final bool isLoading;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    decoration: BoxDecoration(
      gradient: AppColors.gradientPrimary,
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
    ),
    child: isLoading
        ? const _LoadingIndicator()
        : Text(label, style: AppTextStyles.button, textAlign: TextAlign.center),
  );
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.isLoading});
  final String label;
  final bool isLoading;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0x267C3AED),
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      border: Border.all(color: const Color(0x4DA855F7)),
    ),
    child: isLoading
        ? const _LoadingIndicator()
        : Text(label, style: AppTextStyles.button.copyWith(color: AppColors.purpleLight), textAlign: TextAlign.center),
  );
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.isLoading});
  final String label;
  final bool isLoading;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.surface2,
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
    ),
    child: isLoading
        ? const _LoadingIndicator()
        : Text(label, style: AppTextStyles.button.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
  );
}

class _DestructiveButton extends StatelessWidget {
  const _DestructiveButton({required this.label, required this.isLoading});
  final String label;
  final bool isLoading;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0x26EF4444),
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      border: Border.all(color: const Color(0x4DEF4444)),
    ),
    child: isLoading
        ? const _LoadingIndicator()
        : Text(label, style: AppTextStyles.button.copyWith(color: AppColors.danger), textAlign: TextAlign.center),
  );
}