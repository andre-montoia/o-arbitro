// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
  name: json['name'] as String,
  vetoTokens: (json['vetoTokens'] as num?)?.toInt() ?? 2,
  daresCompleted: (json['daresCompleted'] as num?)?.toInt() ?? 0,
  score: (json['score'] as num?)?.toInt() ?? 0,
  streak: (json['streak'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'name': instance.name,
  'vetoTokens': instance.vetoTokens,
  'daresCompleted': instance.daresCompleted,
  'score': instance.score,
  'streak': instance.streak,
};
