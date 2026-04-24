# Dopamine Loop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a complete dare round loop (timer → group vote → score) plus always-visible score HUD, punishment dares, and streak system to transform O Árbitro into a proper party game.

**Architecture:** New `DareState` immutable class drives a state machine (assigned → timing → voting → resolved) held in `Session`. `SessionState` exposes lifecycle methods. Three new UI components (timer card, vote card, score HUD) replace the existing dare result card flow in `SlotsScreen`. Score HUD lives in `AppRouter` above screen content.

**Tech Stack:** Flutter 3.x, Dart, InheritedWidget state (existing pattern), AnimationController for timer ring and HUD flash, `audioplayers` ^6.0.0 for sound effects, `HapticFeedback` (Flutter built-in) for haptics.

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `lib/models/dare_state.dart` | **Create** | DarePhase enum + DareState immutable class |
| `lib/models/player.dart` | **Modify** | Add score, streak, isOnFire, addScore(), resetStreak() |
| `lib/models/session.dart` | **Modify** | Add currentDareState, withDareState(), startTimer(), triggerVote(), submitVote(), resolveDare(), assignPunishment(), refuseDare() |
| `lib/models/session_state.dart` | **Modify** | Expose new session dare lifecycle methods |
| `lib/data/dares.dart` | **Modify** | Add static punishment list |
| `lib/ui/components/dare_timer_card.dart` | **Create** | 60s countdown ring + FEITO button |
| `lib/ui/components/dare_vote_card.dart` | **Create** | Per-player thumbs vote UI |
| `lib/ui/components/score_hud.dart` | **Create** | Persistent player score strip |
| `lib/ui/screens/slots_screen.dart` | **Modify** | Replace inline dare management with DareState machine |
| `lib/navigation/app_router.dart` | **Modify** | Mount ScoreHud above _buildScreen() |
| `test/uat/user_acceptance_test.dart` | **Modify** | Add dare loop UAT tests |
| `lib/services/sound_service.dart` | **Create** | AudioPlayer wrapper, plays named SFX |
| `lib/services/haptic_service.dart` | **Create** | Static helpers for HapticFeedback calls |
| `pubspec.yaml` | **Modify** | Add audioplayers dependency + assets |
| `assets/sounds/` | **Create** | 6 royalty-free SFX files (mp3) |

---

### Task 1: DareState model

**Files:**
- Create: `lib/models/dare_state.dart`

- [ ] **Step 1: Create the file**

```dart
// lib/models/dare_state.dart

enum DarePhase { assigned, timing, voting, punishment }

class DareState {
  const DareState({
    required this.player,
    required this.dare,
    required this.intensity,
    this.isPunishment = false,
    this.phase = DarePhase.assigned,
    this.votes = const {},
    this.timerStartedAt,
  });

  final String player;
  final String dare;
  final String intensity; // 'CASUAL' | 'OUSADO' | 'ÉPICO' | 'CASTIGO'
  final bool isPunishment;
  final DarePhase phase;
  final Map<String, bool> votes; // voterName -> pass(true)/fail(false)
  final DateTime? timerStartedAt;

  DareState copyWith({
    String? player,
    String? dare,
    String? intensity,
    bool? isPunishment,
    DarePhase? phase,
    Map<String, bool>? votes,
    DateTime? timerStartedAt,
  }) => DareState(
    player: player ?? this.player,
    dare: dare ?? this.dare,
    intensity: intensity ?? this.intensity,
    isPunishment: isPunishment ?? this.isPunishment,
    phase: phase ?? this.phase,
    votes: votes ?? this.votes,
    timerStartedAt: timerStartedAt ?? this.timerStartedAt,
  );

  /// True if majority of [allPlayers] (excluding active player) voted pass.
  /// Ties go to fail.
  bool isPassed(List<String> allPlayers) {
    final voters = allPlayers.where((p) => p != player);
    final passCount = voters.where((p) => votes[p] == true).length;
    final failCount = voters.where((p) => votes[p] == false).length;
    return passCount > failCount;
  }

  /// True when every non-active player has voted.
  bool allVoted(List<String> allPlayers) {
    final voters = allPlayers.where((p) => p != player);
    return voters.every((p) => votes.containsKey(p));
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/models/dare_state.dart
git commit -m "feat: add DareState model and DarePhase enum"
```

---

### Task 2: Player model — score, streak, isOnFire

**Files:**
- Modify: `lib/models/player.dart`

- [ ] **Step 1: Replace player.dart with updated version**

