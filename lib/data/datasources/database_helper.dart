import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/training_day_model.dart';
import '../models/user_log_model.dart';

class DatabaseHelper {
  static const String dbName = 'jakim_tracker.db';
  static const int dbVersion = 1;

  static const String tableTrainingDays = 'training_days';
  static const String tableUserLogs = 'user_logs';

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTrainingDays (
        id INTEGER PRIMARY KEY,
        date_iso TEXT UNIQUE,
        week_number INTEGER,
        day_of_week TEXT,
        phase TEXT,
        default_status TEXT,
        default_category TEXT,
        default_distance REAL,
        default_pace TEXT,
        default_time TEXT,
        run_menu TEXT,
        alt_non_fasting_menu TEXT,
        strength_menu TEXT,
        nutrition_menu TEXT,
        is_puasa_default INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableUserLogs (
        date_iso TEXT PRIMARY KEY,
        is_fasting INTEGER,
        is_completed INTEGER,
        actual_distance REAL,
        actual_duration INTEGER,
        actual_pace TEXT,
        actual_avg_hr INTEGER,
        perceived_effort INTEGER,
        notes TEXT,
        strava_activity_id TEXT,
        swapped_with_date TEXT,
        updated_at TEXT
      )
    ''');

    await _prepopulateSchedule(db);
  }

  static Future<void> _prepopulateSchedule(Database db) async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/training_schedule.json');
      final List<dynamic> list = jsonDecode(jsonStr);

      final batch = db.batch();
      for (final item in list) {
        final model = TrainingDayModel.fromJson(item as Map<String, dynamic>);
        batch.insert(
          tableTrainingDays,
          model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      // In standalone tests or when bundle is mocked
    }
  }
}
