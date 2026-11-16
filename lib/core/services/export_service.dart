import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/training_day.dart';
import '../../domain/entities/user_log.dart';

class ExportService {
  static String generateCoachReportMarkdown({
    required List<TrainingDay> days,
    required Map<String, UserLog> logs,
    required String dateRangeLabel,
  }) {
    double totalTargetDist = 0.0;
    double totalActualDist = 0.0;
    int completedSessions = 0;
    int plannedRunSessions = 0;

    final buffer = StringBuffer();
    buffer.writeln('# 🏃 LAPORAN PROGRES LATIHAN JAKIM 2027');
    buffer.writeln('**Atlet:** Muhammad Adlan Jazuli');
    buffer.writeln('**Target Lomba:** Jakarta International Marathon 2027 — Half Marathon (Pace 7:00 / Sub-2:30)');
    buffer.writeln('**Periode Evaluasi:** $dateRangeLabel\n');

    final tableBuffer = StringBuffer();
    tableBuffer.writeln('| Tanggal | Hari | Kategori Sesi | Target (km) | Aktual (km) | Pace Aktual | Avg HR | RPE (1-5) | Catatan / Keluhan Atlet |');
    tableBuffer.writeln('| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |');

    for (final day in days) {
      final log = logs[day.dateIso];
      final isDone = log?.isCompleted ?? false;
      final targetKm = day.defaultDistance;
      final actualKm = log?.actualDistance ?? 0.0;

      if (targetKm > 0) plannedRunSessions++;
      totalTargetDist += targetKm;

      if (isDone) {
        completedSessions++;
        totalActualDist += actualKm;
      }

      final statusSymbol = isDone ? '✅' : (targetKm > 0 ? '⏳' : '💤');
      final actualPace = (log?.actualPace.isNotEmpty ?? false) ? log!.actualPace : '-';
      final actualHr = (log != null && log.actualAvgHr > 0) ? '${log.actualAvgHr} bpm' : '-';
      final effort = (log != null && log.perceivedEffort > 0) ? '${log.perceivedEffort}/5' : '-';
      final note = (log?.notes.isNotEmpty ?? false) ? log!.notes.replaceAll('|', '/') : '-';

      tableBuffer.writeln(
        '| ${day.dateIso} | ${day.dayOfWeek} | $statusSymbol ${day.defaultCategory} | '
        '${targetKm > 0 ? targetKm.toStringAsFixed(1) : '-'} | '
        '${actualKm > 0 ? actualKm.toStringAsFixed(1) : '-'} | '
        '$actualPace | $actualHr | $effort | $note |',
      );
    }

    final adherence = totalTargetDist > 0
        ? ((totalActualDist / totalTargetDist) * 100).toStringAsFixed(1)
        : '100';

    buffer.writeln('## 📊 Ringkasan Statistik');
    buffer.writeln('- **Total Jarak Target:** ${totalTargetDist.toStringAsFixed(1)} km');
    buffer.writeln('- **Total Jarak Aktual:** ${totalActualDist.toStringAsFixed(1)} km (Adherence: $adherence%)');
    buffer.writeln('- **Sesi Lari Diselesaikan:** $completedSessions dari $plannedRunSessions sesi lari yang direncanakan');
    buffer.writeln('\n## 📝 Rincian Log Harian');
    buffer.writeln(tableBuffer.toString());
    buffer.writeln('\n## 💬 Catatan untuk Coach Gemini AI:');
    buffer.writeln('> Halo Coach, tolong analisa progres latihan saya di atas. Apakah pace dan volume saya sudah di jalur yang tepat untuk target finish sub-2:30 JAKIM Juni 2027?');

    return buffer.toString();
  }

  static Future<void> copyToClipboard(String reportText) async {
    await Clipboard.setData(ClipboardData(text: reportText));
  }

  static Future<void> shareReport(String reportText) async {
    await Share.share(
      reportText,
      subject: 'Laporan Progres Latihan JAKIM 2027 - Adlan',
    );
  }
}
