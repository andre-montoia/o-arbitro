class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int requiredValue;
  final AchievementType type;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.requiredValue,
    required this.type,
  });
}

enum AchievementType {
  streak, // Combo streaks
  score, // Total score
  gamesPlayed, // Games completed
  daresCompleted, // Dares finished
  social, // Social interactions
}

final List<Achievement> allAchievements = [
  // Streak Achievements
  Achievement(
    id: 'streak_3',
    title: 'Iniciante de Combo',
    description: 'Alcance um streak de 3x',
    emoji: '🔥',
    requiredValue: 3,
    type: AchievementType.streak,
  ),
  Achievement(
    id: 'streak_5',
    title: 'Mestre de Combo',
    description: 'Alcance um streak de 5x',
    emoji: '💫',
    requiredValue: 5,
    type: AchievementType.streak,
  ),
  Achievement(
    id: 'streak_10',
    title: 'Lenda do Combo',
    description: 'Alcance um streak de 10x',
    emoji: '⚡',
    requiredValue: 10,
    type: AchievementType.streak,
  ),

  // Score Achievements
  Achievement(
    id: 'score_100',
    title: 'Pontuador',
    description: 'Alcance 100 pontos',
    emoji: '🎯',
    requiredValue: 100,
    type: AchievementType.score,
  ),
  Achievement(
    id: 'score_500',
    title: 'Ás dos Pontos',
    description: 'Alcance 500 pontos',
    emoji: '🏆',
    requiredValue: 500,
    type: AchievementType.score,
  ),
  Achievement(
    id: 'score_1000',
    title: 'Rei da Pontuação',
    description: 'Alcance 1000 pontos',
    emoji: '👑',
    requiredValue: 1000,
    type: AchievementType.score,
  ),

  // Games Played
  Achievement(
    id: 'games_5',
    title: 'Jogador Casual',
    description: 'Jogue 5 partidas',
    emoji: '🎮',
    requiredValue: 5,
    type: AchievementType.gamesPlayed,
  ),
  Achievement(
    id: 'games_20',
    title: 'Viciado em Jogos',
    description: 'Jogue 20 partidas',
    emoji: '🕹️',
    requiredValue: 20,
    type: AchievementType.gamesPlayed,
  ),

  // Dares Completed
  Achievement(
    id: 'dares_10',
    title: 'Ousado',
    description: 'Complete 10 desafios',
    emoji: '😎',
    requiredValue: 10,
    type: AchievementType.daresCompleted,
  ),
  Achievement(
    id: 'dares_50',
    title: 'Destemido',
    description: 'Complete 50 desafios',
    emoji: '🦁',
    requiredValue: 50,
    type: AchievementType.daresCompleted,
  ),

  // Social
  Achievement(
    id: 'social_share',
    title: 'Compartilhador',
    description: 'Compartilhe resultados',
    emoji: '📤',
    requiredValue: 1,
    type: AchievementType.social,
  ),
];
