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
