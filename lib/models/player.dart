class Player {
  const Player({
    required this.name,
    this.vetoTokens = 2,
    this.daresCompleted = 0,
  });

  final String name;
  final int vetoTokens;
  final int daresCompleted;

  bool get canVeto => vetoTokens > 0;

  Player useVeto() => _copyWith(vetoTokens: vetoTokens - 1);
  Player completeDare() => _copyWith(daresCompleted: daresCompleted + 1);

  Player _copyWith({int? vetoTokens, int? daresCompleted}) => Player(
    name: name,
    vetoTokens: vetoTokens ?? this.vetoTokens,
    daresCompleted: daresCompleted ?? this.daresCompleted,
  );
}
