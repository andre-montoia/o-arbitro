import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class RouletteScreen extends StatelessWidget {
  const RouletteScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Text('Roleta do Destino', style: AppTextStyles.display),
    ),
  );
}
