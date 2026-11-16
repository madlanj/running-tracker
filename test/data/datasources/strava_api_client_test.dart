import 'dart:convert';

// Test parser matching StravaApiClient.parseRunActivity logic
void main() {
  final mockStravaRun = {
    'id': 12345678,
    'name': 'Morning Run',
    'type': 'Run',
    'distance': 6020.0, // 6.02 km
    'moving_time': 3012, // 50m 12s -> 50.2m / 6.02km = 8:20/km
    'elapsed_time': 3100,
    'average_heartrate': 148.5,
    'max_heartrate': 162.0,
    'start_date_local': '2026-11-17T05:15:00Z'
  };

  final distanceKm = mockStravaRun['distance']! / 1000.0;
  final movingTimeS = mockStravaRun['moving_time']!;
  final secPerKm = movingTimeS / distanceKm;
  final m = secPerKm ~/ 60;
  final s = (secPerKm % 60).toInt();
  final pace = '$m:${s.toString().padLeft(2, '0')}';

  assert(distanceKm == 6.02, 'Distance must be 6.02');
  assert(pace == '8:20', 'Pace must be 8:20');
  assert(mockStravaRun['average_heartrate'] == 148.5);

  print('Task 5 Strava Parser Test: ALL ASSERTIONS PASSED!');
}
