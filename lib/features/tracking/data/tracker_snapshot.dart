class TrackerSnapshot {
  const TrackerSnapshot({
    required this.steps, required this.distanceKm, required this.calories,
    required this.isTracking, required this.sensorAvailable,
    required this.history, required this.today,
  });
  final int steps;
  final double distanceKm;
  final double calories;
  final bool isTracking;
  final bool sensorAvailable;
  final List<DailyRecord> history;
  final String today;

  factory TrackerSnapshot.fromMap(Map<dynamic, dynamic> map) {
    final records = (map['history'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => DailyRecord.fromMap(item))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return TrackerSnapshot(
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
      calories: (map['calories'] as num?)?.toDouble() ?? 0,
      isTracking: map['isTracking'] as bool? ?? false,
      sensorAvailable: map['sensorAvailable'] as bool? ?? false,
      history: records, today: map['today'] as String? ?? '',
    );
  }

  factory TrackerSnapshot.empty() => const TrackerSnapshot(
    steps: 0, distanceKm: 0, calories: 0, isTracking: false,
    sensorAvailable: false, history: [], today: '',
  );
}

class DailyRecord {
  const DailyRecord({
    required this.date, required this.steps,
    required this.distanceKm, required this.calories,
  });
  final String date;
  final int steps;
  final double distanceKm;
  final double calories;

  factory DailyRecord.fromMap(Map<dynamic, dynamic> map) => DailyRecord(
    date: map['date']?.toString() ?? '',
    steps: (map['steps'] as num?)?.toInt() ?? 0,
    distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
    calories: (map['calories'] as num?)?.toDouble() ?? 0,
  );
}
