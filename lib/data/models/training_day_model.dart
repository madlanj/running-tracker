import '../../domain/entities/training_day.dart';

class TrainingDayModel extends TrainingDay {
  const TrainingDayModel({
    required super.id,
    required super.dateIso,
    required super.weekNumber,
    required super.dayOfWeek,
    required super.phase,
    required super.defaultStatus,
    required super.defaultCategory,
    required super.defaultDistance,
    required super.defaultPace,
    required super.defaultTime,
    required super.runMenu,
    required super.altNonFastingMenu,
    required super.strengthMenu,
    required super.nutritionMenu,
    required super.isPuasaDefault,
  });

  factory TrainingDayModel.fromJson(Map<String, dynamic> json) {
    return TrainingDayModel(
      id: json['id'] as int,
      dateIso: json['date_iso'] as String,
      weekNumber: json['week_number'] as int,
      dayOfWeek: json['day_of_week'] as String,
      phase: json['phase'] as String,
      defaultStatus: json['default_status'] as String,
      defaultCategory: json['default_category'] as String,
      defaultDistance: (json['default_distance'] as num).toDouble(),
      defaultPace: json['default_pace'] as String,
      defaultTime: json['default_time'] as String,
      runMenu: json['run_menu'] as String,
      altNonFastingMenu: (json['alt_non_fasting_menu'] ?? '') as String,
      strengthMenu: json['strength_menu'] as String,
      nutritionMenu: json['nutrition_menu'] as String,
      isPuasaDefault: json['is_puasa_default'] as bool,
    );
  }

  factory TrainingDayModel.fromMap(Map<String, dynamic> map) {
    return TrainingDayModel(
      id: map['id'] as int,
      dateIso: map['date_iso'] as String,
      weekNumber: map['week_number'] as int,
      dayOfWeek: map['day_of_week'] as String,
      phase: map['phase'] as String,
      defaultStatus: map['default_status'] as String,
      defaultCategory: map['default_category'] as String,
      defaultDistance: (map['default_distance'] as num).toDouble(),
      defaultPace: map['default_pace'] as String,
      defaultTime: map['default_time'] as String,
      runMenu: map['run_menu'] as String,
      altNonFastingMenu: (map['alt_non_fasting_menu'] ?? '') as String,
      strengthMenu: map['strength_menu'] as String,
      nutritionMenu: map['nutrition_menu'] as String,
      isPuasaDefault: (map['is_puasa_default'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date_iso': dateIso,
      'week_number': weekNumber,
      'day_of_week': dayOfWeek,
      'phase': phase,
      'default_status': defaultStatus,
      'default_category': defaultCategory,
      'default_distance': defaultDistance,
      'default_pace': defaultPace,
      'default_time': defaultTime,
      'run_menu': runMenu,
      'alt_non_fasting_menu': altNonFastingMenu,
      'strength_menu': strengthMenu,
      'nutrition_menu': nutritionMenu,
      'is_puasa_default': isPuasaDefault ? 1 : 0,
    };
  }
}
