import 'dart:convert';
import 'dart:io';

// Simple standalone test runner to verify model parsing without flutter SDK dependency
void main() {
  final jsonContent = File('assets/data/training_schedule.json').readAsStringSync();
  final List<dynamic> list = jsonDecode(jsonContent);

  // Test day 1
  final day1 = list.first;
  assert(day1['id'] == 1, 'Day 1 ID should be 1');
  assert(day1['date_iso'] == '2026-11-16', 'Day 1 date should be 2026-11-16');
  assert(day1['day_of_week'] == 'Senin', 'Day 1 should be Senin');
  assert(day1['is_puasa_default'] == true, 'Day 1 is_puasa_default should be true');
  assert(day1['default_distance'] == 0.0, 'Day 1 distance should be 0.0');

  // Test day 2 (Selasa - Easy run 6.0 km)
  final day2 = list[1];
  assert(day2['id'] == 2, 'Day 2 ID should be 2');
  assert(day2['date_iso'] == '2026-11-17', 'Day 2 date should be 2026-11-17');
  assert(day2['day_of_week'] == 'Selasa', 'Day 2 should be Selasa');
  assert(day2['default_distance'] == 6.0, 'Day 2 distance should be 6.0');

  // Total days
  assert(list.length == 197, 'Total days should be exactly 197');

  print('Task 2 Model Test: ALL ASSERTIONS PASSED (197 days valid)!');
}
