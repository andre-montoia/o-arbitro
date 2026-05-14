// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dare_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DareState _$DareStateFromJson(Map<String, dynamic> json) => DareState(
  player: json['player'] as String,
  dare: json['dare'] as String,
  intensity: json['intensity'] as String,
  isPunishment: json['isPunishment'] as bool? ?? false,
  phase:
      $enumDecodeNullable(_$DarePhaseEnumMap, json['phase']) ??
      DarePhase.assigned,
  votes:
      (json['votes'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const {},
  timerStartedAt: json['timerStartedAt'] == null
      ? null
      : DateTime.parse(json['timerStartedAt'] as String),
  resolvedPassed: json['resolvedPassed'] as bool?,
);

Map<String, dynamic> _$DareStateToJson(DareState instance) => <String, dynamic>{
  'player': instance.player,
  'dare': instance.dare,
  'intensity': instance.intensity,
  'isPunishment': instance.isPunishment,
  'phase': _$DarePhaseEnumMap[instance.phase]!,
  'votes': instance.votes,
  'timerStartedAt': instance.timerStartedAt?.toIso8601String(),
  'resolvedPassed': instance.resolvedPassed,
};

const _$DarePhaseEnumMap = {
  DarePhase.assigned: 'assigned',
  DarePhase.timing: 'timing',
  DarePhase.voting: 'voting',
  DarePhase.resolved: 'resolved',
  DarePhase.punishment: 'punishment',
};
