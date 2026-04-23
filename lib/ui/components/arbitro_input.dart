import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

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
    ),
  );
}
