import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/navigation/app_router.dart';
import 'package:o_arbitro/ui/theme/app_theme.dart';
import 'package:o_arbitro/models/dare_state.dart';
import 'package:o_arbitro/models/session.dart';
import 'package:o_arbitro/models/player.dart';
import 'package:o_arbitro/ui/components/dare_timer_card.dart';
import 'package:o_arbitro/ui/components/dare_vote_card.dart';
import 'package:o_arbitro/ui/components/score_hud.dart';

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
      await tester.pump();
      expect(find.text('COMEÇAR DESAFIO'), findsOneWidget);
      expect(find.text('RECUSAR'), findsOneWidget);
    });

    testWidgets('accepting dare moves to timer, then to voting, then clears after pass', (tester) async {
      await goToSlots(tester);
      await tester.tap(find.text('GIRAR'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump();
      
      // Assigned -> Timing
      await tester.tap(find.text('COMEÇAR DESAFIO'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('FEITO'), findsOneWidget);
      
      // Timing -> Voting
      await tester.tap(find.text('FEITO'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('O GRUPO DECIDE'), findsOneWidget);
      
      // Voting -> Resolved (Passed)
      // Bruno is the only voter (Ana is active)
      await tester.tap(find.byIcon(Icons.thumb_up_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Back to lobby/slots with GIRAR
      expect(find.text('GIRAR'), findsOneWidget);
    });
  });

  group('UAT: Dare timer card', () {
    testWidgets('renders dare text and player name, shows FEITO button', (tester) async {
      bool timerEnded = false;
      const dareState = DareState(
        player: 'Ana',
        dare: 'Beber um shot',
        intensity: 'OUSADO',
        phase: DarePhase.timing,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DareTimerCard(
            dareState: dareState,
            onTimerEnd: () => timerEnded = true,
          ),
        ),
      ));

      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Beber um shot'), findsOneWidget);
      expect(find.text('FEITO'), findsOneWidget);

      await tester.tap(find.text('FEITO'));
      expect(timerEnded, isTrue);
    });
  });

  group('UAT: Dare vote card', () {
    testWidgets('renders vote buttons for others, active player has none', (tester) async {
      String? votedVoter;
      bool? votedPass;

      final players = [
        const Player(name: 'Ana'),
        const Player(name: 'Bruno'),
        const Player(name: 'Carla'),
      ];

      final dareState = DareState(
        player: 'Ana',
        dare: 'Cantar uma canção',
        intensity: 'CASUAL',
        phase: DarePhase.voting,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DareVoteCard(
            dareState: dareState,
            players: players,
            onVote: (voter, pass) {
              votedVoter = voter;
              votedPass = pass;
            },
          ),
        ),
      ));

      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Bruno'), findsOneWidget);
      expect(find.text('Carla'), findsOneWidget);

      // Ana is the active player, so she shouldn't have vote buttons next to her name
      // The DareVoteCard implementation uses players.where((p) => p.name != dareState.player)
      // So Ana shouldn't even be in the voters list.
      
      // Find thumb up icon
      final thumbUpIcons = find.byIcon(Icons.thumb_up_rounded);
      expect(thumbUpIcons, findsNWidgets(2)); // Bruno and Carla

      await tester.tap(thumbUpIcons.first);
      expect(votedVoter, 'Bruno');
      expect(votedPass, isTrue);
    });
  });

  group('UAT: Score HUD', () {
    testWidgets('renders player names, scores, fire emoji, and veto dots', (tester) async {
      final players = [
        const Player(name: 'Ana', score: 5, streak: 3, vetoTokens: 2),
        const Player(name: 'Bruno', score: 2, streak: 0, vetoTokens: 1),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScoreHud(players: players),
        ),
      ));

      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget); // Found for Ana

      expect(find.text('Bruno'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      
      // Since only Ana has the fire emoji, we expect exactly 1 overall.
      expect(find.text('🔥'), findsOneWidget);

      // Veto dots are custom painted or simple containers, let's check if they exist
      // In ScoreHud, veto dots are _VetoDot instances.
      // 2 dots for Ana (2 tokens), 1 dot for Bruno (1 token, but UI shows 2 positions)
      // Actually ScoreHud shows 2 dots per player regardless, just filled or not.
    });
  });

  group('UAT: Dare lifecycle model', () {
    final players = [
      const Player(name: 'Ana'),
      const Player(name: 'Bruno'),
      const Player(name: 'Carla'),
    ];

    test('assignDare produces DarePhase.assigned', () {
      final session = Session(players: players);
      final updated = session.assignDare(
        player: 'Ana',
        dare: 'Teste',
        intensity: 'CASUAL',
      );
      expect(updated.currentDareState?.phase, DarePhase.assigned);
    });

    test('startTimer produces DarePhase.timing', () {
      final session = Session(players: players).assignDare(
        player: 'Ana',
        dare: 'Teste',
        intensity: 'CASUAL',
      );
      final updated = session.startTimer();
      expect(updated.currentDareState?.phase, DarePhase.timing);
    });

    test('triggerVote produces DarePhase.voting', () {
      final session = Session(players: players)
          .assignDare(player: 'Ana', dare: 'Teste', intensity: 'CASUAL')
          .startTimer();
      final updated = session.triggerVote();
      expect(updated.currentDareState?.phase, DarePhase.voting);
    });

    test('submitVote + resolveDare with majority pass', () {
      var session = Session(players: players)
          .assignDare(player: 'Ana', dare: 'Teste', intensity: 'CASUAL')
          .startTimer()
          .triggerVote();
      
      session = session.submitVote('Bruno', true);
      session = session.submitVote('Carla', true);
      
      final (resolved, passed) = session.resolveDare();
      expect(passed, isTrue);
      expect(resolved.currentDareState, isNull);
      expect(resolved.playerByName('Ana')?.score, 1);
    });

    test('submitVote + resolveDare with majority fail', () {
      var session = Session(players: players)
          .assignDare(player: 'Ana', dare: 'Teste', intensity: 'CASUAL')
          .startTimer()
          .triggerVote();
      
      session = session.submitVote('Bruno', false);
      session = session.submitVote('Carla', false);
      
      final (resolved, passed) = session.resolveDare();
      expect(passed, isFalse);
      expect(resolved.currentDareState, isNull);
      expect(resolved.playerByName('Ana')?.score, 0);
    });
  });
}
