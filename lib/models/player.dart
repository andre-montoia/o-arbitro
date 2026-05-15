import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable()
class Player {
  const Player({
    required this.name,
    this.avatarId = 'default',
    this.vetoTokens = 2,
    this.daresCompleted = 0,
    this.score = 0,
    this.streak = 0,
  });

  final String name;
  final String avatarId;
  final int vetoTokens;
  final int daresCompleted;
  final int score;
  final int streak;

  bool get canVeto => vetoTokens > 0;
  bool get isOnFire => streak >= 3;

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        name: json['name'] as String,
        avatarId: json['avatarId'] as String? ?? 'default',
        vetoTokens: (json['vetoTokens'] as num?)?.toInt() ?? 2,
        daresCompleted: (json['daresCompleted'] as num?)?.toInt() ?? 0,
        score: (json['score'] as num?)?.toInt() ?? 0,
        streak: (json['streak'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatarId': avatarId,
        'vetoTokens': vetoTokens,
        'daresCompleted': daresCompleted,
        'score': score,
        'streak': streak,
      };

  Player useVeto() => _copyWith(vetoTokens: vetoTokens - 1, streak: 0);
  Player earnVeto() => _copyWith(vetoTokens: vetoTokens + 1);
  Player completeDare() => _copyWith(daresCompleted: daresCompleted + 1);
  Player addScore(int points) => _copyWith(
        score: score + points,
        daresCompleted: daresCompleted + 1,
        streak: streak + 1,
      );
  Player resetStreak() => _copyWith(streak: 0);

  Player _copyWith({
    String? avatarId,
    int? vetoTokens,
    int? daresCompleted,
    int? score,
    int? streak,
  }) =>
      Player(
        name: name,
        avatarId: avatarId ?? this.avatarId,
        vetoTokens: vetoTokens ?? this.vetoTokens,
        daresCompleted: daresCompleted ?? this.daresCompleted,
        score: score ?? this.score,
        streak: streak ?? this.streak,
      );
}
