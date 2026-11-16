class StravaRunSummary {
  final String id;
  final String name;
  final double distanceKm;
  final int movingTimeSeconds;
  final String avgPace;
  final int avgHeartRate;
  final int maxHeartRate;
  final String startDateIso;

  const StravaRunSummary({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.movingTimeSeconds,
    required this.avgPace,
    required this.avgHeartRate,
    required this.maxHeartRate,
    required this.startDateIso,
  });
}

abstract class StravaRepository {
  Future<bool> isAuthenticated();
  Future<void> authorizeWithStrava();
  Future<StravaRunSummary?> fetchLatestRunForDate(DateTime date);
  Future<void> disconnect();
}
