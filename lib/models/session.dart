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
        slotsHistory = List<SpinResult>.unmodifiable(slotsHistory ?? []),
        rouletteHistory = List<RouletteResult>.unmodifiable(rouletteHistory ?? []),
        ledgerEntries = List<LedgerEntry>.unmodifiable(ledgerEntries ?? []);

  final List<Player> players;
  final List<SpinResult> slotsHistory;
  final List<RouletteResult> rouletteHistory;
  final List<LedgerEntry> ledgerEntries;
  final DareState? currentDareState;

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        players: (json['players'] as List<dynamic>)
            .map((e) => Player.fromJson(e as Map<String, dynamic>))
            .toList(),
        slotsHistory: (json['slotsHistory'] as List<dynamic>?)
            ?.map((e) => SpinResult.fromJson(e as Map<String, dynamic>))
            .toList(),
        rouletteHistory: (json['rouletteHistory'] as List<dynamic>?)
            ?.map((e) => RouletteResult.fromJson(e as Map<String, dynamic>))
            .toList(),
        ledgerEntries: (json['ledgerEntries'] as List<dynamic>?)
            ?.map((e) => ledgerEntryFromJson(e as Map<String, dynamic>))
            .toList(),
        currentDareState: json['currentDareState'] == null
            ? null
            : DareState.fromJson(json['currentDareState'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'players': players.map((e) => e.toJson()).toList(),
        'slotsHistory': slotsHistory.map((e) => e.toJson()).toList(),
        'rouletteHistory': rouletteHistory.map((e) => e.toJson()).toList(),
        'ledgerEntries': ledgerEntries.map((e) => _ledgerEntryToJson(e)).toList(),
        'currentDareState': currentDareState?.toJson(),
      };

  static LedgerEntry ledgerEntryFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == 'SocialBet') return SocialBet.fromJson(json);
    if (type == 'Prediction') return Prediction.fromJson(json);
    if (type == 'ScoreEntry') return ScoreEntry.fromJson(json);
    throw ArgumentError('Unknown LedgerEntry type: $type');
  }

  static Map<String, dynamic> _ledgerEntryToJson(LedgerEntry entry) {
    final map = entry.toJson();
    if (entry is SocialBet) {
      map['type'] = 'SocialBet';
    } else if (entry is Prediction) {
      map['type'] = 'Prediction';
    } else if (entry is ScoreEntry) {
      map['type'] = 'ScoreEntry';
    }
    return map;
  }

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

    int pointsForIntensity(String intensity) => switch (intensity) {
          'CASUAL' => 100,
          'OUSADO' => 250,
          'ÉPICO' => 500,
          'CASTIGO' => 50,
          _ => 100,
        };

    final updated = players.map((p) {
      if (p.name != ds.player) return p;
      if (!passed) return p.resetStreak();
      final points = pointsForIntensity(ds.intensity);
      var result = p.addScore(points);
      if (result.streak == 3) result = result.earnVeto();
      return result;
    }).toList();

    return (_copyWith(players: updated, dareState: null), passed);
  }

  Session resolveToResult(bool passed) {
    if (currentDareState == null) return this;
    return _copyWith(
      dareState: currentDareState!.copyWith(
        phase: DarePhase.resolved,
        resolvedPassed: passed,
      ),
    );
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
