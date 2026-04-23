# Game Mechanics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement all three party games (Social Slots, Roleta do Destino, Absurdity Ledger) with a shared in-memory session model.

**Architecture:** Pure in-memory state via `SessionState` (InheritedWidget) passed from `AppRouter`. No backend. Session resets on app close. Each game reads/writes to the shared session. Dare content is hardcoded in `lib/data/dares.dart`.

**Tech Stack:** Flutter 3.x, Dart, CustomPainter (roulette wheel), Flutter animation framework, no external state management packages.

---

## File Map

```
lib/
├── data/
│   └── dares.dart                    # Hardcoded dare content (60 dares)
├── models/
│   ├── player.dart                   # Player model
│   ├── session.dart                  # Session model + state
│   ├── spin_result.dart              # Slots result model
│   ├── roulette_result.dart          # Roulette result model
│   └── ledger_entry.dart             # Sealed class for ledger entries
├── navigation/
│   └── app_router.dart               # MODIFY: add SessionState, lock tabs
├── ui/
│   ├── screens/
│   │   ├── lobby_screen.dart         # MODIFY: session banner + new session flow
│   │   ├── slots_screen.dart         # REPLACE: full slot machine implementation
│   │   ├── roulette_screen.dart      # REPLACE: full roulette implementation
│   │   └── ledger_screen.dart        # REPLACE: full ledger implementation
│   └── components/
│       ├── slot_machine.dart         # 3-reel animated widget
│       ├── dare_result_card.dart     # Result card with ACEITAR/VETAR
│       ├── roulette_wheel.dart       # CustomPainter wheel widget
│       ├── player_setup_sheet.dart   # Bottom sheet for session init
│       └── new_ledger_entry_sheet.dart # Bottom sheet for ledger entries
└── main.dart                         # no change
test/
├── models/
│   ├── session_test.dart
│   ├── player_test.dart
│   └── ledger_entry_test.dart
├── data/
│   └── dares_test.dart
└── ui/
    └── screens/
        ├── slots_screen_test.dart
        └── ledger_screen_test.dart
```

---

### Task 1: Player & Session Models

**Files:**
- Create: `lib/models/player.dart`
- Create: `lib/models/session.dart`
- Create: `lib/models/spin_result.dart`
- Create: `lib/models/roulette_result.dart`
- Create: `lib/models/ledger_entry.dart`
- Test: `test/models/session_test.dart`
- Test: `test/models/player_test.dart`
- Test: `test/models/ledger_entry_test.dart`

- [ ] **Step 1: Write failing tests**

```bash
mkdir -p test/models
```

Create `test/models/player_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/models/player.dart';

void main() {
  test('player starts with 2 veto tokens and 0 dares', () {
    final p = Player(name: 'João');
    expect(p.vetoTokens, 2);
    expect(p.daresCompleted, 0);
  });

  test('player can use a veto token', () {
    final p = Player(name: 'João');
    final p2 = p.useVeto();
    expect(p2.vetoTokens, 1);
    expect(p.vetoTokens, 2); // original unchanged
  });

  test('player cannot veto when tokens exhausted', () {
    final p = Player(name: 'João', vetoTokens: 0);
    expect(p.canVeto, false);
  });
}
```

Create `test/models/session_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/models/session.dart';
import 'package:o_arbitro/models/player.dart';

void main() {
  test('session starts with empty history', () {
    final s = Session(players: [Player(name: 'Ana'), Player(name: 'Bruno')]);
    expect(s.slotsHistory.isEmpty, true);
    expect(s.rouletteHistory.isEmpty, true);
    expect(s.ledgerEntries.isEmpty, true);
  });

  test('session requires at least 2 players', () {
    expect(() => Session(players: [Player(name: 'Ana')]), throwsAssertionError);
  });

  test('session has max 8 players', () {
    final names = List.generate(9, (i) => Player(name: 'P$i'));
    expect(() => Session(players: names), throwsAssertionError);
  });

  test('session player veto updates correctly', () {
    final s = Session(players: [Player(name: 'Ana'), Player(name: 'Bruno')]);
    final s2 = s.useVeto('Ana');
    expect(s2.players.first.vetoTokens, 1);
    expect(s.players.first.vetoTokens, 2); // original unchanged
  });
}
```

Create `test/models/ledger_entry_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/models/ledger_entry.dart';

void main() {
  test('SocialBet starts as pending', () {
    final bet = SocialBet(
      description: 'Aposto que o João não aguenta 1h sem telemóvel',
      players: ['João', 'Ana'],
      consequence: 'Paga a próxima ronda',
    );
    expect(bet.status, BetStatus.pending);
    expect(bet.loser, null);
  });

  test('SocialBet can be resolved', () {
    final bet = SocialBet(
      description: 'Teste',
      players: ['João', 'Ana'],
      consequence: 'Faz 20 flexões',
    );
    final resolved = bet.resolve('João');
    expect(resolved.status, BetStatus.resolved);
    expect(resolved.loser, 'João');
  });

  test('Prediction starts unresolved with empty votes', () {
    final p = Prediction(
      description: 'Portugal ganha',
      consequence: 'Paga uma ronda',
    );
    expect(p.resolved, false);
    expect(p.votes.isEmpty, true);
  });

  test('ScoreEntry records source correctly', () {
    final s = ScoreEntry(
      player: 'Ana',
      source: ScoreSource.slots,
      description: 'Completou desafio de slots',
    );
    expect(s.source, ScoreSource.slots);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
export PATH="$PATH:/root/flutter/bin"
flutter test test/models/ 2>&1 | tail -5
```

Expected: FAIL — models not found

- [ ] **Step 3: Implement Player model**

Create `lib/models/player.dart`:
```dart
class Player {
  const Player({
    required this.name,
    this.vetoTokens = 2,
    this.daresCompleted = 0,
  });

  final String name;
  final int vetoTokens;
  final int daresCompleted;

  bool get canVeto => vetoTokens > 0;

  Player useVeto() => Player(
    name: name,
    vetoTokens: vetoTokens - 1,
    daresCompleted: daresCompleted,
  );

  Player completeDare() => Player(
    name: name,
    vetoTokens: vetoTokens,
    daresCompleted: daresCompleted + 1,
  );
}
```

- [ ] **Step 4: Implement SpinResult and RouletteResult models**

Create `lib/models/spin_result.dart`:
```dart
enum DareCategory { social, fisico, mental, wild }
enum DareIntensity { casual, ousado, epico }

class SpinResult {
  const SpinResult({
    required this.player,
    required this.category,
    required this.intensity,
    required this.dare,
    required this.accepted,
  });

  final String player;
  final DareCategory category;
  final DareIntensity intensity;
  final String dare;
  final bool accepted;
}
```

Create `lib/models/roulette_result.dart`:
```dart
class RouletteResult {
  const RouletteResult({
    required this.question,
    required this.winner,
    required this.timestamp,
  });

  final String question;
  final String winner;
  final DateTime timestamp;
}
```

- [ ] **Step 5: Implement LedgerEntry sealed class**

