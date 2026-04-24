import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/models/player.dart';
import 'package:o_arbitro/models/session.dart';
import 'package:o_arbitro/models/session_state.dart';
import 'package:o_arbitro/ui/screens/slots_screen.dart';
import 'package:o_arbitro/ui/theme/app_theme.dart';

void main() {
  Widget _wrap(Widget child, Session session) {
    return SessionState(
      session: session,
      onSessionChanged: (_) {},
      child: MaterialApp(
        theme: AppTheme.dark,
        home: child,
      ),
    );
  }

  testWidgets('slots screen shows GIRAR button', (WidgetTester tester) async {
    final session = Session(players: [
      const Player(name: 'Ana'),
      const Player(name: 'Bruno'),
    ]);

    await tester.pumpWidget(_wrap(const SlotsScreen(), session));

    expect(find.text('GIRAR'), findsOneWidget);
  });

  testWidgets('slots screen shows player names', (WidgetTester tester) async {
    final session = Session(players: [
      const Player(name: 'Ana'),
      const Player(name: 'Bruno'),
    ]);

    await tester.pumpWidget(_wrap(const SlotsScreen(), session));

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Bruno'), findsOneWidget);
  });
}
