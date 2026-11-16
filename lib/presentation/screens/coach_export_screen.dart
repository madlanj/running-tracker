import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/export_service.dart';
import '../providers/today_mission_provider.dart';

class CoachExportScreen extends ConsumerStatefulWidget {
  const CoachExportScreen({super.key});

  @override
  ConsumerState<CoachExportScreen> createState() => _CoachExportScreenState();
}

class _CoachExportScreenState extends ConsumerState<CoachExportScreen> {
  String _selectedPeriod = 'Semua (197 Hari)';
  bool _generating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        title: const Text('Export ke Coach Gemini AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informational Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentTeal.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.smart_toy_outlined, color: AppColors.accentTeal, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kirim Progres ke Coach',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Export ringkasan latihan kamu dan paste langsung ke Gemini AI untuk review performa berkala!',
                          style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('PILIH PERIODE LAPORAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['7 Hari Terakhir', 'Fase 1 (Base)', 'Fase 2 (Ramadhan)', 'Semua (197 Hari)'].map((p) {
                final isSel = _selectedPeriod == p;
                return ChoiceChip(
                  label: Text(p),
                  selected: isSel,
                  selectedColor: AppColors.accentTeal,
                  labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                  onSelected: (val) {
                    if (val) setState(() => _selectedPeriod = p);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Export Actions
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _generating
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.copy),
              label: const Text('Salin Teks Laporan (Copy to Clipboard)', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _generating ? null : () => _handleExport(copyOnly: true),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.energyOrange,
                side: const BorderSide(color: AppColors.energyOrange, width: 1.5),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.share),
              label: const Text('Bagikan via Aplikasi Lain (Share)', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _generating ? null : () => _handleExport(copyOnly: false),
            ),
            const SizedBox(height: 30),

            // Target Pace & Heart Rate reference table
            const Text('REFERENSI TARGET RACE JAKIM 2027', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Target Utama HM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Pace 7:00/km (Finish 2:27:41)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentTeal)),
                    ],
                  ),
                  Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Zone 2 (Aerobic Base)', style: TextStyle(fontSize: 12, color: Colors.black87)),
                      Text('137 - 153 bpm (Pace ~8:15)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Zone 4 (Threshold HM)', style: TextStyle(fontSize: 12, color: Colors.black87)),
                      Text('168 - 179 bpm (Pace ~6:50)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExport({required bool copyOnly}) async {
    setState(() => _generating = true);
    final repo = ref.read(trainingRepositoryProvider);
    final allDays = await repo.getAllDays();
    final allLogs = await repo.getAllLogs();

    final markdown = ExportService.generateCoachReportMarkdown(
      days: allDays,
      logs: allLogs,
      dateRangeLabel: _selectedPeriod,
    );

    setState(() => _generating = false);

    if (copyOnly) {
      await ExportService.copyToClipboard(markdown);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primaryNavy,
            content: Text('Teks laporan berhasil disalin! Silakan paste ke Gemini AI.'),
          ),
        );
      }
    } else {
      await ExportService.shareReport(markdown);
    }
  }
}
