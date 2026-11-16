class UserLog {
  final String dateIso;
  final bool isFasting;
  final bool isCompleted;
  final double actualDistance;
  final int actualDurationSeconds;
  final String actualPace;
  final int actualAvgHr;
  final int perceivedEffort; // 1 to 5
  final String notes;
  final String? stravaActivityId;
  final String? swappedWithDate;
  final String updatedAt;

  const UserLog({
    required this.dateIso,
    required this.isFasting,
    required this.isCompleted,
    this.actualDistance = 0.0,
    this.actualDurationSeconds = 0,
    this.actualPace = '',
    this.actualAvgHr = 0,
    this.perceivedEffort = 3,
    this.notes = '',
    this.stravaActivityId,
    this.swappedWithDate,
    required this.updatedAt,
  });

  UserLog copyWith({
    String? dateIso,
    bool? isFasting,
    bool? isCompleted,
    double? actualDistance,
    int? actualDurationSeconds,
    String? actualPace,
    int? actualAvgHr,
    int? perceivedEffort,
    String? notes,
    String? stravaActivityId,
    String? swappedWithDate,
    String? updatedAt,
  }) {
    return UserLog(
      dateIso: dateIso ?? this.dateIso,
      isFasting: isFasting ?? this.isFasting,
      isCompleted: isCompleted ?? this.isCompleted,
      actualDistance: actualDistance ?? this.actualDistance,
      actualDurationSeconds: actualDurationSeconds ?? this.actualDurationSeconds,
      actualPace: actualPace ?? this.actualPace,
      actualAvgHr: actualAvgHr ?? this.actualAvgHr,
      perceivedEffort: perceivedEffort ?? this.perceivedEffort,
      notes: notes ?? this.notes,
      stravaActivityId: stravaActivityId ?? this.stravaActivityId,
      swappedWithDate: swappedWithDate ?? this.swappedWithDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
