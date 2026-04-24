class Player {
  const Player({
    required this.name,
    this.vetoTokens = 2,
    this.daresCompleted = 0,
    this.score = 0,
    this.streak = 0,
  });

  final String name;
  final int vetoTokens;
  final int daresCompleted;
  final int score;
  final int streak;

  bool get canVeto => vetoTokens > 0;
  bool get isOnFire => streak >= 3;

  Player useVeto() => _copyWith(vetoTokens: vetoTokens - 1, streak: 0);
  Player completeDare() => _copyWith(daresCompleted: daresCompleted + 1);
  Player addScore() => _copyWith(
        score: score + 1,
        daresCompleted: daresCompleted + 1,
        streak: streak + 1,
      );
  Player resetStreak() => _copyWith(streak: 0);

  Player _copyWith({
    int? vetoTokens,
    int? daresCompleted,
    int? score,
    int? streak,
  }) => Player(
        name: name,
        vetoTokens: vetoTokens ?? this.vetoTokens,
        daresCompleted: daresCompleted ?? this.daresCompleted,
        score: score ?? this.score,
        streak: streak ?? this.streak,
      );
}