Create `lib/models/ledger_entry.dart`:
```dart
enum BetStatus { pending, resolved }
enum ScoreSource { slots, roulette, manual }

sealed class LedgerEntry {
  const LedgerEntry({required this.timestamp});
  final DateTime timestamp;
}

class SocialBet extends LedgerEntry {
  const SocialBet({
    required this.description,
    required this.players,
    required this.consequence,
    this.status = BetStatus.pending,
    this.loser,
    super.timestamp = const _Now(),
  });

  final String description;
  final List<String> players;
  final String consequence;
  final BetStatus status;
  final String? loser;

  SocialBet resolve(String loserName) => SocialBet(
    description: description,
    players: players,
    consequence: consequence,
    status: BetStatus.resolved,
    loser: loserName,
    timestamp: timestamp,
  );
}

class Prediction extends LedgerEntry {
  const Prediction({
    required this.description,
    required this.consequence,
    this.votes = const {},
    this.resolved = false,
    super.timestamp = const _Now(),
  });

  final String description;
  final String consequence;
  final Map<String, bool> votes;
  final bool resolved;

  Prediction withVote(String player, bool vote) => Prediction(
    description: description,
    consequence: consequence,
    votes: {...votes, player: vote},
    resolved: resolved,
    timestamp: timestamp,
  );

  Prediction resolve() => Prediction(
    description: description,
    consequence: consequence,
    votes: votes,
    resolved: true,
    timestamp: timestamp,
  );
}

class ScoreEntry extends LedgerEntry {
  const ScoreEntry({
    required this.player,
    required this.source,
    required this.description,
    super.timestamp = const _Now(),
  });

  final String player;
  final ScoreSource source;
  final String description;
}

// Helper to allow const constructors with DateTime.now()
class _Now implements DateTime {
  const _Now();
  // Dart doesn't allow const DateTime.now(), so we use a workaround:
  // timestamp fields will be set at runtime via factory constructors below.
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}
```

The `_Now` const trick won't work cleanly. Replace with proper factory constructors:

Create `lib/models/ledger_entry.dart` (final version):
```dart
enum BetStatus { pending, resolved }
enum ScoreSource { slots, roulette, manual }

sealed class LedgerEntry {
  LedgerEntry() : timestamp = DateTime.now();
  final DateTime timestamp;
}

class SocialBet extends LedgerEntry {
  SocialBet({
    required this.description,
    required this.players,
    required this.consequence,
    this.status = BetStatus.pending,
    this.loser,
  });

  final String description;
  final List<String> players;
  final String consequence;
  final BetStatus status;
  final String? loser;

  SocialBet resolve(String loserName) => SocialBet(
    description: description,
    players: players,
    consequence: consequence,
    status: BetStatus.resolved,
    loser: loserName,
  );
}

class Prediction extends LedgerEntry {
  Prediction({
    required this.description,
    required this.consequence,
    Map<String, bool>? votes,
    this.resolved = false,
  }) : votes = votes ?? {};

  final String description;
  final String consequence;
  final Map<String, bool> votes;
  final bool resolved;

  Prediction withVote(String player, bool vote) => Prediction(
    description: description,
    consequence: consequence,
    votes: {...votes, player: vote},
    resolved: resolved,
  );

  Prediction resolve() => Prediction(
    description: description,
    consequence: consequence,
    votes: votes,
    resolved: true,
  );
}

class ScoreEntry extends LedgerEntry {
  ScoreEntry({
    required this.player,
    required this.source,
    required this.description,
  });

  final String player;
  final ScoreSource source;
  final String description;
}
```

- [ ] **Step 6: Implement Session model**

Create `lib/models/session.dart`:
```dart
import 'player.dart';
import 'spin_result.dart';
import 'roulette_result.dart';
import 'ledger_entry.dart';

class Session {
  Session({
    required this.players,
    List<SpinResult>? slotsHistory,
    List<RouletteResult>? rouletteHistory,
    List<LedgerEntry>? ledgerEntries,
  })  : assert(players.length >= 2, 'Session requires at least 2 players'),
        assert(players.length <= 8, 'Session allows max 8 players'),
        slotsHistory = slotsHistory ?? [],
        rouletteHistory = rouletteHistory ?? [],
        ledgerEntries = ledgerEntries ?? [];

  final List<Player> players;
  final List<SpinResult> slotsHistory;
  final List<RouletteResult> rouletteHistory;
  final List<LedgerEntry> ledgerEntries;

  Session useVeto(String playerName) {
    final updated = players.map((p) =>
      p.name == playerName ? p.useVeto() : p,
    ).toList();
    return _copyWith(players: updated);
  }

  Session completeDare(String playerName) {
    final updated = players.map((p) =>
      p.name == playerName ? p.completeDare() : p,
    ).toList();
    return _copyWith(players: updated);
  }

  Session addSpinResult(SpinResult result) =>
    _copyWith(slotsHistory: [...slotsHistory, result]);

  Session addRouletteResult(RouletteResult result) =>
    _copyWith(rouletteHistory: [...rouletteHistory, result]);

  Session addLedgerEntry(LedgerEntry entry) =>
    _copyWith(ledgerEntries: [...ledgerEntries, entry]);

  Session updateLedgerEntry(int index, LedgerEntry updated) {
    final entries = [...ledgerEntries];
    entries[index] = updated;
    return _copyWith(ledgerEntries: entries);
  }

  Player? playerByName(String name) =>
    players.where((p) => p.name == name).firstOrNull;

  Session _copyWith({
    List<Player>? players,
    List<SpinResult>? slotsHistory,
    List<RouletteResult>? rouletteHistory,
    List<LedgerEntry>? ledgerEntries,
  }) => Session(
    players: players ?? this.players,
    slotsHistory: slotsHistory ?? this.slotsHistory,
    rouletteHistory: rouletteHistory ?? this.rouletteHistory,
    ledgerEntries: ledgerEntries ?? this.ledgerEntries,
  );
}
```

- [ ] **Step 7: Run tests to verify they pass**

```bash
export PATH="$PATH:/root/flutter/bin"
flutter test test/models/ 2>&1 | tail -8
```

Expected: All tests passed!

- [ ] **Step 8: Commit**

```bash
git add lib/models/ test/models/
git commit -m "feat: add session and game models"
```

---

### Task 2: Dare Content

**Files:**
- Create: `lib/data/dares.dart`
- Test: `test/data/dares_test.dart`

- [ ] **Step 1: Write failing test**

```bash
mkdir -p test/data
```

Create `test/data/dares_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/data/dares.dart';
import 'package:o_arbitro/models/spin_result.dart';

void main() {
  test('every category+intensity bucket has at least 5 dares', () {
    for (final cat in DareCategory.values) {
      for (final intensity in DareIntensity.values) {
        final bucket = Dares.get(cat, intensity);
        expect(bucket.length, greaterThanOrEqualTo(5),
          reason: '${cat.name}/${intensity.name} has only ${bucket.length} dares');
      }
    }
  });

  test('random dare returns a non-empty string', () {
    final dare = Dares.random(DareCategory.social, DareIntensity.casual);
    expect(dare.isNotEmpty, true);
  });

  test('all dares are non-empty strings', () {
    for (final cat in DareCategory.values) {
      for (final intensity in DareIntensity.values) {
        for (final dare in Dares.get(cat, intensity)) {
          expect(dare.isNotEmpty, true,
            reason: 'Empty dare found in ${cat.name}/${intensity.name}');
        }
      }
    }
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
export PATH="$PATH:/root/flutter/bin"
flutter test test/data/dares_test.dart 2>&1 | tail -5
```

Expected: FAIL — dares.dart not found

- [ ] **Step 3: Implement dares.dart**

```bash
mkdir -p lib/data
```

