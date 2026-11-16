import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/training_day.dart';
import '../../domain/entities/user_log.dart';

class MissionCard extends StatelessWidget {
  final TrainingDay day;
  final UserLog? log;
  final VoidCallback onLogTap;
  final VoidCallback onStravaSyncTap;

  const MissionCard({
    super.key,
    required this.day,
    this.log,
    required this.onLogTap,
    required this.onStravaSyncTap,
  });

  Color _getBadgeColor() {
    if (day.defaultCategory.contains('Puasa') || day.defaultCategory.contains('Ramadhan')) {
      return AppColors.fastingGreenBg;
    } else if (day.defaultCategory.contains('LONG RUN')) {
      return AppColors.longRunBlueBg;
    } else if (day.defaultCategory.contains('Tempo')) {
      return AppColors.tempoOrangeBg;
    }
    return AppColors.restGrayBg;
  }

  Color _getBorderColor() {
    if (day.defaultCategory.contains('Puasa') || day.defaultCategory.contains('Ramadhan')) {
      return AppColors.fastingGreenBorder;
    } else if (day.defaultCategory.contains('LONG RUN')) {
      return AppColors.longRunBlueBorder;
    } else if (day.defaultCategory.contains('Tempo')) {
      return AppColors.tempoOrangeBorder;
    }
    return AppColors.restGrayBorder;
  }

  @override
  Widget build(BuildContext context) {
    final isDone = log?.isCompleted ?? false;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDone ? Colors.green.shade400 : _getBorderColor(), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDone ? Colors.green.shade50 : _getBadgeColor(),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDone ? Icons.check_circle : Icons.directions_run,
                      color: isDone ? Colors.green.shade700 : AppColors.primaryNavy,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      day.defaultCategory.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.8,
                        color: isDone ? Colors.green.shade800 : AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
                Text(
                  day.defaultTime,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Target metrics row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TARGET JARAK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(
                            day.defaultDistance > 0 ? '${day.defaultDistance.toStringAsFixed(1)} km' : 'Rest Day',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primaryNavy),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TARGET PACE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(
                            day.defaultPace.isNotEmpty ? day.defaultPace : '-',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),

                // Run Menu
                const Text('🏃 MENU LARI HARI INI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryNavy)),
                const SizedBox(height: 4),
                Text(day.runMenu, style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87)),
                const SizedBox(height: 14),

                // Strength Menu
                const Text('💪 STRENGTH & MOBILITAS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.energyOrange)),
                const SizedBox(height: 4),
                Text(day.strengthMenu, style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87)),
                const SizedBox(height: 14),

                // Nutrition Menu
                const Text('🥗 PANDUAN NUTRISI & HIDRASI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.accentTeal)),
                const SizedBox(height: 4),
                Text(day.nutritionMenu, style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87)),

                if (isDone) ...[
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Selesai! Aktual: ${log?.actualDistance.toStringAsFixed(2)} km @ ${log?.actualPace} (${log?.actualAvgHr} bpm)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDone ? Colors.grey.shade700 : AppColors.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: onLogTap,
                        icon: Icon(isDone ? Icons.edit : Icons.check_circle_outline),
                        label: Text(isDone ? 'Edit Hasil Lari' : 'Catat Selesai'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.energyOrange,
                        side: const BorderSide(color: AppColors.energyOrange, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onStravaSyncTap,
                      icon: const Icon(Icons.sync),
                      label: const Text('Strava'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
