enum DarePhase { assigned, timing, voting, punishment }

class DareState {
  const DareState({
    required this.player,
    required this.dare,
    required this.intensity,
    this.isPunishment = false,
    this.phase = DarePhase.assigned,
    this.votes = const {},
    this.timerStartedAt,
  });

  final String player;
  final String dare;
  final String intensity; // 'CASUAL' | 'OUSADO' | 'ÉPICO' | 'CASTIGO'
  final bool isPunishment;
  final DarePhase phase;
  final Map<String, bool> votes; // voterName -> pass(true)/fail(false)
  final DateTime? timerStartedAt;

  DareState copyWith({
    String? player,
    String? dare,
    String? intensity,
    bool? isPunishment,
    DarePhase? phase,
    Map<String, bool>? votes,
    DateTime? timerStartedAt,
  }) => DareState(
    player: player ?? this.player,
    dare: dare ?? this.dare,
    intensity: intensity ?? this.intensity,
    isPunishment: isPunishment ?? this.isPunishment,
    phase: phase ?? this.phase,
    votes: votes ?? this.votes,
    timerStartedAt: timerStartedAt ?? this.timerStartedAt,
  );

  /// True if majority of [allPlayers] (excluding active player) voted pass.
  /// Ties go to fail.
  bool isPassed(List<String> allPlayers) {
    final voters = allPlayers.where((p) => p != player);
    final passCount = voters.where((p) => votes[p] == true).length;
    final failCount = voters.where((p) => votes[p] == false).length;
    return passCount > failCount;
  }

  /// True when every non-active player has voted.
  bool allVoted(List<String> allPlayers) {
    final voters = allPlayers.where((p) => p != player);
    return voters.every((p) => votes.containsKey(p));
  }
}