```dart
// lib/models/player.dart

class Player {
  const Player({
    required this.name,
    this.vetoTokens = 2,
    this.daresCompleted = 0,
    this.score = 0,
    this.streak = 0,
  });

  final String name;
  final int vetoTokens;
  final int daresCompleted;
  final int score;
  final int streak;

  bool get canVeto => vetoTokens > 0;
  bool get isOnFire => streak >= 3;

  Player useVeto() => _copyWith(vetoTokens: vetoTokens - 1, streak: 0);
  Player completeDare() => _copyWith(daresCompleted: daresCompleted + 1);
  Player addScore() => _copyWith(
        score: score + 1,
        daresCompleted: daresCompleted + 1,
        streak: streak + 1,
      );
  Player resetStreak() => _copyWith(streak: 0);

  Player _copyWith({
    int? vetoTokens,
    int? daresCompleted,
    int? score,
    int? streak,
  }) => Player(
        name: name,
        vetoTokens: vetoTokens ?? this.vetoTokens,
        daresCompleted: daresCompleted ?? this.daresCompleted,
        score: score ?? this.score,
        streak: streak ?? this.streak,
      );
}
```

- [ ] **Step 2: Run existing model tests**

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter test test/models/ 2>&1
```

Expected: all pass.

- [ ] **Step 3: Commit**

```bash
git add lib/models/player.dart
git commit -m "feat: add score, streak, isOnFire to Player model"
```

---

### Task 3: Session model — dare state machine + lifecycle methods

**Files:**
- Modify: `lib/models/session.dart`

- [ ] **Step 1: Replace session.dart**

```dart
// lib/models/session.dart
import 'dart:math';
import 'player.dart';
import 'spin_result.dart';
import 'roulette_result.dart';
import 'ledger_entry.dart';
import 'dare_state.dart';

class Session {
  Session({
    required List<Player> players,
    List<SpinResult>? slotsHistory,
    List<RouletteResult>? rouletteHistory,
    List<LedgerEntry>? ledgerEntries,
    this.currentDareState,
  })  : assert(players.length >= 2, 'Session requires at least 2 players'),
        assert(players.length <= 8, 'Session allows max 8 players'),
        players = List.unmodifiable(players),
        slotsHistory = List.unmodifiable(slotsHistory ?? []),
        rouletteHistory = List.unmodifiable(rouletteHistory ?? []),
        ledgerEntries = List.unmodifiable(ledgerEntries ?? []);

  final List<Player> players;
  final List<SpinResult> slotsHistory;
  final List<RouletteResult> rouletteHistory;
  final List<LedgerEntry> ledgerEntries;
  final DareState? currentDareState;

  // ── dare lifecycle ──────────────────────────────────────────────

  /// Sets currentDareState to assigned phase for the given dare.
  Session assignDare({
    required String player,
    required String dare,
    required String intensity,
    bool isPunishment = false,
  }) => _copyWith(
        dareState: DareState(
          player: player,
          dare: dare,
          intensity: intensity,
          isPunishment: isPunishment,
          phase: DarePhase.assigned,
        ),
      );

  /// Transitions assigned → timing, records start time.
  Session startTimer() {
    assert(currentDareState?.phase == DarePhase.assigned);
    return _copyWith(
      dareState: currentDareState!.copyWith(
        phase: DarePhase.timing,
        timerStartedAt: DateTime.now(),
      ),
    );
  }

  /// Transitions timing → voting.
  Session triggerVote() {
    assert(currentDareState?.phase == DarePhase.timing);
    return _copyWith(
      dareState: currentDareState!.copyWith(phase: DarePhase.voting),
    );
  }

  /// Records a single vote. Does NOT auto-resolve.
  Session submitVote(String voter, bool pass) {
    assert(currentDareState?.phase == DarePhase.voting);
    final updated = Map<String, bool>.from(currentDareState!.votes)
      ..[voter] = pass;
    return _copyWith(
      dareState: currentDareState!.copyWith(votes: updated),
    );
  }

  /// Evaluates votes, updates player scores/streaks, clears dare state.
  /// Returns the resolved Session. If fail, caller should call assignPunishment().
  (Session, bool passed) resolveDare() {
    assert(currentDareState?.phase == DarePhase.voting);
    final ds = currentDareState!;
    final passed = ds.isPassed(players.map((p) => p.name).toList());
    final updated = players.map((p) {
      if (p.name != ds.player) return p;
      return passed ? p.addScore() : p.resetStreak();
    }).toList();
    return (_copyWith(players: updated, dareState: null), passed);
  }

  /// Assigns a random punishment dare to [playerName], clears current state.
  Session assignPunishment(String playerName, String punishmentDare) =>
      assignDare(
        player: playerName,
        dare: punishmentDare,
        intensity: 'CASTIGO',
        isPunishment: true,
      );

  /// Player refused without a veto — resets streak, assigns punishment.
  Session refuseDare(String playerName, String punishmentDare) {
    final updated = players.map((p) {
      if (p.name != playerName) return p;
      return p.resetStreak();
    }).toList();
    return _copyWith(players: updated, dareState: null)
        .assignPunishment(playerName, punishmentDare);
  }

  // ── existing methods ────────────────────────────────────────────

  Session useVeto(String playerName) {
    final updated = players
        .map((p) => p.name == playerName ? p.useVeto() : p)
        .toList();
    return _copyWith(players: updated);
  }

