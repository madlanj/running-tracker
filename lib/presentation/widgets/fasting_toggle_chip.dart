import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FastingToggleChip extends StatelessWidget {
  final bool isFasting;
  final ValueChanged<bool> onToggle;

  const FastingToggleChip({
    super.key,
    required this.isFasting,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isFasting ? AppColors.fastingGreenBg : AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFasting ? AppColors.fastingGreenBorder : AppColors.restGrayBorder,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFasting ? Icons.dark_mode : Icons.wb_sunny_outlined,
            size: 18,
            color: isFasting ? Colors.green.shade800 : Colors.orange.shade800,
          ),
          const SizedBox(width: 8),
          Text(
            'Hari ini Puasa Sunnah?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isFasting ? Colors.green.shade900 : Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          Switch.adaptive(
            value: isFasting,
            activeColor: AppColors.accentTeal,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