Create `lib/data/dares.dart`:
```dart
import 'dart:math';
import '../models/spin_result.dart';

abstract final class Dares {
  static final _random = Random();

  static List<String> get(DareCategory category, DareIntensity intensity) =>
    _content[category]![intensity]!;

  static String random(DareCategory category, DareIntensity intensity) {
    final bucket = get(category, intensity);
    return bucket[_random.nextInt(bucket.length)];
  }

  static const Map<DareCategory, Map<DareIntensity, List<String>>> _content = {
    DareCategory.social: {
      DareIntensity.casual: [
        'Envia uma mensagem de voz a alguém que não falas há 3 meses',
        'Mostra a última foto que tiraste ao grupo',
        'Lê a última mensagem que enviaste em voz alta',
        'Muda o teu nome no grupo para o que o grupo decidir durante 10 minutos',
        'Posta uma selfie nos stories agora mesmo',
      ],
      DareIntensity.ousado: [
        'Liga para um familiar e diz que tens uma surpresa — depois desliga',
        'Envia uma mensagem de "saudades" a um ex',
        'Muda a tua foto de perfil para o que o grupo escolher durante 1 hora',
        'Posta uma história embaraçosa tua nas redes sociais',
        'Envia um elogio sincero a alguém que não gostas muito',
      ],
      DareIntensity.epico: [
        'Conta o teu maior segredo ao grupo',
        'Mostra as últimas 10 pesquisas no Google',
        'Liga para alguém aleatório dos teus contactos e canta os parabéns',
        'Publica uma foto da infância envergonhosa no Instagram',
        'Envia uma declaração de amor exagerada a um amigo — a sério',
      ],
    },
    DareCategory.fisico: {
      DareIntensity.casual: [
        'Faz 10 agachamentos agora mesmo',
        'Mantém-te em equilíbrio numa perna durante 30 segundos',
        'Faz a tua melhor dança durante 15 segundos',
        'Imita um animal à escolha do grupo durante 20 segundos',
        'Faz 5 estrelinhas',
      ],
      DareIntensity.ousado: [
        'Faz 20 flexões agora mesmo',
        'Mantém a posição de prancha durante 1 minuto',
        'Anda de gatas pela sala duas vezes',
        'Imita um personagem famoso até o grupo adivinhar',
        'Faz o teu melhor moonwalk',
      ],
      DareIntensity.epico: [
        'Mantém-te em posição de cadeira durante 2 minutos',
        'Faz 30 abdominais sem parar',
        'Anda às cavalitas do jogador mais pesado do grupo',
        'Salta à corda (imaginária) durante 2 minutos sem parar',
        'Faz 10 burpees perfeitos',
      ],
    },
    DareCategory.mental: {
      DareIntensity.casual: [
        'Di o alfabeto ao contrário o mais rápido que conseguires',
        'Conta uma piada que o grupo ainda não conhece',
        'Nomeia 10 capitais europeias em 20 segundos',
        'Imita a voz de um membro do grupo — eles têm de adivinhar quem',
        'Diz 5 factos aleatórios sobre ti mesmo',
      ],
      DareIntensity.ousado: [
        'Responde honestamente: qual é o teu maior arrependimento?',
        'Descreve cada pessoa do grupo com apenas um adjetivo — honestamente',
        'Qual é a coisa mais embaraçosa que já fizeste? Conta tudo',
        'Se tivesses de escolher um do grupo para namorar, quem era? Porquê?',
        'O que pensas realmente de cada pessoa nesta sala?',
      ],
      DareIntensity.epico: [
        'Conta o teu maior segredo que nunca contaste a ninguém aqui',
        'Diz uma verdade desconfortável sobre alguém na sala — com respeito',
        'Qual foi o teu pior momento de vida? Partilha com o grupo',
        'Se pudesses apagar um evento da tua vida, qual era? Porquê?',
        'Confessa algo ao grupo que nunca tiveste coragem de dizer',
      ],
    },
    DareCategory.wild: {
      DareIntensity.casual: [
        'O grupo decide o teu desafio — tens 30 segundos para aceitar ou vetar',
        'Troca de lugar com a pessoa à tua esquerda e fica assim 5 minutos',
        'Fala com sotaque escolhido pelo grupo durante 3 rodadas',
        'Grita o teu nome pela janela',
        'Apresenta-te ao grupo como se fosses um personagem de série',
      ],
      DareIntensity.ousado: [
        'O grupo cria um desafio combinado — aceitas ou perdes 2 turnos',
        'Deixa o grupo desbloquear o teu telemóvel e mandar 1 mensagem a quem quiser',
        'O grupo escolhe uma música — danças sem parar até acabar',
        'Fala apenas em perguntas durante as próximas 3 rondas',
        'Trocas de roupa com alguém do grupo durante 10 minutos',
      ],
      DareIntensity.epico: [
        'O grupo decide tudo — desafio livre sem limite de tempo',
        'Deixa o grupo postar algo no teu Instagram sem ver primeiro',
        'Aceitas o próximo desafio sem saber o que é — sem veto possível',
        'O grupo escreve uma mensagem e tu envias para quem eles escolherem',
        'Ficas às ordens do grupo durante as próximas 5 rondas',
      ],
    },
  };
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
export PATH="$PATH:/root/flutter/bin"
flutter test test/data/dares_test.dart 2>&1 | tail -5
```

Expected: All tests passed!

- [ ] **Step 5: Commit**

```bash
git add lib/data/dares.dart test/data/dares_test.dart
git commit -m "feat: add hardcoded dare content (60 dares)"
```

---

### Task 3: SessionState (InheritedWidget)

**Files:**
- Create: `lib/models/session_state.dart`
- Modify: `lib/navigation/app_router.dart`

- [ ] **Step 1: Create SessionState InheritedWidget**

Create `lib/models/session_state.dart`:
```dart
import 'package:flutter/material.dart';
import 'session.dart';
import 'ledger_entry.dart';
import 'spin_result.dart';
import 'roulette_result.dart';

class SessionState extends InheritedWidget {
  const SessionState({
    super.key,
    required this.session,
    required this.onSessionChanged,
    required super.child,
  });

  final Session? session;
  final ValueChanged<Session?> onSessionChanged;

  bool get hasSession => session != null;

  static SessionState of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<SessionState>();
    assert(result != null, 'No SessionState found in context');
    return result!;
  }

  void startSession(Session s) => onSessionChanged(s);
  void endSession() => onSessionChanged(null);

  void addSpinResult(SpinResult result) {
    if (session == null) return;
    onSessionChanged(session!.addSpinResult(result));
  }

  void useVeto(String playerName) {
    if (session == null) return;
    onSessionChanged(session!.useVeto(playerName));
  }

  void completeDare(String playerName) {
    if (session == null) return;
    onSessionChanged(session!.completeDare(playerName));
  }

  void addRouletteResult(RouletteResult result) {
    if (session == null) return;
    onSessionChanged(session!.addRouletteResult(result));
  }

  void addLedgerEntry(LedgerEntry entry) {
    if (session == null) return;
    onSessionChanged(session!.addLedgerEntry(entry));
  }

  void updateLedgerEntry(int index, LedgerEntry updated) {
    if (session == null) return;
    onSessionChanged(session!.updateLedgerEntry(index, updated));
  }

  @override
  bool updateShouldNotify(SessionState oldWidget) =>
    session != oldWidget.session;
}
```

- [ ] **Step 2: Modify AppRouter to hold and provide SessionState**

