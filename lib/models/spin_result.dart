enum DareCategory { social, fisico, mental, wild }
enum DareIntensity { casual, ousado, epico }

class SpinResult {
  const SpinResult({
    required this.player,
    required this.category,
    required this.intensity,
    required this.dare,
    required this.accepted,
  });

  final String player;
  final DareCategory category;
  final DareIntensity intensity;
  final String dare;
  final bool accepted;
}
