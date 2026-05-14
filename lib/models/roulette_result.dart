class RouletteResult {
  const RouletteResult({
    required this.question,
    required this.winner,
    required this.timestamp,
  });

  factory RouletteResult.fromJson(Map<String, dynamic> json) => RouletteResult(
        question: json['question'] as String,
        winner: json['winner'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        'winner': winner,
        'timestamp': timestamp.toIso8601String(),
      };

  final String question;
  final String winner;
  final DateTime timestamp;
}
