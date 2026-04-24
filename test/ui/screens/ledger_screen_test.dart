import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/models/player.dart';
import 'package:o_arbitro/models/session.dart';
import 'package:o_arbitro/models/session_state.dart';
import 'package:o_arbitro/models/ledger_entry.dart';
import 'package:o_arbitro/ui/screens/ledger_screen.dart';
import 'package:o_arbitro/ui/theme/app_theme.dart';

Widget _wrap(Session session) => MaterialApp(
      theme: AppTheme.dark,
      home: SessionState(
        session: session,
        onSessionChanged: (_) {},
        child: const LedgerScreen(),
      ),
    );

void main() {
  testWidgets('ledger shows empty state when no entries', (tester) async {
    final session =
        Session(players: [Player(name: 'Ana'), Player(name: 'Bruno')]);
    await tester.pumpWidget(_wrap(session));
    expect(find.text('Sem entradas ainda'), findsOneWidget);
  });

  testWidgets('ledger shows score entry', (tester) async {
    final session = Session(
      players: [Player(name: 'Ana'), Player(name: 'Bruno')],
      ledgerEntries: [
        ScoreEntry(
          player: 'Ana',
          source: ScoreSource.slots,
          description: 'Completou desafio',
        ),
      ],
    );
    await tester.pumpWidget(_wrap(session));
    expect(find.text('Ana'), findsWidgets);
  });
}
