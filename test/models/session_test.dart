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
