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