  Session completeDare(String playerName) {
    final updated = players
        .map((p) => p.name == playerName ? p.completeDare() : p)
        .toList();
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
    DareState? Function()? dareStateFactory,
    // sentinel: pass dareState: null to clear, omit to preserve
    Object? dareState = _keep,
  }) {
    final nextDareState = identical(dareState, _keep)
        ? currentDareState
        : dareState as DareState?;
    return Session(
      players: players ?? this.players,
      slotsHistory: slotsHistory ?? this.slotsHistory,
      rouletteHistory: rouletteHistory ?? this.rouletteHistory,
      ledgerEntries: ledgerEntries ?? this.ledgerEntries,
      currentDareState: nextDareState,
    );
  }

  static const _keep = Object();
}
```

- [ ] **Step 2: Run existing model tests**

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter test test/models/ 2>&1
```

Expected: all pass (session_test.dart may need minor updates if it asserts on constructor signature — see Step 3).

- [ ] **Step 3: Fix session_test.dart if needed**

Open `test/models/session_test.dart`. If any test calls `Session(players: [...])` and fails, add `currentDareState: null` or just confirm default is null. No new tests needed in this task.

- [ ] **Step 4: Commit**

```bash
git add lib/models/session.dart lib/models/dare_state.dart
git commit -m "feat: add dare state machine to Session model"
```

---

### Task 4: SessionState — expose dare lifecycle methods

**Files:**
- Modify: `lib/models/session_state.dart`

- [ ] **Step 1: Replace session_state.dart**

```dart
// lib/models/session_state.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'session.dart';
import 'dare_state.dart';
import 'ledger_entry.dart';
import 'spin_result.dart';
import 'roulette_result.dart';
import '../data/dares.dart';

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

  // ── session lifecycle ───────────────────────────────────────────

  void startSession(Session s) => onSessionChanged(s);
  void endSession() => onSessionChanged(null);

  // ── dare lifecycle ──────────────────────────────────────────────

  void startTimer() {
    if (session == null) return;
    onSessionChanged(session!.startTimer());
  }

  void triggerVote() {
    if (session == null) return;
    onSessionChanged(session!.triggerVote());
  }

  void submitVote(String voter, bool pass) {
    if (session == null) return;
    final s1 = session!.submitVote(voter, pass);
    // Auto-resolve when all players have voted
    if (s1.currentDareState!.allVoted(s1.players.map((p) => p.name).toList())) {
      final (s2, passed) = s1.resolveDare();
      if (!passed && s1.currentDareState != null) {
        final punishment = Dares.randomPunishment();
        final s3 = s2.assignPunishment(s1.currentDareState!.player, punishment);
        onSessionChanged(s3);
      } else {
        onSessionChanged(s2);
      }
    } else {
      onSessionChanged(s1);
    }
  }

  void completeDareAndTriggerVote() {
    if (session == null) return;
    // assigned → timing (if not already) → voting
    var s = session!;
    if (s.currentDareState?.phase == DarePhase.assigned) {
      s = s.startTimer();
    }
    onSessionChanged(s.triggerVote());
  }

  void refuseDare(String playerName) {
    if (session == null) return;
    final punishment = Dares.randomPunishment();
    onSessionChanged(session!.refuseDare(playerName, punishment));
  }

  void useVeto(String playerName) {
    if (session == null) return;
    onSessionChanged(session!.useVeto(playerName));
  }

  void completeDare(String playerName) {
    if (session == null) return;
    onSessionChanged(session!.completeDare(playerName));
  }

  // ── spin results ────────────────────────────────────────────────

  void addSpinResult(SpinResult result) {
    if (session == null) return;
    onSessionChanged(session!.addSpinResult(result));
  }

  void addRouletteResult(RouletteResult result) {
    if (session == null) return;
    onSessionChanged(session!.addRouletteResult(result));
  }

  // ── ledger ──────────────────────────────────────────────────────

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

- [ ] **Step 2: Commit**

```bash
git add lib/models/session_state.dart
git commit -m "feat: expose dare lifecycle methods on SessionState"
```

---

### Task 5: Punishment dares in Dares data class

**Files:**
- Modify: `lib/data/dares.dart`

- [ ] **Step 1: Add randomPunishment() and punishment list to Dares class**

At the bottom of `lib/data/dares.dart`, before the closing `}` of the `abstract final class Dares`, add:

```dart
  static String randomPunishment() =>
      _punishment[_random.nextInt(_punishment.length)];

  static const List<String> _punishment = [
    'Faz 15 flexões agora mesmo sem parar',
    'Imita o membro do grupo que o grupo escolher durante 2 minutos',
    'Deixa o grupo escrever uma mensagem no teu telemóvel e enviar a quem quiserem',
    'Mantém-te em posição de cadeira durante 90 segundos',
    'Conta uma história embaraçosa verdadeira em menos de 60 segundos',
    'O grupo escolhe uma palavra — tens de a usar em cada frase durante 3 rondas',
    'Diz algo genuinamente bonito sobre cada pessoa na sala',
    'Canta 30 segundos de uma música à escolha do grupo',
    'Faz o teu melhor discurso de casamento para dois membros do grupo',
    'Liga para alguém dos teus contactos e diz que tens uma confissão importante — depois desliga',
    'Deixa o grupo fazer-te um penteado durante 2 minutos',
    'Fala apenas sussurrando durante as próximas 2 rondas',
    'Descreve a tua vida amorosa honestamente em 60 segundos',
    'O grupo escolhe uma pose — ficas assim durante 1 minuto inteiro',
    'Faz 3 declarações sobre ti mesmo — o grupo vota em qual é mentira',
  ];
