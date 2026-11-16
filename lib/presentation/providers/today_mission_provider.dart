import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/schedule_adapter.dart';
import '../../domain/entities/training_day.dart';
import '../../domain/entities/user_log.dart';
import '../../domain/repositories/training_repository.dart';
import '../../domain/repositories/strava_repository.dart';
import '../../data/repositories/training_repository_impl.dart';
import '../../data/repositories/strava_repository_impl.dart';

final trainingRepositoryProvider = Provider<TrainingRepository>((ref) {
  return TrainingRepositoryImpl();
});

final stravaRepositoryProvider = Provider<StravaRepository>((ref) {
  return StravaRepositoryImpl();
});

class TodayMissionState {
  final DateTime selectedDate;
  final TrainingDay? rawDay;
  final TrainingDay? adaptedDay;
  final UserLog? log;
  final bool isLoading;
  final String? errorMessage;

  const TodayMissionState({
    required this.selectedDate,
    this.rawDay,
    this.adaptedDay,
    this.log,
    this.isLoading = false,
    this.errorMessage,
  });

  TodayMissionState copyWith({
    DateTime? selectedDate,
    TrainingDay? rawDay,
    TrainingDay? adaptedDay,
    UserLog? log,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TodayMissionState(
      selectedDate: selectedDate ?? this.selectedDate,
      rawDay: rawDay ?? this.rawDay,
      adaptedDay: adaptedDay ?? this.adaptedDay,
      log: log ?? this.log,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TodayMissionNotifier extends StateNotifier<TodayMissionState> {
  final TrainingRepository _trainingRepo;
  final StravaRepository _stravaRepo;

  TodayMissionNotifier(this._trainingRepo, this._stravaRepo)
      : super(TodayMissionState(selectedDate: DateTime(2026, 11, 16))) {
    loadMissionForDate(state.selectedDate);
  }

  String _formatIso(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<void> loadMissionForDate(DateTime date) async {
    state = state.copyWith(isLoading: true, selectedDate: date, errorMessage: null);
    try {
      final iso = _formatIso(date);
      final raw = await _trainingRepo.getDayByDate(iso);
      final userLog = await _trainingRepo.getLogByDate(iso);

      final isFasting = userLog != null ? userLog.isFasting : (raw?.isPuasaDefault ?? false);
      final adapted = raw != null ? ScheduleAdapter.adaptDayForFasting(raw, isFasting) : null;

      state = state.copyWith(
        rawDay: raw,
        adaptedDay: adapted,
        log: userLog,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> toggleFasting(bool isFasting) async {
    if (state.rawDay == null) return;
    final iso = state.rawDay!.dateIso;
    await _trainingRepo.toggleFasting(iso, isFasting);
    await loadMissionForDate(state.selectedDate);
  }

  Future<void> syncWithStrava() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final summary = await _stravaRepo.fetchLatestRunForDate(state.selectedDate);
      if (summary != null) {
        final existing = state.log;
        final updatedLog = UserLog(
          dateIso: state.rawDay!.dateIso,
          isFasting: existing?.isFasting ?? state.rawDay!.isPuasaDefault,
          isCompleted: true,
          actualDistance: summary.distanceKm,
          actualDurationSeconds: summary.movingTimeSeconds,
          actualPace: summary.avgPace,
          actualAvgHr: summary.avgHeartRate,
          perceivedEffort: existing?.perceivedEffort ?? 3,
          notes: existing?.notes.isNotEmpty ?? false ? existing!.notes : 'Synced from Strava: ${summary.name}',
          stravaActivityId: summary.id,
          updatedAt: DateTime.now().toIso8601String(),
        );

        await _trainingRepo.saveUserLog(updatedLog);
        await loadMissionForDate(state.selectedDate);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Tidak ditemukan aktivitas lari Strava untuk tanggal ini.',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Gagal terhubung ke Strava: $e');
    }
  }

  Future<void> saveManualLog({
    required double actualDistance,
    required String actualPace,
    required int actualAvgHr,
    required int effort,
    required String notes,
  }) async {
    if (state.rawDay == null) return;
    final existing = state.log;
    final log = UserLog(
      dateIso: state.rawDay!.dateIso,
      isFasting: existing?.isFasting ?? state.rawDay!.isPuasaDefault,
      isCompleted: true,
      actualDistance: actualDistance,
      actualPace: actualPace,
      actualAvgHr: actualAvgHr,
      perceivedEffort: effort,
      notes: notes,
      stravaActivityId: existing?.stravaActivityId,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await _trainingRepo.saveUserLog(log);
    await loadMissionForDate(state.selectedDate);
  }
}

final todayMissionProvider = StateNotifierProvider<TodayMissionNotifier, TodayMissionState>((ref) {
  final trainingRepo = ref.watch(trainingRepositoryProvider);
  final stravaRepo = ref.watch(stravaRepositoryProvider);
  return TodayMissionNotifier(trainingRepo, stravaRepo);
});
