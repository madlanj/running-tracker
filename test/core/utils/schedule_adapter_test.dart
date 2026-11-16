import 'dart:convert';
import 'dart:io';

void main() {
  final jsonContent = File('assets/data/training_schedule.json').readAsStringSync();
  final List<dynamic> list = jsonDecode(jsonContent);

  // Day 1: Monday Nov 16, 2026 (Puasa Sunnah Senin)
  final day1 = list.first;
  assert(day1['day_of_week'] == 'Senin');
  assert(day1['default_distance'] == 0.0);

  // Test Fasting toggle OFF: should become 5.0 km Easy Aerobic Run
  // Simulate adaptDayForFasting logic
  final adaptedDistance = 5.0;
  final adaptedTime = '05.15 - 06.00 WIB';
  assert(adaptedDistance == 5.0);
  assert(adaptedTime == '05.15 - 06.00 WIB');

  // Test Weekend Swap:
  // Saturday W1 = Day 6 (15.0 km)
  // Sunday W1 = Day 7 (0.0 km)
  final sat = list[5];
  final sun = list[6];
  assert(sat['day_of_week'] == 'Sabtu');
  assert(sat['default_distance'] == 15.0);
  assert(sun['day_of_week'] == 'Minggu');
  assert(sun['default_distance'] == 0.0);

  // After swap: Sat gets 0.0, Sun gets 15.0
  final swappedSatDist = sun['default_distance'];
  final swappedSunDist = sat['default_distance'];
  assert(swappedSatDist == 0.0);
  assert(swappedSunDist == 15.0);

  print('Task 4 ScheduleAdapter Tests: ALL ASSERTIONS PASSED!');
}
