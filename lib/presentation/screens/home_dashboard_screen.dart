import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/today_mission_provider.dart';
import '../widgets/fasting_toggle_chip.dart';
import '../widgets/mission_card.dart';
import '../widgets/log_entry_bottom_sheet.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todayMissionProvider);
    final notifier = ref.read(todayMissionProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'JAKIM 2027 TRACKER',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Colors.white),
            ),
            Text(
              'Muhammad Adlan Jazuli • HM Sub-2:30',
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.85)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Colors.white),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.selectedDate,
                firstDate: DateTime(2026, 11, 16),
                lastDate: DateTime(2027, 5, 31),
              );
              if (picked != null) {
                notifier.loadMissionForDate(picked);
              }
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.rawDay == null
              ? const Center(child: Text('Data latihan tidak ditemukan.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date & Phase Header Banner
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.rawDay!.dayOfWeek}, ${state.rawDay!.dateIso}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryNavy.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${state.rawDay!.phase} • Minggu ${state.rawDay!.weekNumber.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                                ),
                              ),
                            ],
                          ),
                          // Fasting Toggle for Monday and Thursday
                          if (state.rawDay!.dayOfWeek == 'Senin' || state.rawDay!.dayOfWeek == 'Kamis')
                            FastingToggleChip(
                              isFasting: state.log?.isFasting ?? state.rawDay!.isPuasaDefault,
                              onToggle: (val) => notifier.toggleFasting(val),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (state.errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Today's Mission Card
                      MissionCard(
                        day: state.adaptedDay ?? state.rawDay!,
                        log: state.log,
                        onLogTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (ctx) => LogEntryBottomSheet(
                              initialLog: state.log,
                              onSave: ({
                                required actualDistance,
                                required actualPace,
                                required actualAvgHr,
                                required effort,
                                required notes,
                              }) {
                                notifier.saveManualLog(
                                  actualDistance: actualDistance,
                                  actualPace: actualPace,
                                  actualAvgHr: actualAvgHr,
                                  effort: effort,
                                  notes: notes,
                                );
                              },
                            ),
                          );
                        },
                        onStravaSyncTap: () => notifier.syncWithStrava(),
                      ),
                    ],
                  ),
                ),
    );
  }
}
