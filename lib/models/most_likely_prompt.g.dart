// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'most_likely_prompt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MostLikelyPrompt _$MostLikelyPromptFromJson(Map<String, dynamic> json) =>
    MostLikelyPrompt(
      id: json['id'] as String,
      textPt: json['textPt'] as String,
      category: $enumDecode(_$PromptCategoryEnumMap, json['category']),
      pointsReward: (json['pointsReward'] as num?)?.toInt() ?? 10,
      isPositive: json['isPositive'] as bool? ?? true,
    );

Map<String, dynamic> _$MostLikelyPromptToJson(MostLikelyPrompt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'textPt': instance.textPt,
      'category': _$PromptCategoryEnumMap[instance.category]!,
      'pointsReward': instance.pointsReward,
      'isPositive': instance.isPositive,
    };

const _$PromptCategoryEnumMap = {
  PromptCategory.social: 'social',
  PromptCategory.romance: 'romance',
  PromptCategory.party: 'party',
  PromptCategory.work: 'work',
  PromptCategory.chaos: 'chaos',
};

MostLikelyVote _$MostLikelyVoteFromJson(Map<String, dynamic> json) =>
    MostLikelyVote(
      voterName: json['voterName'] as String,
      votedForName: json['votedForName'] as String,
    );

Map<String, dynamic> _$MostLikelyVoteToJson(MostLikelyVote instance) =>
    <String, dynamic>{
      'voterName': instance.voterName,
      'votedForName': instance.votedForName,
    };

MostLikelyResult _$MostLikelyResultFromJson(Map<String, dynamic> json) =>
    MostLikelyResult(
      prompt: MostLikelyPrompt.fromJson(json['prompt'] as Map<String, dynamic>),
      votes: (json['votes'] as List<dynamic>)
          .map((e) => MostLikelyVote.fromJson(e as Map<String, dynamic>))
          .toList(),
      winnerName: json['winnerName'] as String,
      voteCount: (json['voteCount'] as num).toInt(),
    );

Map<String, dynamic> _$MostLikelyResultToJson(MostLikelyResult instance) =>
    <String, dynamic>{
      'prompt': instance.prompt,
      'votes': instance.votes,
      'winnerName': instance.winnerName,
      'voteCount': instance.voteCount,
    };
