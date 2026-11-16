class TrainingDay {
  final int id;
  final String dateIso;
  final int weekNumber;
  final String dayOfWeek;
  final String phase;
  final String defaultStatus;
  final String defaultCategory;
  final double defaultDistance;
  final String defaultPace;
  final String defaultTime;
  final String runMenu;
  final String altNonFastingMenu;
  final String strengthMenu;
  final String nutritionMenu;
  final bool isPuasaDefault;

  const TrainingDay({
    required this.id,
    required this.dateIso,
    required this.weekNumber,
    required this.dayOfWeek,
    required this.phase,
    required this.defaultStatus,
    required this.defaultCategory,
    required this.defaultDistance,
    required this.defaultPace,
    required this.defaultTime,
    required this.runMenu,
    required this.altNonFastingMenu,
    required this.strengthMenu,
    required this.nutritionMenu,
    required this.isPuasaDefault,
  });

  TrainingDay copyWith({
    int? id,
    String? dateIso,
    int? weekNumber,
    String? dayOfWeek,
    String? phase,
    String? defaultStatus,
    String? defaultCategory,
    double? defaultDistance,
    String? defaultPace,
    String? defaultTime,
    String? runMenu,
    String? altNonFastingMenu,
    String? strengthMenu,
    String? nutritionMenu,
    bool? isPuasaDefault,
  }) {
    return TrainingDay(
      id: id ?? this.id,
      dateIso: dateIso ?? this.dateIso,
      weekNumber: weekNumber ?? this.weekNumber,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      phase: phase ?? this.phase,
      defaultStatus: defaultStatus ?? this.defaultStatus,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      defaultDistance: defaultDistance ?? this.defaultDistance,
      defaultPace: defaultPace ?? this.defaultPace,
      defaultTime: defaultTime ?? this.defaultTime,
      runMenu: runMenu ?? this.runMenu,
      altNonFastingMenu: altNonFastingMenu ?? this.altNonFastingMenu,
      strengthMenu: strengthMenu ?? this.strengthMenu,
      nutritionMenu: nutritionMenu ?? this.nutritionMenu,
      isPuasaDefault: isPuasaDefault ?? this.isPuasaDefault,
    );
  }
}
