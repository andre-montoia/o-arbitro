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

  Player useVeto() => Player(
    name: name,
    vetoTokens: vetoTokens - 1,
    daresCompleted: daresCompleted,
  );

  Player completeDare() => Player(
    name: name,
    vetoTokens: vetoTokens,
    daresCompleted: daresCompleted + 1,
  );
}
