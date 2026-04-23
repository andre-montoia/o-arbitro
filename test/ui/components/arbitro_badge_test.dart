import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/ui/components/arbitro_badge.dart';
import 'package:o_arbitro/ui/theme/app_theme.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('renders label text uppercased', (tester) async {
    await tester.pumpWidget(_wrap(const ArbitroBadge(label: 'popular')));
    expect(find.text('POPULAR'), findsOneWidget);
  });

  testWidgets('gold variant uses gold colour', (tester) async {
    await tester.pumpWidget(_wrap(
      const ArbitroBadge(label: 'raro', variant: BadgeVariant.gold),
    ));
    final text = tester.widget<Text>(find.text('RARO'));
    expect(text.style?.color, AppColors.gold);
  });
}
