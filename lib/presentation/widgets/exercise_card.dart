import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/exercise.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Illustration Image from assets
          Container(
            height: 180,
            width: double.infinity,
            color: AppColors.primaryDark,
            child: Image.asset(
              exercise.imageAssetPath,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => const Center(
                child: Icon(Icons.fitness_center, size: 50, color: Colors.white54),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.energyOrange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        exercise.dosage,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.energyOrange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '🎯 Target: ${exercise.targetMuscles}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_outlined, size: 16, color: AppColors.accentTeal),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          exercise.functionForHm,
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('📋 Form Cue / Cara Melakukan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                const SizedBox(height: 4),
                Text(exercise.formCues, style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.black87)),
                const SizedBox(height: 8),
                Text('⚠️ ${exercise.importantNotes}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
