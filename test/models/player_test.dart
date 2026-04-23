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
