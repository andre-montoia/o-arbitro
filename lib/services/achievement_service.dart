import 'package:shared_preferences/shared_preferences.dart';
import 'package:o_arbitro/models/achievement.dart';

class AchievementService {
  static const String _prefix = 'achievement_';
  static const String _gamesPlayedKey = 'games_played';
  static const String _totalScoreKey = 'total_score';
  static const String _daresCompletedKey = 'dares_completed';

  static Future<Set<String>> getUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_prefix\_unlocked')?.toSet() ?? {};
  }

  static Future<void> unlockAchievement(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = await getUnlockedAchievements();
    if (!unlocked.contains(achievementId)) {
      unlocked.add(achievementId);
      await prefs.setStringList('$_prefix\_unlocked', unlocked.toList());
    }
  }

  static Future<bool> isUnlocked(String achievementId) async {
    final unlocked = await getUnlockedAchievements();
    return unlocked.contains(achievementId);
  }

  static Future<Map<String, dynamic>> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'gamesPlayed': prefs.getInt(_gamesPlayedKey) ?? 0,
      'totalScore': prefs.getInt(_totalScoreKey) ?? 0,
      'daresCompleted': prefs.getInt(_daresCompletedKey) ?? 0,
    };
  }

  static Future<void> incrementGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_gamesPlayedKey) ?? 0;
    await prefs.setInt(_gamesPlayedKey, current + 1);
    await checkAchievements(AchievementType.gamesPlayed, current + 1);
  }

  static Future<void> addScore(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalScoreKey) ?? 0;
    final newTotal = current + points;
    await prefs.setInt(_totalScoreKey, newTotal);
    await checkAchievements(AchievementType.score, newTotal);
  }

  static Future<void> incrementDaresCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_daresCompletedKey) ?? 0;
    await prefs.setInt(_daresCompletedKey, current + 1);
    await checkAchievements(AchievementType.daresCompleted, current + 1);
  }

  static Future<void> checkAchievements(
      AchievementType type, int value) async {
    for (final achievement in allAchievements) {
      if (achievement.type == type && value >= achievement.requiredValue) {
        await unlockAchievement(achievement.id);
      }
    }
  }

  static Future<List<Achievement>> getNewlyUnlocked() async {
    final unlocked = await getUnlockedAchievements();
    return allAchievements
        .where((a) => unlocked.contains(a.id))
        .toList();
  }
}
