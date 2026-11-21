import 'package:flutter_test/flutter_test.dart';
import 'package:khotwaty/features/tracking/data/tracker_snapshot.dart';

void main() {
  group('TrackerSnapshot', () {
    test('parses totals and daily history from the native bridge', () {
      final snapshot = TrackerSnapshot.fromMap({
        'steps': 4321,
        'distanceKm': 3.14,
        'calories': 210.5,
        'isTracking': true,
        'sensorAvailable': true,
        'today': '2026-11-21',
        'history': [
          {
            'date': '2026-11-20',
            'steps': 3000,
            'distanceKm': 2.1,
            'calories': 145.0,
          }
        ],
      });

      expect(snapshot.steps, 4321);
      expect(snapshot.distanceKm, 3.14);
      expect(snapshot.calories, 210.5);
      expect(snapshot.isTracking, isTrue);
      expect(snapshot.sensorAvailable, isTrue);
      expect(snapshot.history.single.steps, 3000);
    });

    test('uses safe defaults when native values are missing', () {
      final snapshot = TrackerSnapshot.fromMap(<String, dynamic>{});

      expect(snapshot.steps, 0);
      expect(snapshot.distanceKm, 0);
      expect(snapshot.calories, 0);
      expect(snapshot.isTracking, isFalse);
      expect(snapshot.history, isEmpty);
    });
  });
}
