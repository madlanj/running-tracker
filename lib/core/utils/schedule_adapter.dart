import '../../domain/entities/training_day.dart';

class ScheduleAdapter {
  /// Adapts Monday or Thursday workout if the user is NOT fasting.
  static TrainingDay adaptDayForFasting(TrainingDay originalDay, bool isFasting) {
    final isMonOrThu = originalDay.dayOfWeek == 'Senin' || originalDay.dayOfWeek == 'Kamis';
    final isRamadhan = originalDay.phase.contains('Ramadhan');

    // Outside Ramadhan, if user is NOT fasting on Monday or Thursday:
    if (isMonOrThu && !isRamadhan && !isFasting) {
      return originalDay.copyWith(
        defaultStatus: 'Normal (Tidak Puasa)',
        defaultCategory: 'Easy Aerobic Run',
        defaultDistance: 5.0,
        defaultPace: 'Pace 8:15 - 8:35 (Zone 2, HR < 150 bpm)',
        defaultTime: '05.15 - 06.00 WIB',
        runMenu: 'Lari santai 5.0 km di zona aerobik nyaman sebelum jam kerja (05.15 WIB). Diakhiri peregangan ringan 5 menit.',
        nutritionMenu: 'Pagi: Minum 250ml air sebelum lari. Pasca lari: Sarapan seimbang (nasi/oat + 2 telur + buah). Penuhi hidrasi 2.5L sepanjang hari.',
      );
    }

    return originalDay;
  }

  /// Swaps Saturday workout with Sunday workout (e.g. Long Run shifted to Sunday).
  static (TrainingDay, TrainingDay) swapSaturdaySunday(TrainingDay sat, TrainingDay sun) {
    final newSat = sat.copyWith(
      defaultCategory: sun.defaultCategory,
      defaultDistance: sun.defaultDistance,
      defaultPace: sun.defaultPace,
      defaultTime: sun.defaultTime,
      runMenu: sun.runMenu,
      strengthMenu: sun.strengthMenu,
      nutritionMenu: sun.nutritionMenu,
    );

    final newSun = sun.copyWith(
      defaultCategory: sat.defaultCategory,
      defaultDistance: sat.defaultDistance,
      defaultPace: sat.defaultPace,
      defaultTime: sat.defaultTime,
      runMenu: sat.runMenu,
      strengthMenu: sat.strengthMenu,
      nutritionMenu: sat.nutritionMenu,
    );

    return (newSat, newSun);
  }
}
