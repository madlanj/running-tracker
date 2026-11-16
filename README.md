# 🏃 JAKIM 2027 Half Marathon Training Tracker & AI Coach

Aplikasi mobile Android berbasis **Flutter** yang dirancang khusus untuk mendampingi **Muhammad Adlan Jazuli** dalam mempersiapkan diri menuju **Jakarta International Marathon (JAKIM) 2027 (Kategori Half Marathon - 21.0975 km)** di bulan Juni 2027, dengan target **Finish Strong Sub-2 Jam 30 Menit (Pace 7:00/km)**.

Aplikasi ini menggabungkan prinsip *sports science* pelari jarak jauh dengan rutinitas harian nyata: **jam kerja kantor 9–6, puasa sunnah Senin & Kamis, lari malam pasca-Tarawih saat Ramadhan 2027, dan integrasi gratis Strava API.**

---

## ✨ Fitur Utama

1. **📅 Kurikulum 197 Hari Preloaded (Offline-First):**
   * Berjalan dari **16 November 2026 s.d. 31 Mei 2027** (28 Minggu) tanpa terputus.
   * Terbagi ke dalam 5 fase periodisasi: *Base Building*, *Ramadhan Maintenance*, *Build & Threshold*, *Peak Volume (Simulasi 21.1 km)*, dan *Tapering*.
   * Menggunakan SQLite lokal (`sqflite`), bekerja 100% tanpa internet.

2. **⚡ Fleksibilitas Jadwal Dinamis (Adaptive Schedule):**
   * **Toggle Puasa Senin & Kamis:** Di hari Senin atau Kamis, cukup geser saklar `Hari ini Puasa? [Ya / Tidak]`. Jika **Tidak**, menu otomatis berubah dari *Rest Day/Core* menjadi *Easy Aerobic Run 5.0 km (05.15 WIB)*.
   * **Tukar Jadwal Weekend (Sabtu ⇄ Minggu):** Jika ada urusan keluarga di hari Sabtu, 1-klik tombol `Tukar Jadwal Sabtu ⇄ Minggu` akan memindahkan Long Run ke hari Minggu.

3. **🔗 Integrasi Strava API (100% Gratis):**
   * 1-tap sinkronisasi aktivitas lari harian via OAuth2 Strava API v3.
   * Menarik jarak aktual (km), waktu tempuh, pace rata-rata, dan rata-rata detak jantung (*Heart Rate*) secara otomatis.
   * Dilengkapi opsi *Catat Manual* jika lari tanpa smartwatch atau offline.

4. **💪 Kamus Strength Training Berilustrasi:**
   * Panduan lengkap 8 gerakan kekuatan esensial pelari jarak jauh lengkap dengan **gambar ilustrasi visual**:
     1. *Bulgarian Split Squat* (Kekuatan & Stabilitas Panggul 1 Kaki)
     2. *Single-Leg Calf Raises* (Vaksin Pencegah *Shin Splints* & Achilles)
     3. *Glute Bridge & Single-Leg* (Membangunkan Otot Pantat yang Mati Rasa Duduk Kantor)
     4. *Side Plank with Leg Raise* (Vaksin Pencegah Nyeri Lutut Samping / *ITBS*)
     5. *Front Plank with Shoulder Taps* (Anti-Rotasi Core & Postur Tegak)
     6. *Bird-Dog* (Sinkronisasi Silang Lengan & Kaki)
     7. *Single-Leg Romanian Deadlift* (Daya Tahan Hamstring & Keseimbangan Telapak Kaki)
     8. *Wall Sit* (Ketahanan Isometrik Tempurung Lutut di Aspal Jakarta)

5. **🤖 Jembatan Export Laporan ke Coach Gemini AI:**
   * 1-klik **"Salin Teks Laporan"** (Markdown).
   * Menghasilkan rekap statistik mingguan/bulanan (total km aktual vs target, rata-rata pace, avg HR, catatan keluhan) siap *paste* langsung ke percakapan Gemini AI untuk review dan evaluasi berkala.