Rewrite `lib/navigation/app_router.dart`:
```dart
import 'package:flutter/material.dart';
import '../models/session.dart';
import '../models/session_state.dart';
import '../ui/screens/lobby_screen.dart';
import '../ui/screens/slots_screen.dart';
import '../ui/screens/roulette_screen.dart';
import '../ui/screens/ledger_screen.dart';
import '../ui/theme/app_colors.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  int _index = 0;
  Session? _session;

  void _onSessionChanged(Session? s) => setState(() => _session = s);

  @override
  Widget build(BuildContext context) {
    return SessionState(
      session: _session,
      onSessionChanged: _onSessionChanged,
      child: Scaffold(
        body: _buildScreen(),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Lobby'),
              BottomNavigationBarItem(icon: Icon(Icons.casino_rounded), label: 'Slots'),
              BottomNavigationBarItem(icon: Icon(Icons.radio_button_checked_rounded), label: 'Roleta'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Ledger'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    if (_index == 0) return const LobbyScreen();
    if (_session == null) return _LockedScreen(tabIndex: _index);
    return switch (_index) {
      1 => const SlotsScreen(),
      2 => const RouletteScreen(),
      3 => const LedgerScreen(),
      _ => const LobbyScreen(),
    };
  }
}

class _LockedScreen extends StatelessWidget {
  const _LockedScreen({required this.tabIndex});
  final int tabIndex;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_rounded, color: AppColors.textDisabled, size: 48),
          const SizedBox(height: 16),
          Text(
            'Inicia uma sessão primeiro',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 3: Verify app compiles**

```bash
export PATH="$PATH:/root/flutter/bin"
flutter analyze lib/ 2>&1 | tail -5
```

Expected: No issues (or only info-level hints)

- [ ] **Step 4: Commit**

```bash
git add lib/models/session_state.dart lib/navigation/app_router.dart
git commit -m "feat: add SessionState InheritedWidget and locked tab gate"
```

---

### Task 4: Player Setup Sheet + Lobby Session Banner

**Files:**
- Create: `lib/ui/components/player_setup_sheet.dart`
- Modify: `lib/ui/screens/lobby_screen.dart`

- [ ] **Step 1: Implement PlayerSetupSheet**

Create `lib/ui/components/player_setup_sheet.dart`:
```dart
import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../models/session.dart';
import '../../models/session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'arbitro_button.dart';
import 'arbitro_input.dart';
import 'bottom_sheet_handle.dart';

class PlayerSetupSheet extends StatefulWidget {
  const PlayerSetupSheet({super.key});

  @override
  State<PlayerSetupSheet> createState() => _PlayerSetupSheetState();
}

class _PlayerSetupSheetState extends State<PlayerSetupSheet> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  void _addPlayer() {
    if (_controllers.length >= 8) return;
    setState(() => _controllers.add(TextEditingController()));
  }

  void _removePlayer(int index) {
    if (_controllers.length <= 2) return;
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  void _confirm() {
    final names = _controllers
      .map((c) => c.text.trim())
      .where((n) => n.isNotEmpty)
      .toList();
    if (names.length < 2) return;
    final players = names.map((n) => Player(name: n)).toList();
    final session = Session(players: players);
    SessionState.of(context).startSession(session);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BottomSheetHandle(),
        const SizedBox(height: AppSpacing.md),
        Text('Jogadores', style: AppTextStyles.heading),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(_controllers.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: ArbitroInput(
                  controller: _controllers[i],
                  hint: 'Nome do jogador ${i + 1}',
                ),
              ),
              if (_controllers.length > 2) ...[
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () => _removePlayer(i),
                  child: const Icon(Icons.remove_circle_outline,
                    color: AppColors.danger),
                ),
              ],
            ],
          ),
        )),
        if (_controllers.length < 8)
          TextButton.icon(
            onPressed: _addPlayer,
            icon: const Icon(Icons.add, color: AppColors.purpleLight),
            label: Text('Adicionar jogador',
              style: AppTextStyles.body.copyWith(color: AppColors.purpleLight)),
          ),
        const SizedBox(height: AppSpacing.lg),
        ArbitroButton(
          label: 'INICIAR SESSÃO',
          onPressed: _confirm,
          fullWidth: true,
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: Rewrite LobbyScreen with session banner**

Rewrite `lib/ui/screens/lobby_screen.dart`:
```dart
import 'package:flutter/material.dart';
import '../../models/session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../components/glass_card.dart';
import '../components/arbitro_badge.dart';
import '../components/arbitro_button.dart';
import '../components/player_setup_sheet.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  void _showSetup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.modalRadius)),
      ),
      builder: (_) => const PlayerSetupSheet(),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Nova Sessão?', style: AppTextStyles.heading),
        content: Text('Todos os dados da sessão atual serão apagados.',
          style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCELAR', style: AppTextStyles.button.copyWith(
              color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              SessionState.of(context).endSession();
              _showSetup(context);
            },
            child: Text('CONFIRMAR', style: AppTextStyles.button.copyWith(
              color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = SessionState.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AppBar(),
              const SizedBox(height: AppSpacing.xl),
              if (!state.hasSession) ...[
                _NoSessionBanner(onStart: () => _showSetup(context)),
              ] else ...[
                _SessionBanner(
                  players: state.session!.players.map((p) => p.name).toList(),
                  onReset: () => _confirmReset(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                _FeaturedCard(),
                const SizedBox(height: AppSpacing.md),
                _SecondaryGrid(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      RichText(
        text: TextSpan(
          style: AppTextStyles.heading,
          children: [
            const TextSpan(text: 'O '),
            TextSpan(
              text: 'Árbitro',
              style: AppTextStyles.heading.copyWith(color: AppColors.purpleLight),
            ),
          ],
        ),
      ),
      Container(
        width: 36, height: 36,
        decoration: const BoxDecoration(
          gradient: AppColors.gradientPrimary,
          shape: BoxShape.circle,
        ),
      ),
    ],
  );
}

class _NoSessionBanner extends StatelessWidget {
  const _NoSessionBanner({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => GlassCard(
    variant: GlassCardVariant.highlighted,
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Column(
      children: [
        const Text('🎮', style: TextStyle(fontSize: 48)),
        const SizedBox(height: AppSpacing.md),
        Text('Prontos para jogar?', style: AppTextStyles.heading,
          textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text('Adiciona os jogadores para começar',
          style: AppTextStyles.body, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        ArbitroButton(label: 'INICIAR SESSÃO', onPressed: onStart, fullWidth: true),
      ],
    ),
  );
}

class _SessionBanner extends StatelessWidget {
  const _SessionBanner({required this.players, required this.onReset});
  final List<String> players;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sessão activa', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.xs),
              Text(players.join(' · '), style: AppTextStyles.bodyStrong),
            ],
          ),
        ),
        GestureDetector(
          onTap: onReset,
          child: const Icon(Icons.refresh_rounded, color: AppColors.textMuted),
        ),
      ],
    ),
  );
}

class _FeaturedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GlassCard(
    variant: GlassCardVariant.highlighted,
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Row(
      children: [
        const Text('🎰', style: TextStyle(fontSize: 48)),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Social Slots', style: AppTextStyles.heading),
              const SizedBox(height: AppSpacing.xs),
              Text('Consequências instantâneas', style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.sm),
              const ArbitroBadge(label: 'Em Destaque', variant: BadgeVariant.purple),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SecondaryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🎡', style: TextStyle(fontSize: 32)),
              const SizedBox(height: AppSpacing.sm),
              Text('Roleta do Destino', style: AppTextStyles.bodyStrong),
              const SizedBox(height: AppSpacing.xs),
              Text('Destino', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📜', style: TextStyle(fontSize: 32)),
              const SizedBox(height: AppSpacing.sm),
              Text('Absurdity Ledger', style: AppTextStyles.bodyStrong),
              const SizedBox(height: AppSpacing.xs),
              Text('Apostas', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    ],
  );
}
```

- [ ] **Step 3: Verify app compiles**

```bash
export PATH="$PATH:/root/flutter/bin"
flutter analyze lib/ 2>&1 | tail -5
```

Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/ui/components/player_setup_sheet.dart lib/ui/screens/lobby_screen.dart
git commit -m "feat: add player setup sheet and session-aware lobby"
```

---

### Task 5: Social Slots Screen

**Files:**
- Create: `lib/ui/components/slot_machine.dart`
- Create: `lib/ui/components/dare_result_card.dart`
- Modify: `lib/ui/screens/slots_screen.dart`
- Test: `test/ui/screens/slots_screen_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/ui/screens/slots_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/models/player.dart';
import 'package:o_arbitro/models/session.dart';
import 'package:o_arbitro/models/session_state.dart';
import 'package:o_arbitro/ui/screens/slots_screen.dart';
import 'package:o_arbitro/ui/theme/app_theme.dart';

Widget _wrap(Session session) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: SessionState(
      session: session,
      onSessionChanged: (_) {},
      child: const SlotsScreen(),
    ),
  );
}

