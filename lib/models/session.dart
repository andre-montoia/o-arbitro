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

  Session startTimer() {
    assert(currentDareState?.phase == DarePhase.assigned);
    return _copyWith(
      dareState: currentDareState!.copyWith(
        phase: DarePhase.timing,
        timerStartedAt: DateTime.now(),
      ),
    );
  }

  Session triggerVote() {
    assert(currentDareState?.phase == DarePhase.timing);
    return _copyWith(
      dareState: currentDareState!.copyWith(phase: DarePhase.voting),
    );
  }

  Session submitVote(String voter, bool pass) {
    assert(currentDareState?.phase == DarePhase.voting);
    final updated = Map<String, bool>.from(currentDareState!.votes)
      ..[voter] = pass;
    return _copyWith(
      dareState: currentDareState!.copyWith(votes: updated),
    );
  }

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

  Session assignPunishment(String playerName, String punishmentDare) =>
      assignDare(
        player: playerName,
        dare: punishmentDare,
        intensity: 'CASTIGO',
        isPunishment: true,
      );

  Session refuseDare(String playerName, String punishmentDare) {
    final updated = players.map((p) {
      if (p.name != playerName) return p;
      return p.resetStreak();
    }).toList();
    return _copyWith(players: updated, dareState: null)
        .assignPunishment(playerName, punishmentDare);
  }

  Session withDareState(DareState? state) => _copyWith(dareState: state);

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
