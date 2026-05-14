
enum DareCategory { social, fisico, mental, wild }
enum DareIntensity { casual, ousado, epico, castigo }

class SpinResult {
  const SpinResult({
    required this.player,
    required this.category,
    required this.intensity,
    required this.dare,
    required this.accepted,
  });

  factory SpinResult.fromJson(Map<String, dynamic> json) => SpinResult(
        player: json['player'] as String,
        category: _parseCategory(json['category'] as String?),
        intensity: _parseIntensity(json['intensity'] as String?),
        dare: json['dare'] as String,
        accepted: json['accepted'] as bool,
      );

  static DareCategory _parseCategory(String? c) => switch (c) {
        'fisico' => DareCategory.fisico,
        'mental' => DareCategory.mental,
        'wild' => DareCategory.wild,
        _ => DareCategory.social,
      };

  static DareIntensity _parseIntensity(String? i) => switch (i) {
        'ousado' => DareIntensity.ousado,
        'epico' => DareIntensity.epico,
        'castigo' => DareIntensity.castigo,
        _ => DareIntensity.casual,
      };

  Map<String, dynamic> toJson() => {
        'player': player,
        'category': _categoryString(category),
        'intensity': _intensityString(intensity),
        'dare': dare,
        'accepted': accepted,
      };

  static String _categoryString(DareCategory c) => switch (c) {
        DareCategory.social => 'social',
        DareCategory.fisico => 'fisico',
        DareCategory.mental => 'mental',
        DareCategory.wild => 'wild',
      };

  static String _intensityString(DareIntensity i) => switch (i) {
        DareIntensity.casual => 'casual',
        DareIntensity.ousado => 'ousado',
        DareIntensity.epico => 'epico',
        DareIntensity.castigo => 'castigo',
      };

  final String player;
  final DareCategory category;
  final DareIntensity intensity;
  final String dare;
  final bool accepted;
}
