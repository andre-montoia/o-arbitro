import 'package:json_annotation/json_annotation.dart';

part 'ledger_entry.g.dart';

enum BetStatus { pending, resolved }
enum ScoreSource { slots, roulette, manual }

@JsonSerializable(explicitToJson: true)
sealed class LedgerEntry {
  final DateTime timestamp;
  final String type; // Add type field

  LedgerEntry({DateTime? timestamp, required this.type}) : timestamp = timestamp ?? DateTime.now();

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String) {
      case 'socialBet':
        return SocialBet.fromJson(json);
      case 'prediction':
        return Prediction.fromJson(json);
      case 'scoreEntry':
        return ScoreEntry.fromJson(json);
      default:
        throw ArgumentError('Unknown LedgerEntry type: ${json['type']}');
    }
  }

  Map<String, dynamic> toJson(); // Abstract toJson
}

@JsonSerializable()
class SocialBet extends LedgerEntry {
  SocialBet({
    required this.description,
    required this.players,
    required this.consequence,
    this.status = BetStatus.pending,
    this.loser,
    super.timestamp,
  }) : super(type: 'socialBet'); // Pass the type here

  @override
  factory SocialBet.fromJson(Map<String, dynamic> json) => _$SocialBetFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SocialBetToJson(this);

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

@JsonSerializable()
class Prediction extends LedgerEntry {
  Prediction({
    required this.description,
    required this.consequence,
    Map<String, bool>? votes,
    this.resolved = false,
    super.timestamp,
  })  : votes = votes ?? {},
        super(type: 'prediction'); // Pass the type here

  @override
  factory Prediction.fromJson(Map<String, dynamic> json) => _$PredictionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PredictionToJson(this);

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

@JsonSerializable()
class ScoreEntry extends LedgerEntry {
  ScoreEntry({
    required this.player,
    required this.source,
    required this.description,
    super.timestamp,
  }) : super(type: 'scoreEntry'); // Pass the type here

  @override
  factory ScoreEntry.fromJson(Map<String, dynamic> json) => _$ScoreEntryFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ScoreEntryToJson(this);

  final String player;
  final ScoreSource source;
  final String description;
}
