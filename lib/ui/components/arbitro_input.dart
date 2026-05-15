import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class ArbitroInput extends StatelessWidget {
  const ArbitroInput({
    super.key,
    this.hint,
    this.label,
    this.controller,
    this.onChanged,
    this.keyboardType,
  });

  final String? hint;
  final String? label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    keyboardType: keyboardType,
    style: AppTextStyles.bodyStrong,
    decoration: InputDecoration(
      hintText: hint,
      labelText: label,
      filled: true,
      fillColor: AppColors.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: const BorderSide(color: AppColors.purpleLight, width: 1.5),
      ),
      labelStyle: AppTextStyles.body,
      hintStyle: AppTextStyles.caption,
    ),
  );
}
