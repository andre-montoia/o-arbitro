import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/ui/components/arbitro_button.dart';
import 'package:o_arbitro/ui/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('primary button renders label', (tester) async {
    await tester.pumpWidget(_wrap(
      ArbitroButton(label: 'GIRAR', onPressed: () {}),
    ));
    expect(find.text('GIRAR'), findsOneWidget);
  });

  testWidgets('disabled button has reduced opacity', (tester) async {
    await tester.pumpWidget(_wrap(
      const ArbitroButton(label: 'GIRAR', onPressed: null),
    ));
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('GIRAR'), matching: find.byType(Opacity)).first,
    );
    expect(opacity.opacity, 0.5);
  });

  testWidgets('ghost variant renders', (tester) async {
    await tester.pumpWidget(_wrap(
      ArbitroButton(
        label: 'CANCELAR',
        variant: ArbitroButtonVariant.ghost,
        onPressed: () {},
      ),
    ));
    expect(find.text('CANCELAR'), findsOneWidget);
  });
}
