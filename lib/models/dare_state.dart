import 'package:json_annotation/json_annotation.dart';

part 'dare_state.g.dart';

enum DarePhase { assigned, timing, voting, resolved, punishment }

@JsonSerializable()
class DareState {
  const DareState({
    required this.player,
    required this.dare,
    required this.intensity,
    this.isPunishment = false,
    this.phase = DarePhase.assigned,
    this.votes = const {},
    this.timerStartedAt,
    this.resolvedPassed = false,
  });

  factory DareState.fromJson(Map<String, dynamic> json) => DareState(
        player: json['player'] as String,
        dare: json['dare'] as String,
        intensity: json['intensity'] as String,
        isPunishment: json['isPunishment'] as bool? ?? false,
        phase: _parsePhase(json['phase'] as String?),
        votes: (json['votes'] as Map<String, dynamic>?)?.map(
              (k, e) => MapEntry(k, e as bool),
            ) ??
            const {},
        timerStartedAt: json['timerStartedAt'] == null
            ? null
            : DateTime.parse(json['timerStartedAt'] as String),
        resolvedPassed: json['resolvedPassed'] as bool? ?? false,
      );

  static DarePhase _parsePhase(String? p) => switch (p) {
        'timing' => DarePhase.timing,
        'voting' => DarePhase.voting,
        'resolved' => DarePhase.resolved,
        'punishment' => DarePhase.punishment,
        _ => DarePhase.assigned,
      };

  Map<String, dynamic> toJson() => {
        'player': player,
        'dare': dare,
        'intensity': intensity,
        'isPunishment': isPunishment,
        'phase': _phaseString(phase),
        'votes': votes,
        'timerStartedAt': timerStartedAt?.toIso8601String(),
        'resolvedPassed': resolvedPassed,
      };

  static String _phaseString(DarePhase p) => switch (p) {
        DarePhase.assigned => 'assigned',
        DarePhase.timing => 'timing',
        DarePhase.voting => 'voting',
        DarePhase.resolved => 'resolved',
        DarePhase.punishment => 'punishment',
      };

  final String player;
  final String dare;
  final String intensity;
  final bool isPunishment;
  final DarePhase phase;
  final Map<String, bool> votes;
  final DateTime? timerStartedAt;
  final bool? resolvedPassed;

  DareState copyWith({
    String? player,
    String? dare,
    String? intensity,
    bool? isPunishment,
    DarePhase? phase,
    Map<String, bool>? votes,
    DateTime? timerStartedAt,
    bool? resolvedPassed,
  }) =>
      DareState(
        player: player ?? this.player,
        dare: dare ?? this.dare,
        intensity: intensity ?? this.intensity,
        isPunishment: isPunishment ?? this.isPunishment,
        phase: phase ?? this.phase,
        votes: votes ?? this.votes,
        timerStartedAt: timerStartedAt ?? this.timerStartedAt,
        resolvedPassed: resolvedPassed ?? this.resolvedPassed,
      );

  bool isPassed(List<String> allPlayers) {
    final voters = allPlayers.where((p) => p != player);
    final passCount = voters.where((p) => votes[p] == true).length;
    final failCount = voters.where((p) => votes[p] == false).length;
    return passCount > failCount;
  }

  bool allVoted(List<String> allPlayers) {
    final voters = allPlayers.where((p) => p != player);
    return voters.every((p) => votes.containsKey(p));
  }
}
