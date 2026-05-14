
enum BetStatus { pending, resolved }
enum ScoreSource { slots, roulette, manual }

sealed class LedgerEntry {
  LedgerEntry({DateTime? timestamp}) : timestamp = timestamp ?? DateTime.now();
  final DateTime timestamp;
  Map<String, dynamic> toJson();
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

  factory SocialBet.fromJson(Map<String, dynamic> json) => SocialBet(
        description: json['description'] as String,
        players: (json['players'] as List<dynamic>).map((e) => e as String).toList(),
        consequence: json['consequence'] as String,
        status: json['status'] == 'resolved' ? BetStatus.resolved : BetStatus.pending,
        loser: json['loser'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  @override
  Map<String, dynamic> toJson() => {
        'description': description,
        'players': players,
        'consequence': consequence,
        'status': status == BetStatus.resolved ? 'resolved' : 'pending',
        'loser': loser,
        'timestamp': timestamp.toIso8601String(),
      };

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

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
        description: json['description'] as String,
        consequence: json['consequence'] as String,
        votes: (json['votes'] as Map<String, dynamic>?)?.map(
              (k, e) => MapEntry(k, e as bool),
            ) ??
            {},
        resolved: json['resolved'] as bool? ?? false,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  @override
  Map<String, dynamic> toJson() => {
        'description': description,
        'consequence': consequence,
        'votes': votes,
        'resolved': resolved,
        'timestamp': timestamp.toIso8601String(),
      };

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

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        player: json['player'] as String,
        source: json['source'] == 'roulette'
            ? ScoreSource.roulette
            : json['source'] == 'manual'
                ? ScoreSource.manual
                : ScoreSource.slots,
        description: json['description'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  @override
  Map<String, dynamic> toJson() => {
        'player': player,
        'source': source == ScoreSource.roulette
            ? 'roulette'
            : source == ScoreSource.manual
                ? 'manual'
                : 'slots',
        'description': description,
        'timestamp': timestamp.toIso8601String(),
      };

  final String player;
  final ScoreSource source;
  final String description;
}
