import '../entities/training_day.dart';
import '../entities/user_log.dart';

abstract class TrainingRepository {
  Future<void> initializeDatabase();
  Future<TrainingDay?> getDayByDate(String dateIso);
  Future<List<TrainingDay>> getAllDays();
  Future<UserLog?> getLogByDate(String dateIso);
  Future<Map<String, UserLog>> getAllLogs();
  Future<void> saveUserLog(UserLog log);
  Future<void> toggleFasting(String dateIso, bool isFasting);
  Future<void> swapWeekendDays(int weekNumber);
}