6. **⏰ Notifikasi Lokal Kustom:**
   * Jam pengingat latihan pagi (default 05.00 WIB) atau pasca-Tarawih (default 20.15 WIB) dapat diatur bebas di menu Pengaturan.

---

## 📁 Struktur Kode Proyek

```
jakim-hm/
├── assets/
│   ├── data/
│   │   └── training_schedule.json          # Data master 197 hari lengkap
│   └── images/exercises/                   # 8 aset gambar ilustrasi latihan strength
├── docs/superpowers/
│   ├── specs/2026-11-16-jakim-hm-tracker-design.md
│   └── plans/2026-11-16-jakim-hm-flutter-app.md
├── lib/
│   ├── main.dart                           # Entry point & navigasi tab utama
│   ├── core/
│   │   ├── constants/app_colors.dart       # Palet warna tema JAKIM
│   │   ├── services/
│   │   │   ├── notification_service.dart   # Manajemen alarm notifikasi lokal
│   │   │   └── export_service.dart         # Generator laporan markdown ke Gemini AI
│   │   └── utils/schedule_adapter.dart     # Logika toggle puasa & weekend swap
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── database_helper.dart        # SQLite helper & prepopulation
│   │   │   └── strava_api_client.dart      # Client OAuth2 Strava API
│   │   ├── models/
│   │   │   ├── training_day_model.dart
│   │   │   └── user_log_model.dart
│   │   └── repositories/
│   │       ├── training_repository_impl.dart
│   │       └── strava_repository_impl.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── training_day.dart
│   │   │   ├── user_log.dart
│   │   │   └── exercise.dart
│   │   └── repositories/
│   │       ├── training_repository.dart
│   │       └── strava_repository.dart
│   └── presentation/
│       ├── providers/today_mission_provider.dart
│       ├── screens/
│       │   ├── home_dashboard_screen.dart    # Tab Hari Ini (Today's Mission)
│       │   ├── calendar_roadmap_screen.dart  # Tab Roadmap 28 Minggu
│       │   ├── exercise_library_screen.dart  # Tab Kamus Strength Training
│       │   ├── coach_export_screen.dart      # Tab Export Laporan ke AI
│       │   └── settings_screen.dart          # Tab Pengaturan & Strava
│       └── widgets/
│           ├── mission_card.dart
│           ├── fasting_toggle_chip.dart
│           ├── log_entry_bottom_sheet.dart
│           └── exercise_card.dart
└── pubspec.yaml
```

---

## 🚀 Panduan Menjalankan & Build Aplikasi

### 1. Prasyarat
* Pasang **Flutter SDK** (versi 3.10 atau lebih baru) dari [flutter.dev](https://flutter.dev).
* Android Studio / VS Code dengan ekstensi Flutter & Dart.

### 2. Menjalankan di Perangkat Android / Emulator
```bash
# 1. Unduh seluruh dependensi
flutter pub get

# 2. Jalankan aplikasi di HP Android atau emulator
flutter run
```

### 3. Build File APK Siap Pakai
Untuk memasang langsung aplikasi ke HP Android kamu:
```bash
flutter build apk --release
```
File APK akan berada di: `build/app/outputs/flutter-apk/app-release.apk`. Kamu tinggal kirim file ini ke HP kamu (via WhatsApp/Google Drive/kabel USB) dan install!

---

## 🔑 Pengaturan Strava API (Gratis)
1. Buka [strava.com/settings/api](https://www.strava.com/settings/api) di browser dan login dengan akun Strava kamu.
2. Buat aplikasi baru:
   * **Application Name:** JAKIM 2027 Tracker
   * **Category:** Personal / Training
   * **Authorization Callback Domain:** `localhost` atau custom scheme `jakimtracker`
3. Masukkan `Client ID` dan `Client Secret` ke halaman Pengaturan di aplikasi untuk menikmati 1-tap auto sync latihan lari kamu.
