class NeverHaveIEverStatement {
  final String id;
  final String text;
  final String category;
  final int intensity; // 1-3 (mild, wild, chaotic)

  NeverHaveIEverStatement({
    required this.id,
    required this.text,
    required this.category,
    this.intensity = 1,
  });

  factory NeverHaveIEverStatement.fromJson(Map<String, dynamic> json) {
    return NeverHaveIEverStatement(
      id: json['id'],
      text: json['text'],
      category: json['category'],
      intensity: json['intensity'] ?? 1,
    );
  }
}

class PlayerFingerState {
  final String playerId;
  int fingersDown; // 5 fingers initially
  int drinksTaken;

  PlayerFingerState({
    required this.playerId,
    this.fingersDown = 5,
    this.drinksTaken = 0,
  });

  bool get hasFingersUp => fingersDown > 0;

  void putFingerDown() {
    if (fingersDown > 0) {
      fingersDown--;
    }
  }

  void resetFingers() {
    fingersDown = 5;
  }
}
