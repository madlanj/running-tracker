import '../../domain/entities/user_log.dart';

class UserLogModel extends UserLog {
  const UserLogModel({
    required super.dateIso,
    required super.isFasting,
    required super.isCompleted,
    super.actualDistance,
    super.actualDurationSeconds,
    super.actualPace,
    super.actualAvgHr,
    super.perceivedEffort,
    super.notes,
    super.stravaActivityId,
    super.swappedWithDate,
    required super.updatedAt,
  });

  factory UserLogModel.fromMap(Map<String, dynamic> map) {
    return UserLogModel(
      dateIso: map['date_iso'] as String,
      isFasting: (map['is_fasting'] as int) == 1,
      isCompleted: (map['is_completed'] as int) == 1,
      actualDistance: (map['actual_distance'] as num?)?.toDouble() ?? 0.0,
      actualDurationSeconds: map['actual_duration'] as int? ?? 0,
      actualPace: map['actual_pace'] as String? ?? '',
      actualAvgHr: map['actual_avg_hr'] as int? ?? 0,
      perceivedEffort: map['perceived_effort'] as int? ?? 3,
      notes: map['notes'] as String? ?? '',
      stravaActivityId: map['strava_activity_id'] as String?,
      swappedWithDate: map['swapped_with_date'] as String?,
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date_iso': dateIso,
      'is_fasting': isFasting ? 1 : 0,
      'is_completed': isCompleted ? 1 : 0,
      'actual_distance': actualDistance,
      'actual_duration': actualDurationSeconds,
      'actual_pace': actualPace,
      'actual_avg_hr': actualAvgHr,
      'perceived_effort': perceivedEffort,
      'notes': notes,
      'strava_activity_id': stravaActivityId,
      'swapped_with_date': swappedWithDate,
      'updated_at': updatedAt,
    };
  }
}
