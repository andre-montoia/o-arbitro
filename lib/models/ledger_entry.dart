enum BetStatus { pending, resolved }
enum ScoreSource { slots, roulette, manual }

sealed class LedgerEntry {
  LedgerEntry({DateTime? timestamp}) : timestamp = timestamp ?? DateTime.now();
  final DateTime timestamp;
}

class SocialBet extends LedgerEntry {
  SocialBet({
    required this.description,
    required this.players,
    required this.consequence,
    this.status = BetStatus.pending,
    this.loser,
    super.timestamp,
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
  Prediction({
    required this.description,
    required this.consequence,
    Map<String, bool>? votes,
    this.resolved = false,
    super.timestamp,
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
  ScoreEntry({
    required this.player,
    required this.source,
    required this.description,
    super.timestamp,
  });

  final String player;
  final ScoreSource source;
  final String description;
}