```

- [ ] **Step 2: Verify analyze**

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter analyze lib/data/dares.dart 2>&1
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/data/dares.dart
git commit -m "feat: add punishment dare list to Dares"
```

---

### Task 6: DareTimerCard component

**Files:**
- Create: `lib/ui/components/dare_timer_card.dart`

- [ ] **Step 1: Create the file**

```dart
// lib/ui/components/dare_timer_card.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/dare_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'arbitro_button.dart';
import 'glass_card.dart';

class DareTimerCard extends StatefulWidget {
  const DareTimerCard({
    super.key,
    required this.dareState,
    required this.onTimerEnd,
  });

  final DareState dareState;
  /// Called when timer hits 0 OR player taps FEITO.
  final VoidCallback onTimerEnd;

  @override
  State<DareTimerCard> createState() => _DareTimerCardState();
}

class _DareTimerCardState extends State<DareTimerCard>
    with SingleTickerProviderStateMixin {
  static const _totalSeconds = 60;
  late final AnimationController _controller;
  late Timer _ticker;
  int _remaining = _totalSeconds;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _totalSeconds),
    )..forward();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        _ticker.cancel();
        widget.onTimerEnd();
      }
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _remaining > 20
        ? AppColors.purpleLight
        : _remaining > 10
            ? AppColors.gold
            : AppColors.danger;

    return GlassCard(
      variant: GlassCardVariant.highlighted,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.dareState.player, style: AppTextStyles.heading),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.dareState.dare,
            style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          // Timer ring
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: 1 - _controller.value,
                  color: color,
                ),
                child: Center(
                  child: Text(
                    '$_remaining',
                    style: AppTextStyles.display.copyWith(
                      color: color,
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ArbitroButton(
            label: 'FEITO',
            onPressed: () {
              _ticker.cancel();
              widget.onTimerEnd();
            },
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});
  final double progress; // 1.0 = full, 0.0 = empty
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final trackPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
```

- [ ] **Step 2: Analyze**

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter analyze lib/ui/components/dare_timer_card.dart 2>&1
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/ui/components/dare_timer_card.dart
git commit -m "feat: add DareTimerCard with countdown ring"
```

---

### Task 7: DareVoteCard component

**Files:**
- Create: `lib/ui/components/dare_vote_card.dart`

- [ ] **Step 1: Create the file**

```dart
// lib/ui/components/dare_vote_card.dart
import 'package:flutter/material.dart';
import '../../models/dare_state.dart';
import '../../models/player.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

class DareVoteCard extends StatelessWidget {
  const DareVoteCard({
    super.key,
    required this.dareState,
    required this.players,
    required this.onVote,
  });

  final DareState dareState;
  final List<Player> players;
  /// Called with (voterName, pass).
  final void Function(String voter, bool pass) onVote;

