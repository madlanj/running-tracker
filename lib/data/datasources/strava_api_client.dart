import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/repositories/strava_repository.dart';

class StravaApiClient {
  static const String baseUrl = 'https://www.strava.com/api/v3';
  static const String tokenUrl = 'https://www.strava.com/oauth/token';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  // Strava App Credentials (set via settings or config)
  static const String _kAccessToken = 'strava_access_token';
  static const String _kRefreshToken = 'strava_refresh_token';
  static const String _kExpiresAt = 'strava_expires_at';

  StravaApiClient({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<bool> hasValidToken() async {
    final token = await _storage.read(key: _kAccessToken);
    return token != null && token.isNotEmpty;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresAt,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
    await _storage.write(key: _kExpiresAt, value: expiresAt.toString());
  }

  Future<String?> getAccessToken() async {
    final expiresAtStr = await _storage.read(key: _kExpiresAt);
    if (expiresAtStr != null) {
      final expiresAt = int.tryParse(expiresAtStr) ?? 0;
      final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (nowSeconds >= expiresAt - 300) {
        // Token will expire in 5 minutes -> refresh
        await _refreshToken();
      }
    }
    return await _storage.read(key: _kAccessToken);
  }

  Future<void> _refreshToken() async {
    final refreshToken = await _storage.read(key: _kRefreshToken);
    if (refreshToken == null) return;

    try {
      final response = await _client.post(
        Uri.parse(tokenUrl),
        body: {
          'client_id': 'YOUR_STRAVA_CLIENT_ID',
          'client_secret': 'YOUR_STRAVA_CLIENT_SECRET',
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String,
          expiresAt: data['expires_at'] as int,
        );
      }
    } catch (_) {
      // Ignore if offline
    }
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kExpiresAt);
  }

  /// Fetches activities for a specific local date (00:00 to 23:59 WIB)
  Future<StravaRunSummary?> fetchRunForDate(DateTime date) async {
    final token = await getAccessToken();
    if (token == null) return null;

    final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch ~/ 1000;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch ~/ 1000;

    final uri = Uri.parse('$baseUrl/athlete/activities?after=$startOfDay&before=$endOfDay&per_page=10');

    try {
      final response = await _client.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> activities = jsonDecode(response.body);
        for (final act in activities) {
          if (act['type'] == 'Run') {
            return parseRunActivity(act as Map<String, dynamic>);
          }
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Parses raw Strava activity JSON into clean domain summary
  static StravaRunSummary parseRunActivity(Map<String, dynamic> act) {
    final distanceM = (act['distance'] as num?)?.toDouble() ?? 0.0;
    final distanceKm = distanceM / 1000.0;
    final movingTimeS = act['moving_time'] as int? ?? 0;

    String pace = '0:00';
    if (distanceKm > 0 && movingTimeS > 0) {
      final secPerKm = movingTimeS / distanceKm;
      final m = secPerKm ~/ 60;
      final s = (secPerKm % 60).toInt();
      pace = '$m:${s.toString().padLeft(2, '0')}';
    }

    return StravaRunSummary(
      id: act['id'].toString(),
      name: (act['name'] ?? 'Morning Run') as String,
      distanceKm: double.parse(distanceKm.toStringAsFixed(2)),
      movingTimeSeconds: movingTimeS,
      avgPace: pace,
      avgHeartRate: (act['average_heartrate'] as num?)?.toInt() ?? 0,
      maxHeartRate: (act['max_heartrate'] as num?)?.toInt() ?? 0,
      startDateIso: (act['start_date_local'] ?? DateTime.now().toIso8601String()) as String,
    );
  }
}
