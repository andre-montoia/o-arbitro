class SpeedDare {
  final String id;
  final String text;
  final String category;
  final int difficulty; // 1-3 (easy, medium, hard)
  final int timeLimit; // seconds

  SpeedDare({
    required this.id,
    required this.text,
    required this.category,
    this.difficulty = 1,
    this.timeLimit = 30,
  });

  factory SpeedDare.fromJson(Map<String, dynamic> json) {
    return SpeedDare(
      id: json['id'],
      text: json['text'],
      category: json['category'],
      difficulty: json['difficulty'] ?? 1,
      timeLimit: json['timeLimit'] ?? 30,
    );
  }
}

class SpeedDareRound {
  final List<SpeedDare> dares;
  int currentIndex;
  int streak;
  int score;
  final Map<int, bool> completed; // dare index -> completed

  SpeedDareRound({
    required this.dares,
    this.currentIndex = 0,
    this.streak = 0,
    this.score = 0,
    Map<int, bool>? completed,
  }) : completed = completed ?? {};

  SpeedDare get currentDare => dares[currentIndex];

  bool get isComplete => currentIndex >= dares.length;

  void completeDare(bool success) {
    completed[currentIndex] = success;
    if (success) {
      streak++;
      score += (10 * streak); // Combo multiplier
    } else {
      streak = 0;
    }
    currentIndex++;
  }
}
