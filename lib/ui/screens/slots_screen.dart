import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class SlotsScreen extends StatelessWidget {
  const SlotsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Text('Social Slots', style: AppTextStyles.display),
    ),
  );
}
