import 'package:sqflite/sqflite.dart';
import '../../domain/entities/training_day.dart';
import '../../domain/entities/user_log.dart';
import '../../domain/repositories/training_repository.dart';
import '../datasources/database_helper.dart';
import '../models/training_day_model.dart';
import '../models/user_log_model.dart';

class TrainingRepositoryImpl implements TrainingRepository {
  final Database? _overrideDb;

  TrainingRepositoryImpl([this._overrideDb]);

  Future<Database> get _db async => _overrideDb ?? await DatabaseHelper.database;

  @override
  Future<void> initializeDatabase() async {
    await _db;
  }

  @override
  Future<TrainingDay?> getDayByDate(String dateIso) async {
    final db = await _db;
    final maps = await db.query(
      DatabaseHelper.tableTrainingDays,
      where: 'date_iso = ?',
      whereArgs: [dateIso],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TrainingDayModel.fromMap(maps.first);
  }

  @override
  Future<List<TrainingDay>> getAllDays() async {
    final db = await _db;
    final maps = await db.query(
      DatabaseHelper.tableTrainingDays,
      orderBy: 'id ASC',
    );
    return maps.map((m) => TrainingDayModel.fromMap(m)).toList();
  }

  @override
  Future<UserLog?> getLogByDate(String dateIso) async {
    final db = await _db;
    final maps = await db.query(
      DatabaseHelper.tableUserLogs,
      where: 'date_iso = ?',
      whereArgs: [dateIso],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return UserLogModel.fromMap(maps.first);
  }

  @override
  Future<Map<String, UserLog>> getAllLogs() async {
    final db = await _db;
    final maps = await db.query(DatabaseHelper.tableUserLogs);
    final result = <String, UserLog>{};
    for (final m in maps) {
      final log = UserLogModel.fromMap(m);
      result[log.dateIso] = log;
    }
    return result;
  }

  @override
  Future<void> saveUserLog(UserLog log) async {
    final db = await _db;
    final model = UserLogModel(
      dateIso: log.dateIso,
      isFasting: log.isFasting,
      isCompleted: log.isCompleted,
      actualDistance: log.actualDistance,
      actualDurationSeconds: log.actualDurationSeconds,
      actualPace: log.actualPace,
      actualAvgHr: log.actualAvgHr,
      perceivedEffort: log.perceivedEffort,
      notes: log.notes,
      stravaActivityId: log.stravaActivityId,
      swappedWithDate: log.swappedWithDate,
      updatedAt: DateTime.now().toIso8601String(),
    );

    await db.insert(
      DatabaseHelper.tableUserLogs,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> toggleFasting(String dateIso, bool isFasting) async {
    final existingLog = await getLogByDate(dateIso);
    if (existingLog != null) {
      final updated = existingLog.copyWith(isFasting: isFasting);
      await saveUserLog(updated);
    } else {
      final newLog = UserLog(
        dateIso: dateIso,
        isFasting: isFasting,
        isCompleted: false,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await saveUserLog(newLog);
    }
  }

  @override
  Future<void> swapWeekendDays(int weekNumber) async {
    final db = await _db;
    final weekendDays = await db.query(
      DatabaseHelper.tableTrainingDays,
      where: 'week_number = ? AND (day_of_week = ? OR day_of_week = ?)',
      whereArgs: [weekNumber, 'Sabtu', 'Minggu'],
      orderBy: 'id ASC',
    );

    if (weekendDays.length == 2) {
      final sat = TrainingDayModel.fromMap(weekendDays[0]);
      final sun = TrainingDayModel.fromMap(weekendDays[1]);

      final satLog = await getLogByDate(sat.dateIso) ??
          UserLog(
            dateIso: sat.dateIso,
            isFasting: sat.isPuasaDefault,
            isCompleted: false,
            updatedAt: DateTime.now().toIso8601String(),
          );

      final sunLog = await getLogByDate(sun.dateIso) ??
          UserLog(
            dateIso: sun.dateIso,
            isFasting: sun.isPuasaDefault,
            isCompleted: false,
            updatedAt: DateTime.now().toIso8601String(),
          );

      // Record swapped association
      await saveUserLog(satLog.copyWith(swappedWithDate: sun.dateIso));
      await saveUserLog(sunLog.copyWith(swappedWithDate: sat.dateIso));
    }
  }
}
