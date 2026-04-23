import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/ui/components/glass_card.dart';
import 'package:o_arbitro/ui/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('renders child content', (tester) async {
    await tester.pumpWidget(_wrap(
      const GlassCard(child: Text('test content')),
    ));
    expect(find.text('test content'), findsOneWidget);
  });

  testWidgets('gold variant renders without error', (tester) async {
    await tester.pumpWidget(_wrap(
      const GlassCard(
        variant: GlassCardVariant.gold,
        child: Text('rare'),
      ),
    ));
    expect(find.text('rare'), findsOneWidget);
  });
}
