import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Text('Absurdity Ledger', style: AppTextStyles.display),
    ),
  );
}
