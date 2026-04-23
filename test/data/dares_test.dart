import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/data/dares.dart';
import 'package:o_arbitro/models/spin_result.dart';

void main() {
  test('every category+intensity bucket has at least 5 dares', () {
    for (final cat in DareCategory.values) {
      for (final intensity in DareIntensity.values) {
        final bucket = Dares.get(cat, intensity);
        expect(bucket.length, greaterThanOrEqualTo(5),
          reason: '${cat.name}/${intensity.name} has only ${bucket.length} dares');
      }
    }
  });

  test('random dare returns a non-empty string', () {
    final dare = Dares.random(DareCategory.social, DareIntensity.casual);
    expect(dare.isNotEmpty, true);
  });

  test('all dares are non-empty strings', () {
    for (final cat in DareCategory.values) {
      for (final intensity in DareIntensity.values) {
        for (final dare in Dares.get(cat, intensity)) {
          expect(dare.isNotEmpty, true,
            reason: 'Empty dare found in ${cat.name}/${intensity.name}');
        }
      }
    }
  });
}
