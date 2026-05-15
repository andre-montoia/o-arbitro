import 'package:json_annotation/json_annotation.dart';
import 'player.dart';

part 'most_likely_prompt.g.dart';

@JsonSerializable()
class MostLikelyPrompt {
  const MostLikelyPrompt({
    required this.id,
    required this.textPt,
    required this.category,
    this.pointsReward = 10,
    this.isPositive = true,
  });

  final String id;
  final String textPt; // "Mais provável de..."
  final PromptCategory category;
  final int pointsReward;
  final bool isPositive; // true = points to voted person; false = dare for voted person

  factory MostLikelyPrompt.fromJson(Map<String, dynamic> json) =>
      _$MostLikelyPromptFromJson(json);

  Map<String, dynamic> toJson() => _$MostLikelyPromptToJson(this);
}

enum PromptCategory {
  social, // Comportamental
  romance, // Romance/Relacionamentos
  party, // Festa/Bebeida
  work, // Trabalho
  chaos, // Caos total
}

@JsonSerializable()
class MostLikelyVote {
  const MostLikelyVote({
    required this.voterName,
    required this.votedForName,
  });

  final String voterName;
  final String votedForName;

  factory MostLikelyVote.fromJson(Map<String, dynamic> json) =>
      _$MostLikelyVoteFromJson(json);

  Map<String, dynamic> toJson() => _$MostLikelyVoteToJson(this);
}

@JsonSerializable()
class MostLikelyResult {
  const MostLikelyResult({
    required this.prompt,
    required this.votes,
    required this.winnerName,
    required this.voteCount,
  });

  final MostLikelyPrompt prompt;
  final List<MostLikelyVote> votes;
  final String winnerName;
  final int voteCount;

  factory MostLikelyResult.fromJson(Map<String, dynamic> json) =>
      _$MostLikelyResultFromJson(json);

  Map<String, dynamic> toJson() => _$MostLikelyResultToJson(this);
}

// Prompt database
class MostLikelyPrompts {
  static const List<MostLikelyPrompt> all = [
    // Social
    MostLikelyPrompt(
      id: 'social_01',
      textPt: 'Mais provável de ficar famoso no TikTok',
      category: PromptCategory.social,
      pointsReward: 15,
    ),
    MostLikelyPrompt(
      id: 'social_02',
      textPt: 'Mais provável de se casar primeiro',
      category: PromptCategory.romance,
      pointsReward: 10,
    ),
    MostLikelyPrompt(
      id: 'social_03',
      textPt: 'Mais provável de se tornar um influencer',
      category: PromptCategory.social,
      pointsReward: 15,
    ),
    // Party
    MostLikelyPrompt(
      id: 'party_01',
      textPt: 'Mais provável de beber todo o álcool no bar',
      category: PromptCategory.party,
      pointsReward: 10,
      isPositive: false,
    ),
    MostLikelyPrompt(
      id: 'party_02',
      textPt: 'Mais provável de dormir na festa',
      category: PromptCategory.party,
      pointsReward: 10,
      isPositive: false,
    ),
    MostLikelyPrompt(
      id: 'party_03',
      textPt: 'Mais provável de dar choque em alguém dançando',
      category: PromptCategory.party,
      pointsReward: 12,
    ),
    // Chaos
    MostLikelyPrompt(
      id: 'chaos_01',
      textPt: 'Mais provável de causar um apagão',
      category: PromptCategory.chaos,
      pointsReward: 20,
    ),
    MostLikelyPrompt(
      id: 'chaos_02',
      textPt: 'Mais provável de ser expulso de um lugar',
      category: PromptCategory.chaos,
      pointsReward: 15,
      isPositive: false,
    ),
    MostLikelyPrompt(
      id: 'chaos_03',
      textPt: 'Mais provável de começar uma briga (brincadeira)',
      category: PromptCategory.chaos,
      pointsReward: 15,
    ),
    // Work
    MostLikelyPrompt(
      id: 'work_01',
      textPt: 'Mais provável de se tornar CEO',
      category: PromptCategory.work,
      pointsReward: 15,
    ),
    MostLikelyPrompt(
      id: 'work_02',
      textPt: 'Mais provável de trabalhar no sabado',
      category: PromptCategory.work,
      pointsReward: 10,
      isPositive: false,
    ),
    // Romance
    MostLikelyPrompt(
      id: 'romance_01',
      textPt: 'Mais provável de ter um romance de verão',
      category: PromptCategory.romance,
      pointsReward: 12,
    ),
    MostLikelyPrompt(
      id: 'romance_02',
      textPt: 'Mais provável de dar um fora em público',
      category: PromptCategory.romance,
      pointsReward: 10,
      isPositive: false,
    ),
  ];

  static MostLikelyPrompt getRandom() {
    all.shuffle();
    return all.first;
  }

  static List<MostLikelyPrompt> getByCategory(PromptCategory cat) {
    return all.where((p) => p.category == cat).toList();
  }
}
