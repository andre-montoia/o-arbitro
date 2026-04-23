import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/models/player.dart';
import 'package:o_arbitro/models/session.dart';
import 'package:o_arbitro/models/session_state.dart';
import 'package:o_arbitro/ui/screens/lobby_screen.dart';
import 'package:o_arbitro/ui/theme/app_theme.dart';

Widget _wrap(Widget child, {Session? session}) => MaterialApp(
  theme: AppTheme.dark,
  home: SessionState(
    session: session,
    onSessionChanged: (_) {},
    child: child,
  ),
);

void main() {
  testWidgets('lobby shows app logo', (tester) async {
    await tester.pumpWidget(_wrap(const LobbyScreen()));
    expect(
      find.byWidgetPredicate((w) =>
        w is RichText && w.text.toPlainText().contains('Árbitro')),
      findsOneWidget,
    );
  });

  testWidgets('lobby shows all three module cards', (tester) async {
    final session = Session(players: [
      const Player(name: 'Alice'),
      const Player(name: 'Bob'),
    ]);
    await tester.pumpWidget(_wrap(const LobbyScreen(), session: session));
    expect(find.text('Social Slots'), findsOneWidget);
    expect(find.text('Roleta do Destino'), findsOneWidget);
    expect(find.text('Absurdity Ledger'), findsOneWidget);
  });
}