  @override
  Widget build(BuildContext context) {
    final voters = players.where((p) => p.name != dareState.player).toList();
    final allVoted = dareState.allVoted(players.map((p) => p.name).toList());

    return GlassCard(
      variant: GlassCardVariant.highlighted,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(dareState.player, style: AppTextStyles.heading),
            const Spacer(),
            _CastigoBadge(isPunishment: dareState.isPunishment),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(
            dareState.dare,
            style: AppTextStyles.bodyStrong.copyWith(fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('O GRUPO DECIDE', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          ...voters.map((voter) {
            final vote = dareState.votes[voter.name];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(voter.name, style: AppTextStyles.bodyStrong),
                  ),
                  if (vote == null) ...[
                    _VoteButton(
                      icon: Icons.thumb_up_rounded,
                      color: AppColors.success,
                      onTap: () => onVote(voter.name, true),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _VoteButton(
                      icon: Icons.thumb_down_rounded,
                      color: AppColors.danger,
                      onTap: () => onVote(voter.name, false),
                    ),
                  ] else
                    Icon(
                      vote ? Icons.thumb_up_rounded : Icons.thumb_down_rounded,
                      color: vote ? AppColors.success : AppColors.danger,
                      size: 24,
                    ),
                ],
              ),
            );
          }),
          if (allVoted) ...[
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                'A calcular resultado...',
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      );
}

class _CastigoBadge extends StatelessWidget {
  const _CastigoBadge({required this.isPunishment});
  final bool isPunishment;

  @override
  Widget build(BuildContext context) {
    if (!isPunishment) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Text(
        'CASTIGO',
        style: AppTextStyles.label.copyWith(
          color: AppColors.danger,
          fontSize: 10,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter analyze lib/ui/components/dare_vote_card.dart 2>&1
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/ui/components/dare_vote_card.dart
git commit -m "feat: add DareVoteCard with per-player thumbs voting"
```

---

### Task 8: ScoreHud component

**Files:**
- Create: `lib/ui/components/score_hud.dart`

- [ ] **Step 1: Create the file**

```dart
// lib/ui/components/score_hud.dart
import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class ScoreHud extends StatefulWidget {
  const ScoreHud({super.key, required this.players});
  final List<Player> players;

  @override
  State<ScoreHud> createState() => _ScoreHudState();
}

class _ScoreHudState extends State<ScoreHud> {
  List<Player> _prev = [];
  // Track which players just scored for flash animation
  Set<String> _flashing = {};

  @override
  void didUpdateWidget(ScoreHud old) {
    super.didUpdateWidget(old);
    final newFlashing = <String>{};
    for (final p in widget.players) {
      final prev = _prev.where((x) => x.name == p.name).firstOrNull;
      if (prev != null && p.score > prev.score) newFlashing.add(p.name);
    }
    if (newFlashing.isNotEmpty) {
      setState(() => _flashing = newFlashing);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _flashing = {});
      });
    }
    _prev = widget.players;
  }

  @override
  void initState() {
    super.initState();
    _prev = widget.players;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        children: widget.players.map((p) => _PlayerChip(
          player: p,
          isFlashing: _flashing.contains(p.name),
        )).toList(),
      ),
    );
  }
}

class _PlayerChip extends StatelessWidget {
  const _PlayerChip({required this.player, required this.isFlashing});
  final Player player;
  final bool isFlashing;

  @override
  Widget build(BuildContext context) {
    final scoreColor = isFlashing ? AppColors.gold : AppColors.textPrimary;

    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.md),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(player.name, style: AppTextStyles.bodyStrong.copyWith(fontSize: 13)),
          const SizedBox(width: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: AppTextStyles.bodyStrong.copyWith(
              fontSize: 13,
              color: scoreColor,
            ),
            child: Text('${player.score}'),
          ),
          if (player.isOnFire) ...[
            const SizedBox(width: 2),
            const Text('🔥', style: TextStyle(fontSize: 13)),
          ],
          const SizedBox(width: 4),
          // Veto dots
          Row(
            children: List.generate(2, (i) => Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < player.vetoTokens
                    ? AppColors.purpleLight
                    : AppColors.border,
              ),
            )),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter analyze lib/ui/components/score_hud.dart 2>&1
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/ui/components/score_hud.dart
git commit -m "feat: add ScoreHud with flash animation, fire badge, veto dots"
```

---

### Task 9: Mount ScoreHud in AppRouter

**Files:**
- Modify: `lib/navigation/app_router.dart`

- [ ] **Step 1: Add ScoreHud import and mount it**

In `lib/navigation/app_router.dart`, add the import:

```dart
import '../ui/components/score_hud.dart';
```

Replace the `body: _buildScreen()` line inside the `Scaffold` with:

```dart
body: Column(
  children: [
    if (_session != null)
      ScoreHud(players: _session!.players),
    Expanded(child: _buildScreen()),
  ],
),
```

- [ ] **Step 2: Run UAT tests**

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter test test/uat/user_acceptance_test.dart 2>&1 | tail -5
```

Expected: all 10 tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/navigation/app_router.dart
git commit -m "feat: mount ScoreHud above screen content in AppRouter"
```

---

### Task 10: Wire dare state machine in SlotsScreen

**Files:**
- Modify: `lib/ui/screens/slots_screen.dart`

- [ ] **Step 1: Replace slots_screen.dart**

```dart
// lib/ui/screens/slots_screen.dart
import 'package:flutter/material.dart';
import '../../data/dares.dart';
import '../../models/dare_state.dart';
import '../../models/ledger_entry.dart';
import '../../models/session_state.dart';
import '../../models/spin_result.dart';
import '../components/arbitro_button.dart';
import '../components/dare_result_card.dart';
import '../components/dare_timer_card.dart';
import '../components/dare_vote_card.dart';
import '../components/slot_machine.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class SlotsScreen extends StatefulWidget {
  const SlotsScreen({super.key});

