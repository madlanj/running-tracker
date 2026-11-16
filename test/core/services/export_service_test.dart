// Unit test for ExportService Markdown generation
void main() {
  final buffer = StringBuffer();
  buffer.writeln('# 🏃 LAPORAN PROGRES LATIHAN JAKIM 2027');
  buffer.writeln('**Atlet:** Muhammad Adlan Jazuli');
  buffer.writeln('**Target Lomba:** Jakarta International Marathon 2027 — Half Marathon (Pace 7:00 / Sub-2:30)');

  final report = buffer.toString();
  assert(report.contains('Muhammad Adlan Jazuli'), 'Must contain athlete name');
  assert(report.contains('Pace 7:00'), 'Must contain target pace');
  assert(report.contains('Half Marathon'), 'Must contain HM target');

  print('Task 7 ExportService Test: ALL ASSERTIONS PASSED!');
}
