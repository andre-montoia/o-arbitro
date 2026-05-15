class WouldYouRatherOption {
  final String text;
  final String emoji;

  WouldYouRatherOption({
    required this.text,
    required this.emoji,
  });
}

class WouldYouRatherQuestion {
  final String id;
  final String category;
  final WouldYouRatherOption optionA;
  final WouldYouRatherOption optionB;
  final Map<String, int> votes; // playerId -> 0 (A) or 1 (B)
  Map<String, int>? historicalVotes; // A: X%, B: Y%

  WouldYouRatherQuestion({
    required this.id,
    required this.category,
    required this.optionA,
    required this.optionB,
    Map<String, int>? votes,
    this.historicalVotes,
  }) : votes = votes ?? {};

  void vote(String playerId, bool choseA) {
    votes[playerId] = choseA ? 0 : 1;
  }

  double get percentageA {
    if (votes.isEmpty) return 50.0;
    final aVotes = votes.values.where((v) => v == 0).length;
    return (aVotes / votes.length) * 100;
  }

  double get percentageB => 100 - percentageA;

  String get winner => percentageA > percentageB ? 'A' : 'B';
}
