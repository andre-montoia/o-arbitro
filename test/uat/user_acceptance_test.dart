import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/navigation/app_router.dart';
import 'package:o_arbitro/ui/theme/app_theme.dart';

Widget _app() => MaterialApp(
      theme: AppTheme.dark,
      home: const AppRouter(),
    );

void main() {
  group('UAT: Session creation flow', () {
    testWidgets('lobby shows INICIAR SESSÃO button when no session', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump();
      expect(find.text('INICIAR SESSÃO'), findsOneWidget);
    });

    testWidgets('tapping INICIAR SESSÃO opens player setup sheet', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump();
      await tester.tap(find.text('INICIAR SESSÃO'));
      await tester.pumpAndSettle();
      expect(find.text('Jogadores'), findsOneWidget);
      expect(find.text('Nome do jogador 1'), findsOneWidget);
      expect(find.text('Nome do jogador 2'), findsOneWidget);
    });

    testWidgets('entering 2 players and confirming creates session', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump();

      // Open setup sheet
      await tester.tap(find.text('INICIAR SESSÃO'));
      await tester.pumpAndSettle();

      // Enter player names
      await tester.enterText(
          find.widgetWithText(TextField, 'Nome do jogador 1'), 'Ana');
      await tester.enterText(
          find.widgetWithText(TextField, 'Nome do jogador 2'), 'Bruno');
      await tester.pump();

      // Tap confirm
      await tester.tap(find.text('INICIAR SESSÃO').last);
      await tester.pumpAndSettle();

      // Sheet should close, session banner should appear
      expect(find.text('Sessão activa'), findsOneWidget);
      expect(find.text('Ana · Bruno'), findsOneWidget);
    });

    testWidgets('cannot confirm with fewer than 2 names filled', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump();
      await tester.tap(find.text('INICIAR SESSÃO'));
      await tester.pumpAndSettle();

      // Only fill one name
      await tester.enterText(
          find.widgetWithText(TextField, 'Nome do jogador 1'), 'Ana');
      await tester.pump();

      await tester.tap(find.text('INICIAR SESSÃO').last);
      await tester.pumpAndSettle();

      // Sheet should still be open
      expect(find.text('Jogadores'), findsOneWidget);
    });
  });

  group('UAT: Navigation with session', () {
    Future<void> createSession(WidgetTester tester) async {
      await tester.pumpWidget(_app());
      await tester.pump();
      await tester.tap(find.text('INICIAR SESSÃO'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextField, 'Nome do jogador 1'), 'Ana');
      await tester.enterText(
          find.widgetWithText(TextField, 'Nome do jogador 2'), 'Bruno');
      await tester.pump();
      await tester.tap(find.text('INICIAR SESSÃO').last);
      await tester.pumpAndSettle();
    }

    testWidgets('can navigate to Slots tab after session created', (tester) async {
      await createSession(tester);
      await tester.tap(find.byIcon(Icons.casino_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Social Slots'), findsOneWidget);
      expect(find.text('GIRAR'), findsOneWidget);
    });

    testWidgets('can navigate to Roleta tab after session created', (tester) async {
      await createSession(tester);
      await tester.tap(find.byIcon(Icons.radio_button_checked_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Roleta do Destino'), findsOneWidget);
      expect(find.text('GIRAR'), findsOneWidget);
    });

    testWidgets('can navigate to Ledger tab after session created', (tester) async {
      await createSession(tester);
      await tester.tap(find.byIcon(Icons.receipt_long_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Absurdity Ledger'), findsOneWidget);
      expect(find.text('Sem entradas ainda'), findsOneWidget);
    });

    testWidgets('tabs show locked screen without session', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.casino_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Inicia uma sessão primeiro'), findsOneWidget);
    });
  });

  group('UAT: Slots spin flow', () {
    Future<void> goToSlots(WidgetTester tester) async {
      await tester.pumpWidget(_app());
      await tester.pump();
      await tester.tap(find.text('INICIAR SESSÃO'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextField, 'Nome do jogador 1'), 'Ana');
      await tester.enterText(
          find.widgetWithText(TextField, 'Nome do jogador 2'), 'Bruno');
      await tester.pump();
      await tester.tap(find.text('INICIAR SESSÃO').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.casino_rounded));
      await tester.pumpAndSettle();
    }

    testWidgets('tapping GIRAR shows dare result card', (tester) async {
      await goToSlots(tester);
      await tester.tap(find.text('GIRAR'));
      // Pump through all animation frames (reel1=600ms, reel2=750ms, reel3=900ms)
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();
      expect(find.text('ACEITAR'), findsOneWidget);
      expect(find.textContaining('VETAR'), findsOneWidget);
    });

    testWidgets('accepting dare clears the card and shows GIRAR again', (tester) async {
      await goToSlots(tester);
      await tester.tap(find.text('GIRAR'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ACEITAR'));
      await tester.pumpAndSettle();
      expect(find.text('GIRAR'), findsOneWidget);
      expect(find.text('ACEITAR'), findsNothing);
    });
  });
}
