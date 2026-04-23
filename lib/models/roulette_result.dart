class RouletteResult {
  const RouletteResult({
    required this.question,
    required this.winner,
    required this.timestamp,
  });

  final String question;
  final String winner;
  final DateTime timestamp;
}
