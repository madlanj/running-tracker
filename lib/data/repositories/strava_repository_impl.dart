import '../../domain/repositories/strava_repository.dart';
import '../datasources/strava_api_client.dart';

class StravaRepositoryImpl implements StravaRepository {
  final StravaApiClient _apiClient;

  StravaRepositoryImpl([StravaApiClient? apiClient])
      : _apiClient = apiClient ?? StravaApiClient();

  @override
  Future<bool> isAuthenticated() async {
    return await _apiClient.hasValidToken();
  }

  @override
  Future<void> authorizeWithStrava() async {
    // In production, launches OAuth2 URL in external browser/custom tab
    // When redirected to custom scheme `jakimtracker://strava-callback?code=XYZ`,
    // exchange code for access_token and refresh_token
  }

  @override
  Future<StravaRunSummary?> fetchLatestRunForDate(DateTime date) async {
    return await _apiClient.fetchRunForDate(date);
  }

  @override
  Future<void> disconnect() async {
    await _apiClient.clearAuth();
  }
}
