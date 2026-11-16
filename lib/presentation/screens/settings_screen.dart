import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../providers/today_mission_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  TimeOfDay _notificationTime = const TimeOfDay(hour: 5, minute: 0);
  bool _previewNightBefore = true;
  bool _stravaConnected = false;

  @override
  void initState() {
    super.initState();
    _checkStrava();
  }

  Future<void> _checkStrava() async {
    final strava = ref.read(stravaRepositoryProvider);
    final isAuth = await strava.isAuthenticated();
    setState(() => _stravaConnected = isAuth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        title: const Text('Pengaturan & Integrasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notification Section
          const Text('NOTIFIKASI PENGINGAT LATIHAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.alarm, color: AppColors.primaryNavy),
                  title: const Text('Jam Notifikasi Pagi (Hari Biasa)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('Diingatkan pukul ${_notificationTime.format(context)} WIB'),
                  trailing: TextButton(
                    child: const Text('Ubah'),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _notificationTime,
                      );
                      if (picked != null) {
                        setState(() => _notificationTime = picked);
                        await NotificationService().scheduleDailyReminder(
                          hour: picked.hour,
                          minute: picked.minute,
                          title: 'Waktunya Lari Pagi! 🏃',
                          body: 'Buka misi latihan JAKIM hari ini dan mulai pemanasan.',
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Notifikasi diatur ke ${picked.format(context)} WIB')),
                          );
                        }
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  activeColor: AppColors.accentTeal,
                  secondary: const Icon(Icons.nightlight_round, color: AppColors.primaryNavy),
                  title: const Text('Preview Menu Malam Sebelumnya', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Notifikasi jam 20.30 untuk persiapan pakaian & tidur awal'),
                  value: _previewNightBefore,
                  onChanged: (val) => setState(() => _previewNightBefore = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Strava Section
          const Text('KONEKSI STRAVA API', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.energyOrange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.directions_run, color: AppColors.energyOrange, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Strava Auto-Sync', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(
                              _stravaConnected ? '✅ Terhubung (Akun: Adlan)' : 'Belum terhubung',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _stravaConnected ? Colors.green.shade800 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sinkronisasi otomatis jarak, durasi, pace, dan detak jantung tanpa perlu ketik manual. Gratis & menggunakan Strava API v3.',
                    style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _stravaConnected ? Colors.red.shade700 : AppColors.energyOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final strava = ref.read(stravaRepositoryProvider);
                        if (_stravaConnected) {
                          await strava.disconnect();
                          setState(() => _stravaConnected = false);
                        } else {
                          await strava.authorizeWithStrava();
                          setState(() => _stravaConnected = true);
                        }
                      },
                      child: Text(_stravaConnected ? 'Putuskan Akun Strava' : 'Hubungkan ke Strava'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // App Info
          const Center(
            child: Text(
              'JAKIM 2027 Half Marathon Tracker v1.0.0\nMade for Muhammad Adlan Jazuli',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.black45, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