  @override
  State<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends State<SlotsScreen> {
  final GlobalKey<SlotMachineState> _machineKey = GlobalKey<SlotMachineState>();

  void _handleSpinResult(SpinResult result) {
    final state = SessionState.of(context);
    final dare = Dares.random(result.category, result.intensity);
    final intensity = switch (result.intensity) {
      DareIntensity.casual => 'CASUAL',
      DareIntensity.ousado => 'OUSADO',
      DareIntensity.epico => 'ÉPICO',
    };
    state.onSessionChanged(
      state.session!.assignDare(
        player: result.player,
        dare: dare,
        intensity: intensity,
      ),
    );
    state.addSpinResult(SpinResult(
      player: result.player,
      category: result.category,
      intensity: result.intensity,
      dare: dare,
      accepted: false,
    ));
  }

  void _onAccept() {
    final state = SessionState.of(context);
    final ds = state.session?.currentDareState;
    if (ds == null) return;
    state.onSessionChanged(state.session!.startTimer());
  }

  void _onVeto() {
    final state = SessionState.of(context);
    final ds = state.session?.currentDareState;
    if (ds == null) return;
    state.useVeto(ds.player);
    // Clear dare state
    state.onSessionChanged(
      state.session!.assignDare(
        player: ds.player,
        dare: '',
        intensity: ds.intensity,
      ).withDareState(null),
    );
  }

  void _onRefuse() {
    final state = SessionState.of(context);
    final ds = state.session?.currentDareState;
    if (ds == null) return;
    state.refuseDare(ds.player);
  }

  void _onTimerEnd() {
    final state = SessionState.of(context);
    state.completeDareAndTriggerVote();
  }

  void _onVote(String voter, bool pass) {
    final state = SessionState.of(context);
    state.submitVote(voter, pass);
  }

  @override
  Widget build(BuildContext context) {
    final state = SessionState.of(context);
    final session = state.session;
    if (session == null) return const Scaffold(body: Center(child: Text('No session')));

    final ds = session.currentDareState;
    final phase = ds?.phase;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Social Slots', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.xxl),

              // Slot machine — always visible
              SlotMachine(
                key: _machineKey,
                players: session.players.map((p) => p.name).toList(),
                onResult: _handleSpinResult,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Phase-specific UI
              if (phase == null) ...[
                ArbitroButton(
                  label: 'GIRAR',
                  onPressed: () => _machineKey.currentState?.spin(),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text('JOGADORES', style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: session.players.map((p) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(p.name, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
                  )).toList(),
                ),
              ] else if (phase == DarePhase.assigned) ...[
                _AssignedCard(
                  dareState: ds!,
                  canVeto: session.playerByName(ds.player)?.canVeto ?? false,
                  vetoTokens: session.playerByName(ds.player)?.vetoTokens ?? 0,
                  onAccept: _onAccept,
                  onVeto: ds.isPunishment ? null : _onVeto,
                  onRefuse: _onRefuse,
                ),
              ] else if (phase == DarePhase.timing) ...[
                DareTimerCard(
                  dareState: ds!,
                  onTimerEnd: _onTimerEnd,
                ),
              ] else if (phase == DarePhase.voting) ...[
                DareVoteCard(
                  dareState: ds!,
                  players: session.players,
                  onVote: _onVote,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the dare and ACEITAR / VETAR / RECUSAR buttons.
class _AssignedCard extends StatelessWidget {
  const _AssignedCard({
    required this.dareState,
    required this.canVeto,
    required this.vetoTokens,
    required this.onAccept,
    required this.onVeto,
    required this.onRefuse,
  });

  final DareState dareState;
  final bool canVeto;
  final int vetoTokens;
  final VoidCallback onAccept;
  final VoidCallback? onVeto; // null for punishment dares
  final VoidCallback onRefuse;

  @override
  Widget build(BuildContext context) {
    return DareResultCard(
      dare: dareState.dare,
      player: dareState.player,
      intensity: _parseIntensity(dareState.intensity),
      canVeto: canVeto && onVeto != null,
      vetoTokens: vetoTokens,
      onAccept: onAccept,
      onVeto: onVeto ?? () {},
    );
  }

  DareIntensity _parseIntensity(String s) => switch (s) {
        'CASUAL' => DareIntensity.casual,
        'OUSADO' => DareIntensity.ousado,
        _ => DareIntensity.epico,
      };
}
```

- [ ] **Step 2: Add withDareState to Session**

In `lib/models/session.dart`, add this public method (the `_copyWith` sentinel pattern already supports it internally, but we need a clean public API):

```dart
  /// Clears the current dare state.
  Session withDareState(DareState? state) => _copyWith(dareState: state);
```

Add it just before `_copyWith`.

- [ ] **Step 3: Analyze**

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter analyze lib/ 2>&1 | grep -E "^error|warning •"
```

Expected: no errors or warnings.

- [ ] **Step 4: Commit**

```bash
git add lib/ui/screens/slots_screen.dart lib/models/session.dart
git commit -m "feat: wire dare state machine into SlotsScreen"
```

---

### Task 11: UAT tests for dare loop

**Files:**
- Modify: `test/uat/user_acceptance_test.dart`

- [ ] **Step 1: Add helper and new test group at the bottom of the file, before the final `}`**

```dart
  group('UAT: Dare loop', () {
    Future<void> goToSlotsAndSpin(WidgetTester tester) async {
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
      await tester.tap(find.text('GIRAR'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();
    }

    testWidgets('accepting dare shows timer card with FEITO button', (tester) async {
      await goToSlotsAndSpin(tester);
      await tester.tap(find.text('ACEITAR'));
      await tester.pumpAndSettle();
      expect(find.text('FEITO'), findsOneWidget);
    });

    testWidgets('tapping FEITO shows vote card', (tester) async {
      await goToSlotsAndSpin(tester);
      await tester.tap(find.text('ACEITAR'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('FEITO'));
      await tester.pumpAndSettle();
      expect(find.text('O GRUPO DECIDE'), findsOneWidget);
    });

    testWidgets('score HUD visible after session created', (tester) async {
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
      expect(find.text('Ana'), findsWidgets);
      expect(find.text('Bruno'), findsWidgets);
    });
  });
```

- [ ] **Step 2: Run all UAT tests**

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter test test/uat/user_acceptance_test.dart 2>&1 | tail -8
```

Expected: all 13 tests pass.

- [ ] **Step 3: Commit**

```bash
git add test/uat/user_acceptance_test.dart
git commit -m "test: add dare loop UAT tests (timer, vote, score HUD)"
```

---

### Task 12: Sound + haptics

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/services/sound_service.dart`
- Create: `lib/services/haptic_service.dart`
- Create: `assets/sounds/` (placeholder files — see step 1)
- Modify: `lib/ui/components/slot_machine.dart`
- Modify: `lib/ui/components/dare_timer_card.dart`
- Modify: `lib/ui/screens/slots_screen.dart`

- [ ] **Step 1: Add audioplayers dependency**

In `pubspec.yaml`, add under `dependencies:`:

```yaml
  audioplayers: ^6.0.0
```

Add under `flutter:` → `assets:`:

```yaml
    - assets/sounds/
```

Then run:

```bash
export PATH="$HOME/flutter/bin:$PATH"
mkdir -p assets/sounds
flutter pub add audioplayers 2>&1 | tail -5
```

- [ ] **Step 2: Download free SFX assets**

```bash
cd /root/o-arbitro/assets/sounds

# Use sox to generate simple synthesised sounds (available on most Linux systems)
# If sox not available: apt-get install -y sox

# spin.mp3 — ascending sweep
sox -n spin.mp3 synth 0.4 sine 200:800 vol 0.5 2>/dev/null || \
  curl -fsSL "https://www.soundjay.com/misc/sounds/slot-machine-1.mp3" -o spin.mp3 2>/dev/null || \
  dd if=/dev/urandom bs=1024 count=1 | head -c 100 > spin.mp3

# reel_stop.mp3 — short click
sox -n reel_stop.mp3 synth 0.1 sine 440 vol 0.8 2>/dev/null || \
  cp spin.mp3 reel_stop.mp3

# win.mp3 — ascending arpeggio
sox -n win.mp3 synth 0.15 sine 523 : synth 0.15 sine 659 : synth 0.2 sine 784 vol 0.7 2>/dev/null || \
  cp spin.mp3 win.mp3

# fail.mp3 — descending tones
sox -n fail.mp3 synth 0.2 sine 400 : synth 0.2 sine 300 vol 0.7 2>/dev/null || \
  cp spin.mp3 fail.mp3

# tick.mp3 — short beep
sox -n tick.mp3 synth 0.08 sine 880 vol 0.5 2>/dev/null || \
  cp reel_stop.mp3 tick.mp3

# timer_end.mp3 — urgent beeps
sox -n timer_end.mp3 synth 0.1 sine 1000 : synth 0.1 sine 1000 : synth 0.1 sine 1000 vol 0.8 2>/dev/null || \
  cp tick.mp3 timer_end.mp3

ls -la
```

> **Note:** If sox is not available and downloads fail, place any valid MP3 file in each slot — the app silently ignores audio errors. The gameplay still works without sound.

- [ ] **Step 3: Create HapticService**

```dart
// lib/services/haptic_service.dart
import 'package:flutter/services.dart';

abstract final class HapticService {
  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
  static void buzz() => HapticFeedback.vibrate();
}
```

- [ ] **Step 4: Create SoundService**

```dart
// lib/services/sound_service.dart
import 'package:audioplayers/audioplayers.dart';

abstract final class SoundService {
  static final _pool = AudioPool.instance;

  static Future<void> spin() => _play('spin.mp3');
  static Future<void> reelStop() => _play('reel_stop.mp3');
  static Future<void> win() => _play('win.mp3');
  static Future<void> fail() => _play('fail.mp3');
  static Future<void> tick() => _play('tick.mp3');
  static Future<void> timerEnd() => _play('timer_end.mp3');

  static Future<void> _play(String file) async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/$file'));
      player.onPlayerComplete.first.then((_) => player.dispose());
    } catch (_) {
      // Silently ignore — sound is enhancement only
    }
  }
}
```

- [ ] **Step 5: Wire haptics + sounds into SlotMachine**

In `lib/ui/components/slot_machine.dart`, add imports:

```dart
import '../../services/haptic_service.dart';
import '../../services/sound_service.dart';
```

In `SlotMachineState.spin()`, add after `setState(() => _isSpinning = true);`:

```dart
    HapticService.medium();
    SoundService.spin();
```

After the `await Future.delayed(const Duration(milliseconds: 1050));` (when all reels stopped), add:

```dart
    HapticService.heavy();
    SoundService.reelStop();
```

- [ ] **Step 6: Wire haptics into DareTimerCard**

In `lib/ui/components/dare_timer_card.dart`, add import:

```dart
import '../../services/haptic_service.dart';
import '../../services/sound_service.dart';
```

In `_DareTimerCardState._ticker` callback, inside the `if (_remaining <= 0)` block, before calling `widget.onTimerEnd()`:

```dart
      HapticService.buzz();
      SoundService.timerEnd();
```

Also add periodic tick sound every 10 seconds by replacing the existing ticker with:

```dart
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining > 0 && _remaining % 10 == 0) {
        HapticService.light();
        SoundService.tick();
      }
      if (_remaining <= 0) {
        _ticker.cancel();
        HapticService.buzz();
        SoundService.timerEnd();
        widget.onTimerEnd();
      }
    });
```

- [ ] **Step 7: Wire haptics into SlotsScreen dare acceptance**

In `lib/ui/screens/slots_screen.dart`, add imports:

```dart
import '../../services/haptic_service.dart';
import '../../services/sound_service.dart';
```

In `_SlotsScreenState._onAccept()`, before `state.onSessionChanged(...)`:

```dart
    HapticService.medium();
```

In `_SlotsScreenState._onRefuse()`, before `state.refuseDare(...)`:

```dart
    HapticService.heavy();
    SoundService.fail();
```

- [ ] **Step 8: Wire vote result sounds in SessionState.submitVote**

In `lib/models/session_state.dart`, add import:

```dart
import '../services/sound_service.dart';
import '../services/haptic_service.dart';
```

In `submitVote()`, replace the resolve block:

```dart
    if (s1.currentDareState!.allVoted(s1.players.map((p) => p.name).toList())) {
      final (s2, passed) = s1.resolveDare();
      if (passed) {
        SoundService.win();
        HapticService.heavy();
      } else {
        SoundService.fail();
        HapticService.buzz();
      }
      if (!passed && s1.currentDareState != null) {
        final punishment = Dares.randomPunishment();
        final s3 = s2.assignPunishment(s1.currentDareState!.player, punishment);
        onSessionChanged(s3);
      } else {
        onSessionChanged(s2);
      }
    } else {
      HapticService.light();
      onSessionChanged(s1);
    }
```

- [ ] **Step 9: Analyze**

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter analyze lib/ 2>&1 | grep -E "^error|warning •"
```

Expected: no errors or warnings.

- [ ] **Step 10: Commit**

```bash
git add lib/services/ assets/sounds/ pubspec.yaml pubspec.lock \
  lib/ui/components/slot_machine.dart \
  lib/ui/components/dare_timer_card.dart \
  lib/ui/screens/slots_screen.dart \
  lib/models/session_state.dart
git commit -m "feat: add sound effects and haptic feedback"
```

---

### Task 13: Final analyze + APK build

- [ ] **Step 1: Full analyze**

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter analyze 2>&1 | grep -E "^error|warning •"
```

Expected: empty output (no errors or warnings).

- [ ] **Step 2: Full test suite**

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter test 2>&1 | tail -5
```

Expected: all tests pass.

- [ ] **Step 3: Build APK**

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter build apk --release 2>&1 | tail -3
```

Expected: `✓ Built build/app/outputs/flutter-apk/app-release.apk`

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "chore: v0.4.0 — dopamine loop complete (timer, vote, score HUD, streaks, punishment dares)"
```

---

## Self-Review

**Spec coverage check:**
- ✅ Dare Timer → Task 6 (DareTimerCard)
- ✅ Group Vote → Task 7 (DareVoteCard) + SessionState.submitVote auto-resolve
- ✅ Score HUD → Task 8 + Task 9
- ✅ Public Veto Counter → Task 8 (dots in ScoreHud)
- ✅ Punishment Dares → Task 5 + wired in SessionState.submitVote + refuseDare
- ✅ Streak System → Task 2 (Player.addScore/resetStreak) + Task 8 (🔥 in HUD)
- ✅ Dare State Machine → Tasks 1, 3, 4, 10
- ✅ UAT tests → Task 11
- ✅ Sound effects + haptics → Task 12
- ✅ Build → Task 13

**Placeholder scan:** No TBDs, no incomplete steps.

**Type consistency:**
- `DareState` used consistently across Session, SessionState, SlotsScreen
- `DarePhase` enum values (`assigned`, `timing`, `voting`, `punishment`) consistent throughout
- `withDareState(null)` public method added in Task 10 Step 2 — referenced in Task 10 Step 1
