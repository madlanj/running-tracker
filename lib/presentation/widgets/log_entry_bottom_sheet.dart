import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/user_log.dart';

class LogEntryBottomSheet extends StatefulWidget {
  final UserLog? initialLog;
  final Function({
    required double actualDistance,
    required String actualPace,
    required int actualAvgHr,
    required int effort,
    required String notes,
  }) onSave;

  const LogEntryBottomSheet({
    super.key,
    this.initialLog,
    required this.onSave,
  });

  @override
  State<LogEntryBottomSheet> createState() => _LogEntryBottomSheetState();
}

class _LogEntryBottomSheetState extends State<LogEntryBottomSheet> {
  late TextEditingController _distCtrl;
  late TextEditingController _paceCtrl;
  late TextEditingController _hrCtrl;
  late TextEditingController _notesCtrl;
  int _effort = 3;

  @override
  void initState() {
    super.initState();
    _distCtrl = TextEditingController(text: widget.initialLog?.actualDistance.toString() ?? '');
    _paceCtrl = TextEditingController(text: widget.initialLog?.actualPace ?? '');
    _hrCtrl = TextEditingController(text: (widget.initialLog?.actualAvgHr ?? 0) > 0 ? widget.initialLog!.actualAvgHr.toString() : '');
    _notesCtrl = TextEditingController(text: widget.initialLog?.notes ?? '');
    _effort = widget.initialLog?.perceivedEffort ?? 3;
  }

  @override
  void dispose() {
    _distCtrl.dispose();
    _paceCtrl.dispose();
    _hrCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Catat Hasil Latihan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _distCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Jarak Aktual (km)',
                      hintText: '6.02',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _paceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Pace Rata-rata',
                      hintText: '8:15',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hrCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Rata-rata Heart Rate (bpm)',
                hintText: '148',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Perasaan Lari / Rating Effort (1 = Santai, 5 = Habis-habisan):',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final rating = index + 1;
                final isSelected = _effort == rating;
                return ChoiceChip(
                  label: Text('$rating ⭐'),
                  selected: isSelected,
                  selectedColor: AppColors.energyOrange,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                  onSelected: (val) {
                    if (val) setState(() => _effort = rating);
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Catatan / Refleksi Pribadi',
                hintText: 'Contoh: Kaki kanan enteng, cuaca pagi sejuk, sepatu Asics Novablast 5 enak banget.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final dist = double.tryParse(_distCtrl.text) ?? 0.0;
                  final hr = int.tryParse(_hrCtrl.text) ?? 0;
                  widget.onSave(
                    actualDistance: dist,
                    actualPace: _paceCtrl.text.trim(),
                    actualAvgHr: hr,
                    effort: _effort,
                    notes: _notesCtrl.text.trim(),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Simpan Latihan Selesai', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
