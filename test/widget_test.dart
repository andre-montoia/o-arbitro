import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/main.dart';

void main() {
  testWidgets('app launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(const OArbitroApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