void main() {
  final session = Session(players: [
    Player(name: 'Ana'),
    Player(name: 'Bruno'),
  ]);

  testWidgets('slots screen shows GIRAR button', (tester) async {
    await tester.pumpWidget(_wrap(session));
    expect(find.text('GIRAR'), findsOneWidget);
  });

  testWidgets('slots screen shows player names', (tester) async {
    await tester.pumpWidget(_wrap(session));
    expect(find.text('Ana'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
export PATH="$PATH:/root/flutter/bin"
flutter test test/ui/screens/slots_screen_test.dart 2>&1 | tail -5
```

Expected: FAIL

- [ ] **Step 3: Implement SlotMachine widget**

Create `lib/ui/components/slot_machine.dart`:
```dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/spin_result.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class SlotMachine extends StatefulWidget {
  const SlotMachine({
    super.key,
    required this.players,
    required this.onResult,
  });

  final List<String> players;
  final ValueChanged<SpinResult> onResult;

  @override
  State<SlotMachine> createState() => SlotMachineState();
}

class SlotMachineState extends State<SlotMachine>
    with TickerProviderStateMixin {
  final _random = Random();
  bool _spinning = false;

  String _selectedPlayer = '';
  DareCategory _selectedCategory = DareCategory.social;
  DareIntensity _selectedIntensity = DareIntensity.casual;

  late AnimationController _reel1;
  late AnimationController _reel2;
  late AnimationController _reel3;

  static const _categories = DareCategory.values;
  static const _intensities = DareIntensity.values;

  static const _categoryLabels = {
    DareCategory.social: 'Social',
    DareCategory.fisico: 'Físico',
    DareCategory.mental: 'Mental',
    DareCategory.wild: 'Wild',
  };

  static const _intensityLabels = {
    DareIntensity.casual: 'CASUAL',
    DareIntensity.ousado: 'OUSADO',
    DareIntensity.epico: 'ÉPICO',
  };

  static const _intensityColors = {
    DareIntensity.casual: Color(0xFF6b7280),
    DareIntensity.ousado: Color(0xFF3b82f6),
    DareIntensity.epico: AppColors.purpleLight,
  };

  @override
  void initState() {
    super.initState();
    _selectedPlayer = widget.players.first;
    _reel1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _reel2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _reel3 = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  }

  @override
  void dispose() {
    _reel1.dispose();
    _reel2.dispose();
    _reel3.dispose();
    super.dispose();
  }

  Future<void> spin() async {
    if (_spinning) return;
    setState(() => _spinning = true);

    final player = widget.players[_random.nextInt(widget.players.length)];
    final category = _categories[_random.nextInt(_categories.length)];
    final intensity = _intensities[_random.nextInt(_intensities.length)];

    await _reel1.forward(from: 0);
    setState(() => _selectedPlayer = player);
    await Future.delayed(const Duration(milliseconds: 150));

    await _reel2.forward(from: 0);
    setState(() => _selectedCategory = category);
    await Future.delayed(const Duration(milliseconds: 150));

    await _reel3.forward(from: 0);
    setState(() {
      _selectedIntensity = intensity;
      _spinning = false;
    });

    widget.onResult(SpinResult(
      player: player,
      category: category,
      intensity: intensity,
      dare: '', // filled by parent from Dares.random()
      accepted: false,
    ));
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Reel(
            controller: _reel1,
            label: _selectedPlayer,
            sublabel: 'JOGADOR',
          ),
          _Reel(
            controller: _reel2,
            label: _categoryLabels[_selectedCategory]!,
            sublabel: 'CATEGORIA',
          ),
          _Reel(
            controller: _reel3,
            label: _intensityLabels[_selectedIntensity]!,
            sublabel: 'NÍVEL',
            color: _intensityColors[_selectedIntensity],
          ),
        ],
      ),
    ],
  );
}

class _Reel extends StatelessWidget {
  const _Reel({
    required this.controller,
    required this.label,
    required this.sublabel,
    this.color,
  });

  final AnimationController controller;
  final String label;
  final String sublabel;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Container(
        width: 100,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              sublabel,
              style: AppTextStyles.label,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodyStrong.copyWith(
                color: color ?? AppColors.textPrimary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Implement DareResultCard**

Create `lib/ui/components/dare_result_card.dart`:
```dart
import 'package:flutter/material.dart';
import '../../models/spin_result.dart';
import '../../models/player.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'arbitro_button.dart';
import 'glass_card.dart';

class DareResultCard extends StatelessWidget {
  const DareResultCard({
    super.key,
    required this.dare,
    required this.player,
    required this.intensity,
    required this.canVeto,
    required this.vetoTokens,
    required this.onAccept,
    required this.onVeto,
  });

  final String dare;
  final String player;
  final DareIntensity intensity;
  final bool canVeto;
  final int vetoTokens;
  final VoidCallback onAccept;
  final VoidCallback onVeto;

  static const _intensityColors = {
    DareIntensity.casual: Color(0xFF6b7280),
    DareIntensity.ousado: Color(0xFF3b82f6),
    DareIntensity.epico: AppColors.purpleLight,
  };

  static const _intensityLabels = {
    DareIntensity.casual: 'CASUAL',
    DareIntensity.ousado: 'OUSADO',
    DareIntensity.epico: 'ÉPICO',
  };

  @override
  Widget build(BuildContext context) {
    final color = _intensityColors[intensity]!;
    return GlassCard(
      variant: intensity == DareIntensity.epico
        ? GlassCardVariant.highlighted
        : GlassCardVariant.defaultCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(player, style: AppTextStyles.heading),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(51),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _intensityLabels[intensity]!,
                  style: AppTextStyles.label.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(dare, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: ArbitroButton(
                  label: 'ACEITAR',
                  onPressed: onAccept,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ArbitroButton(
                  label: 'VETAR ($vetoTokens)',
                  variant: ArbitroButtonVariant.secondary,
                  onPressed: canVeto ? onVeto : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Implement SlotsScreen**

Rewrite `lib/ui/screens/slots_screen.dart`:
```dart
import 'package:flutter/material.dart';
import '../../data/dares.dart';
import '../../models/session_state.dart';
import '../../models/spin_result.dart';
import '../../models/ledger_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../components/slot_machine.dart';
import '../components/dare_result_card.dart';
import '../components/arbitro_button.dart';

class SlotsScreen extends StatefulWidget {
  const SlotsScreen({super.key});

  @override
  State<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends State<SlotsScreen> {
  final _machineKey = GlobalKey<SlotMachineState>();
  SpinResult? _pendingResult;
  String? _currentDare;

  void _onSpinResult(SpinResult result) {
    final dare = Dares.random(result.category, result.intensity);
    setState(() {
      _pendingResult = result;
      _currentDare = dare;
    });
  }

  void _onAccept() {
    if (_pendingResult == null || _currentDare == null) return;
    final state = SessionState.of(context);
    final result = SpinResult(
      player: _pendingResult!.player,
      category: _pendingResult!.category,
      intensity: _pendingResult!.intensity,
      dare: _currentDare!,
      accepted: true,
    );
    state.addSpinResult(result);
    state.completeDare(_pendingResult!.player);
    state.addLedgerEntry(ScoreEntry(
      player: _pendingResult!.player,
      source: ScoreSource.slots,
      description: _currentDare!,
    ));
    setState(() {
      _pendingResult = null;
      _currentDare = null;
    });
  }

  void _onVeto() {
    if (_pendingResult == null) return;
    final state = SessionState.of(context);
    state.useVeto(_pendingResult!.player);
    final newDare = Dares.random(_pendingResult!.category, _pendingResult!.intensity);
    setState(() => _currentDare = newDare);
  }

  @override
  Widget build(BuildContext context) {
    final state = SessionState.of(context);
    final session = state.session!;
    final players = session.players;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              Text('Social Slots', style: AppTextStyles.heading),
              const SizedBox(height: AppSpacing.xl),
              SlotMachine(
                key: _machineKey,
                players: players.map((p) => p.name).toList(),
                onResult: _onSpinResult,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_pendingResult == null)
                ArbitroButton(
                  label: 'GIRAR',
                  onPressed: () => _machineKey.currentState?.spin(),
                  fullWidth: true,
                )
              else ...[
                () {
                  final player = session.playerByName(_pendingResult!.player);
                  return DareResultCard(
                    dare: _currentDare!,
                    player: _pendingResult!.player,
                    intensity: _pendingResult!.intensity,
                    canVeto: player?.canVeto ?? false,
                    vetoTokens: player?.vetoTokens ?? 0,
                    onAccept: _onAccept,
                    onVeto: _onVeto,
                  );
                }(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Run tests**

```bash
export PATH="$PATH:/root/flutter/bin"
flutter test test/ui/screens/slots_screen_test.dart 2>&1 | tail -8
```

Expected: All tests passed!

- [ ] **Step 7: Commit**

```bash
git add lib/ui/components/slot_machine.dart lib/ui/components/dare_result_card.dart \
  lib/ui/screens/slots_screen.dart test/ui/screens/slots_screen_test.dart
git commit -m "feat: implement Social Slots with spin, dare reveal, veto system"
```

---

### Task 6: Roleta do Destino Screen

**Files:**
- Create: `lib/ui/components/roulette_wheel.dart`
- Modify: `lib/ui/screens/roulette_screen.dart`

- [ ] **Step 1: Implement RouletteWheel with CustomPainter**

Create `lib/ui/components/roulette_wheel.dart`:
```dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class RouletteWheel extends StatefulWidget {
  const RouletteWheel({
    super.key,
    required this.players,
    required this.onResult,
  });

  final List<String> players;
  final ValueChanged<String> onResult;

  @override
  State<RouletteWheel> createState() => RouletteWheelState();
}

class RouletteWheelState extends State<RouletteWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentAngle = 0;
  bool _spinning = false;
  final _random = Random();

  static const _segmentColors = [
    AppColors.purple,
    AppColors.pink,
    Color(0xFF3b82f6),
    AppColors.success,
    AppColors.gold,
    Color(0xFF8b5cf6),
    Color(0xFFf97316),
    Color(0xFF06b6d4),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> spin() async {
    if (_spinning || widget.players.isEmpty) return;
    setState(() => _spinning = true);

    final n = widget.players.length;
    final winnerIndex = _random.nextInt(n);
    final segmentAngle = (2 * pi) / n;

    // Minimum 3 full rotations + land on winner segment
    final targetAngle = _currentAngle +
      (2 * pi * (3 + _random.nextDouble())) +
      (2 * pi - (winnerIndex * segmentAngle + segmentAngle / 2));

    _animation = Tween<double>(
      begin: _currentAngle,
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    ));

    _controller.reset();
    await _controller.forward();

    setState(() {
      _currentAngle = targetAngle % (2 * pi);
      _spinning = false;
    });

    widget.onResult(widget.players[winnerIndex]);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      // Pointer
      const Icon(Icons.arrow_drop_down_rounded,
        color: AppColors.gold, size: 40),
      AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => CustomPaint(
          size: const Size(280, 280),
          painter: _WheelPainter(
            players: widget.players,
            angle: _controller.isAnimating
              ? _animation.value
              : _currentAngle,
            colors: _segmentColors,
          ),
        ),
      ),
    ],
  );
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({
    required this.players,
    required this.angle,
    required this.colors,
  });

  final List<String> players;
  final double angle;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (players.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final n = players.length;
    final segmentAngle = (2 * pi) / n;

    for (int i = 0; i < n; i++) {
      final startAngle = angle + i * segmentAngle - pi / 2;
      final color = colors[i % colors.length];

      // Segment fill
      final paint = Paint()..color = color.withAlpha(200);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, segmentAngle, true, paint,
      );

      // Segment border
      final borderPaint = Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, segmentAngle, true, borderPaint,
      );

      // Label
      final labelAngle = startAngle + segmentAngle / 2;
      final labelRadius = radius * 0.65;
      final labelOffset = Offset(
        center.dx + labelRadius * cos(labelAngle),
        center.dy + labelRadius * sin(labelAngle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: players[i].length > 8
            ? '${players[i].substring(0, 7)}…'
            : players[i],
          style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 60);

      canvas.save();
      canvas.translate(labelOffset.dx, labelOffset.dy);
      canvas.rotate(labelAngle + pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Center circle
    canvas.drawCircle(center, 20,
      Paint()..color = AppColors.surface);
    canvas.drawCircle(center, 20,
      Paint()..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
    old.angle != angle || old.players != players;
}
```

- [ ] **Step 2: Rewrite RouletteScreen**

Rewrite `lib/ui/screens/roulette_screen.dart`:
```dart
import 'package:flutter/material.dart';
import '../../models/roulette_result.dart';
import '../../models/session_state.dart';
import '../../models/ledger_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../components/roulette_wheel.dart';
import '../components/arbitro_button.dart';
import '../components/arbitro_input.dart';
import '../components/glass_card.dart';

class RouletteScreen extends StatefulWidget {
  const RouletteScreen({super.key});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> {
  final _wheelKey = GlobalKey<RouletteWheelState>();
  final _questionController = TextEditingController();
  String? _winner;
  bool _hasSpun = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _onResult(String winner) {
    final state = SessionState.of(context);
    final result = RouletteResult(
      question: _questionController.text.trim(),
      winner: winner,
      timestamp: DateTime.now(),
    );
    state.addRouletteResult(result);
    state.addLedgerEntry(ScoreEntry(
      player: winner,
      source: ScoreSource.roulette,
      description: _questionController.text.trim().isEmpty
        ? 'Resultado da Roleta'
        : _questionController.text.trim(),
    ));
    setState(() {
      _winner = winner;
      _hasSpun = true;
    });
  }

  void _reset() => setState(() {
    _winner = null;
    _hasSpun = false;
    _questionController.clear();
  });

  @override
  Widget build(BuildContext context) {
    final players = SessionState.of(context).session!.players
      .map((p) => p.name).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              Text('Roleta do Destino', style: AppTextStyles.heading),
              const SizedBox(height: AppSpacing.lg),
              ArbitroInput(
                controller: _questionController,
                hint: 'Qual a questão a decidir?',
              ),
              const SizedBox(height: AppSpacing.xl),
              RouletteWheel(
                key: _wheelKey,
                players: players,
                onResult: _onResult,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_winner != null) ...[
                GlassCard(
                  variant: GlassCardVariant.gold,
                  child: Column(
                    children: [
                      Text('O destino decidiu!', style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.sm),
                      Text(_winner!, style: AppTextStyles.display
                        .copyWith(color: AppColors.gold)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ArbitroButton(
                  label: 'NOVA QUESTÃO',
                  onPressed: _reset,
                  variant: ArbitroButtonVariant.secondary,
                  fullWidth: true,
                ),
              ] else
                ArbitroButton(
                  label: 'GIRAR',
                  onPressed: () => _wheelKey.currentState?.spin(),
                  fullWidth: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Verify compiles**

```bash
export PATH="$PATH:/root/flutter/bin"
flutter analyze lib/ 2>&1 | tail -5
```

Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/ui/components/roulette_wheel.dart lib/ui/screens/roulette_screen.dart
git commit -m "feat: implement Roleta do Destino with spinning wheel and result reveal"
```

---

### Task 7: Absurdity Ledger Screen

**Files:**
- Create: `lib/ui/components/new_ledger_entry_sheet.dart`
- Modify: `lib/ui/screens/ledger_screen.dart`
- Test: `test/ui/screens/ledger_screen_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/ui/screens/ledger_screen_test.dart`:
```dart
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
    final session = Session(players: [Player(name: 'Ana'), Player(name: 'Bruno')]);
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
```

- [ ] **Step 2: Run test to verify it fails**

```bash
export PATH="$PATH:/root/flutter/bin"
flutter test test/ui/screens/ledger_screen_test.dart 2>&1 | tail -5
```

Expected: FAIL

- [ ] **Step 3: Implement NewLedgerEntrySheet**

Create `lib/ui/components/new_ledger_entry_sheet.dart`:
```dart
import 'package:flutter/material.dart';
import '../../models/ledger_entry.dart';
import '../../models/session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'arbitro_button.dart';
import 'arbitro_input.dart';
import 'bottom_sheet_handle.dart';

enum _EntryType { aposta, previsao, pontuacao }

class NewLedgerEntrySheet extends StatefulWidget {
  const NewLedgerEntrySheet({super.key});

  @override
  State<NewLedgerEntrySheet> createState() => _NewLedgerEntrySheetState();
}

class _NewLedgerEntrySheetState extends State<NewLedgerEntrySheet> {
  _EntryType _type = _EntryType.aposta;
  final _descController = TextEditingController();
  final _consequenceController = TextEditingController();
  final List<String> _selectedPlayers = [];
  String? _selectedPlayer;

  @override
  void dispose() {
    _descController.dispose();
    _consequenceController.dispose();
    super.dispose();
  }

  void _submit() {
    final desc = _descController.text.trim();
    if (desc.isEmpty) return;
    final state = SessionState.of(context);
    final players = state.session!.players.map((p) => p.name).toList();

    LedgerEntry entry;
    switch (_type) {
      case _EntryType.aposta:
        entry = SocialBet(
          description: desc,
          players: _selectedPlayers.isEmpty ? players : _selectedPlayers,
          consequence: _consequenceController.text.trim(),
        );
      case _EntryType.previsao:
        entry = Prediction(
          description: desc,
          consequence: _consequenceController.text.trim(),
        );
      case _EntryType.pontuacao:
        entry = ScoreEntry(
          player: _selectedPlayer ?? players.first,
          source: ScoreSource.manual,
          description: desc,
        );
    }

    state.addLedgerEntry(entry);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = SessionState.of(context);
    final players = state.session!.players.map((p) => p.name).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BottomSheetHandle(),
          const SizedBox(height: AppSpacing.md),
          Text('Nova Entrada', style: AppTextStyles.heading),
          const SizedBox(height: AppSpacing.lg),
          // Type selector
          Row(
            children: [
              _TypeChip(label: 'Aposta', selected: _type == _EntryType.aposta,
                onTap: () => setState(() => _type = _EntryType.aposta)),
              const SizedBox(width: AppSpacing.sm),
              _TypeChip(label: 'Previsão', selected: _type == _EntryType.previsao,
                onTap: () => setState(() => _type = _EntryType.previsao)),
              const SizedBox(width: AppSpacing.sm),
              _TypeChip(label: 'Pontuação', selected: _type == _EntryType.pontuacao,
                onTap: () => setState(() => _type = _EntryType.pontuacao)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ArbitroInput(
            controller: _descController,
            hint: _type == _EntryType.pontuacao
              ? 'Descrição do ponto'
              : 'Descrição da ${_type == _EntryType.aposta ? "aposta" : "previsão"}',
          ),
          if (_type != _EntryType.pontuacao) ...[
            const SizedBox(height: AppSpacing.sm),
            ArbitroInput(
              controller: _consequenceController,
              hint: 'Consequência para o perdedor',
            ),
          ],
          if (_type == _EntryType.pontuacao) ...[
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _selectedPlayer ?? players.first,
              dropdownColor: AppColors.surface2,
              style: AppTextStyles.bodyStrong,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              items: players.map((p) => DropdownMenuItem(
                value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => _selectedPlayer = v),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          ArbitroButton(
            label: 'ADICIONAR',
            onPressed: _submit,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.purple : AppColors.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.purpleLight : AppColors.border),
      ),
      child: Text(label, style: AppTextStyles.label.copyWith(
        color: selected ? AppColors.textPrimary : AppColors.textMuted)),
    ),
  );
}
```

- [ ] **Step 4: Implement LedgerScreen**

Rewrite `lib/ui/screens/ledger_screen.dart`:
```dart
import 'package:flutter/material.dart';
import '../../models/ledger_entry.dart';
import '../../models/session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../components/glass_card.dart';
import '../components/new_ledger_entry_sheet.dart';
import '../components/arbitro_button.dart';

enum _Filter { todos, apostas, previsoes, pontuacao }

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  _Filter _filter = _Filter.todos;

  void _showNewEntry(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.modalRadius)),
      ),
      builder: (_) => const NewLedgerEntrySheet(),
    );
  }

  List<LedgerEntry> _filtered(List<LedgerEntry> entries) {
    return switch (_filter) {
      _Filter.todos => entries,
      _Filter.apostas => entries.whereType<SocialBet>().toList(),
      _Filter.previsoes => entries.whereType<Prediction>().toList(),
      _Filter.pontuacao => entries.whereType<ScoreEntry>().toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = SessionState.of(context);
    final entries = state.session!.ledgerEntries.reversed.toList();
    final filtered = _filtered(entries);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  Text('Absurdity Ledger', style: AppTextStyles.heading),
                  const SizedBox(height: AppSpacing.lg),
                  _Leaderboard(session: state.session!),
                  const SizedBox(height: AppSpacing.lg),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(label: 'TODOS',
                          selected: _filter == _Filter.todos,
                          onTap: () => setState(() => _filter = _Filter.todos)),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(label: 'APOSTAS',
                          selected: _filter == _Filter.apostas,
                          onTap: () => setState(() => _filter = _Filter.apostas)),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(label: 'PREVISÕES',
                          selected: _filter == _Filter.previsoes,
                          onTap: () => setState(() => _filter = _Filter.previsoes)),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(label: 'PONTUAÇÃO',
                          selected: _filter == _Filter.pontuacao,
                          onTap: () => setState(() => _filter = _Filter.pontuacao)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                ? Center(child: Text('Sem entradas ainda',
                    style: AppTextStyles.body))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (ctx, i) {
                      final entry = filtered[i];
                      final globalIndex =
                        state.session!.ledgerEntries.indexOf(entry);
                      return _EntryCard(
                        entry: entry,
                        index: globalIndex,
                      );
                    },
                  ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: ArbitroButton(
                label: '+ NOVA ENTRADA',
                onPressed: () => _showNewEntry(context),
                variant: ArbitroButtonVariant.secondary,
                fullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard({required this.session});
  final Session session;

  @override
  Widget build(BuildContext context) {
    final sorted = [...session.players]
      ..sort((a, b) => b.daresCompleted.compareTo(a.daresCompleted));

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Classificação', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          ...sorted.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                Text(p.name, style: AppTextStyles.bodyStrong),
                const Spacer(),
                Text('${p.daresCompleted} desafios',
                  style: AppTextStyles.caption),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.index});
  final LedgerEntry entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    return switch (entry) {
      SocialBet e => _BetCard(bet: e, index: index),
      Prediction e => _PredictionCard(prediction: e, index: index),
      ScoreEntry e => _ScoreCard(score: e),
    };
  }
}

class _BetCard extends StatelessWidget {
  const _BetCard({required this.bet, required this.index});
  final SocialBet bet;
  final int index;

  @override
  Widget build(BuildContext context) {
    final state = SessionState.of(context);
    final players = state.session!.players.map((p) => p.name).toList();

    return GlassCard(
      variant: bet.status == BetStatus.resolved
        ? GlassCardVariant.defaultCard
        : GlassCardVariant.highlighted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('🎲', style: const TextStyle(fontSize: 16)),
            const SizedBox(width: AppSpacing.sm),
            Text('APOSTA', style: AppTextStyles.label),
            const Spacer(),
            Text(
              bet.status == BetStatus.pending ? 'PENDENTE' : 'RESOLVIDA',
              style: AppTextStyles.label.copyWith(
                color: bet.status == BetStatus.pending
                  ? AppColors.gold : AppColors.success),
            ),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(bet.description, style: AppTextStyles.bodyStrong),
          Text('Consequência: ${bet.consequence}', style: AppTextStyles.body),
          if (bet.loser != null)
            Text('Perdedor: ${bet.loser}',
              style: AppTextStyles.body.copyWith(color: AppColors.danger)),
          if (bet.status == BetStatus.pending) ...[
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              hint: Text('Escolher perdedor', style: AppTextStyles.caption),
              dropdownColor: AppColors.surface2,
              style: AppTextStyles.bodyStrong,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface2,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              items: players.map((p) => DropdownMenuItem(
                value: p, child: Text(p))).toList(),
              onChanged: (loser) {
                if (loser == null) return;
                state.updateLedgerEntry(index, bet.resolve(loser));
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  const _PredictionCard({required this.prediction, required this.index});
  final Prediction prediction;
  final int index;

  @override
  Widget build(BuildContext context) {
    final state = SessionState.of(context);
    final players = state.session!.players.map((p) => p.name).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🔮', style: TextStyle(fontSize: 16)),
            const SizedBox(width: AppSpacing.sm),
            Text('PREVISÃO', style: AppTextStyles.label),
            const Spacer(),
            if (prediction.resolved)
              Text('RESOLVIDA', style: AppTextStyles.label
                .copyWith(color: AppColors.success)),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(prediction.description, style: AppTextStyles.bodyStrong),
          Text('Consequência: ${prediction.consequence}',
            style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.sm),
          if (!prediction.resolved) ...[
            Text('Votos:', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            ...players.map((p) {
              final vote = prediction.votes[p];
              return Row(children: [
                Text(p, style: AppTextStyles.body),
                const Spacer(),
                GestureDetector(
                  onTap: () => state.updateLedgerEntry(
                    index, prediction.withVote(p, true)),
                  child: Icon(Icons.thumb_up_rounded,
                    color: vote == true
                      ? AppColors.success : AppColors.textDisabled,
                    size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () => state.updateLedgerEntry(
                    index, prediction.withVote(p, false)),
                  child: Icon(Icons.thumb_down_rounded,
                    color: vote == false
                      ? AppColors.danger : AppColors.textDisabled,
                    size: 20),
                ),
              ]);
            }),
            if (prediction.votes.length == players.length) ...[
              const SizedBox(height: AppSpacing.sm),
              ArbitroButton(
                label: 'RESOLVER',
                onPressed: () => state.updateLedgerEntry(
                  index, prediction.resolve()),
                variant: ArbitroButtonVariant.secondary,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});
  final ScoreEntry score;

  String get _sourceIcon => switch (score.source) {
    ScoreSource.slots => '🎰',
    ScoreSource.roulette => '🎡',
    ScoreSource.manual => '✏️',
  };

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Row(
      children: [
        Text(_sourceIcon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(score.player, style: AppTextStyles.bodyStrong),
              Text(score.description, style: AppTextStyles.caption),
            ],
          ),
        ),
        Text('+1', style: AppTextStyles.heading
          .copyWith(color: AppColors.success)),
      ],
    ),
  );
}
```

- [ ] **Step 5: Run all tests**

```bash
export PATH="$PATH:/root/flutter/bin"
flutter test 2>&1 | tail -8
```

Expected: All tests passed!

- [ ] **Step 6: Commit**

```bash
git add lib/ui/components/new_ledger_entry_sheet.dart \
  lib/ui/screens/ledger_screen.dart \
  test/ui/screens/ledger_screen_test.dart
git commit -m "feat: implement Absurdity Ledger with bets, predictions and scores"
```

---

### Task 8: Full Test Run + Build APK

**Files:** No new files

- [ ] **Step 1: Run full test suite**

```bash
export PATH="$PATH:/root/flutter/bin"
flutter test 2>&1 | tail -5
```

Expected: All tests passed!

- [ ] **Step 2: Analyze for errors**

```bash
export PATH="$PATH:/root/flutter/bin"
flutter analyze lib/ 2>&1 | tail -5
```

Expected: No issues (or info only)

- [ ] **Step 3: Build APK**

```bash
export ANDROID_HOME=/opt/android-sdk
export PATH="$PATH:/root/flutter/bin:/opt/android-sdk/cmdline-tools/latest/bin"
flutter build apk --debug 2>&1 | tail -5
```

Expected: `✓ Built build/app/outputs/flutter-apk/app-debug.apk`

- [ ] **Step 4: Push to GitHub and create release**

```bash
git push origin master

gh release create v0.2.0-debug \
  build/app/outputs/flutter-apk/app-debug.apk \
  --title "v0.2.0 — Games Implemented" \
  --notes "Social Slots, Roleta do Destino, and Absurdity Ledger fully implemented. Local party game, no backend required."
```

- [ ] **Step 5: Final commit tag**

```bash
git tag v0.2.0
git push origin v0.2.0
```
