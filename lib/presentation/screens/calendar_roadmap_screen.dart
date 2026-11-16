import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/training_day.dart';
import '../providers/today_mission_provider.dart';

class CalendarRoadmapScreen extends ConsumerStatefulWidget {
  const CalendarRoadmapScreen({super.key});

  @override
  ConsumerState<CalendarRoadmapScreen> createState() => _CalendarRoadmapScreenState();
}

class _CalendarRoadmapScreenState extends ConsumerState<CalendarRoadmapScreen> {
  List<TrainingDay> _allDays = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllDays();
  }

  Future<void> _loadAllDays() async {
    setState(() => _loading = true);
    final repo = ref.read(trainingRepositoryProvider);
    final days = await repo.getAllDays();
    setState(() {
      _allDays = days;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Group days by week_number (1 to 28)
    final Map<int, List<TrainingDay>> weeks = {};
    for (final d in _allDays) {
      weeks.putIfAbsent(d.weekNumber, () => []).add(d);
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        title: const Text('Roadmap 28 Minggu (197 Hari)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: weeks.length,
        itemBuilder: (ctx, idx) {
          final weekNum = idx + 1;
          final daysInWeek = weeks[weekNum] ?? [];
          final firstDay = daysInWeek.isNotEmpty ? daysInWeek.first : null;
          final phase = firstDay?.phase ?? '';
          final totalDist = daysInWeek.fold<double>(0.0, (sum, d) => sum + d.defaultDistance);

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ExpansionTile(
              initiallyExpanded: weekNum == 1,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Minggu ${weekNum.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryNavy),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${totalDist.toStringAsFixed(1)} km',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentTeal),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                phase,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              children: [
                // Button to swap Weekend Saturday & Sunday
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryNavy,
                      side: const BorderSide(color: AppColors.primaryNavy),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Tukar Jadwal Sabtu ⇄ Minggu', style: TextStyle(fontSize: 12)),
                    onPressed: () async {
                      final repo = ref.read(trainingRepositoryProvider);
                      await repo.swapWeekendDays(weekNum);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Jadwal Sabtu & Minggu di Minggu $weekNum berhasil ditukar!')),
                      );
                      await _loadAllDays();
                    },
                  ),
                ),
                const Divider(),
                // Daily items list
                ...daysInWeek.map((d) {
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: d.defaultDistance > 0 ? AppColors.accentTeal : Colors.grey.shade300,
                      child: Text(
                        d.dayOfWeek.substring(0, 1),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: d.defaultDistance > 0 ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                    title: Text(
                      '${d.dayOfWeek}, ${d.dateIso} • ${d.defaultCategory}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      d.defaultDistance > 0 ? '${d.defaultDistance} km @ ${d.defaultPace}' : 'Rest Day',
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    trailing: Text(
                      d.defaultTime.split(' ').first,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black45),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
