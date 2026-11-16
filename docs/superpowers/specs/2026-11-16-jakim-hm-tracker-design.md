# Design Specification: JAKIM 2027 Half Marathon Tracker & Coach (Flutter Android App)

**Date:** 2026-11-16  
**Athlete / User:** Muhammad Adlan Jazuli  
**Target Event:** Jakarta International Marathon (JAKIM) 2027 - Half Marathon (21.0975 km), June 2027  
**Target Pace:** Pace 7:00/km (Estimated finish: 2:27:41 — Sub-2:30)  
**Status:** Approved for Implementation Planning  

---

## 1. Executive Summary & Problem Statement

Muhammad Adlan Jazuli is preparing for the Jakarta International Marathon (JAKIM) 2027 in the Half Marathon category. A comprehensive 197-day training plan (running from November 16, 2026 to May 31, 2027) was formulated from his Strava activity history. 

To ensure high adherence, consistency, and minimal friction amidst a demanding 9-to-6 workday and religious commitments (Sunnah fasting on Mondays and Thursdays, and full-month fasting during Ramadan in February 2027), an Android mobile application built with Flutter is required.

### Key Objectives:
1. **Daily Mission Clarity:** Deliver daily actionable workout guidance (running, strength training, and nutrition) directly to the athlete's phone.
2. **Flexible & Adaptive Schedule:** Seamlessly handle variable Sunnah fasting days (dynamic toggle between Rest/Core and Easy Run) and weekend schedule conflicts (swap Saturday Long Run with Sunday Rest).
3. **Automated & Manual Logging:** 1-tap sync with Strava API to capture actual distance, moving time, average pace, and average heart rate, with full offline manual fallback.
4. **AI Coach Export Bridge:** Allow 1-tap export of weekly/monthly workout logs to share directly with the Gemini AI Coach for ongoing evaluation and plan adjustment.
5. **Customizable Notifications:** Allow the user to specify preferred reminder times to prepare for morning runs (05:15 WIB) or post-Tarawih night runs (20:45 WIB).

---

## 2. System Architecture & Tech Stack

The application follows an **Offline-First, Clean Architecture** pattern using Flutter.

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│   (Screens, Widgets, State Management with Riverpod)   │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                      Domain Layer                      │
│      (Entities, Use Cases, Training Schedule Logic)    │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                       Data Layer                       │
│  ┌──────────────────────┐    ┌──────────────────────┐  │
│  │ Local SQLite (sqflite│    │  Strava API Service  │  │
│  │   Preloaded 197 days │    │   (OAuth2 + HTTP)    │  │
│  └──────────────────────┘    └──────────────────────┘  │
│  ┌──────────────────────┐    ┌──────────────────────┐  │
│  │ Local Notifications  │    │   Export Service     │  │
│  │ (flutter_local_notif)│    │ (Share / Clipboard)  │  │
│  └──────────────────────┘    └──────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

### Component Breakdown:
* **Framework:** Flutter (Target: Android SDK 26+, optimized for Android 13/14+).
* **State Management:** `flutter_riverpod` for declarative, testable state.
* **Local Database:** `sqflite` (SQLite) + `path_provider` for persistent offline storage.
* **Strava API Client:** `http` with OAuth2 token persistence (`flutter_secure_storage`).
* **Local Notifications:** `flutter_local_notifications` + `timezone` for scheduled reminders without cloud dependency.
* **Export / Sharing:** `share_plus` to export progress logs as formatted Markdown text / JSON for Gemini AI.

---

## 3. Database Schema & Data Models

### 3.1 Table: `training_days` (Preloaded Catalog)
Pre-populated with all 197 days from 2026-11-16 to 2027-05-31.

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | INTEGER PRIMARY KEY | Day index (1 to 197) |
| `date_iso` | TEXT UNIQUE | ISO date string (`YYYY-MM-DD`) |
| `week_number` | INTEGER | Week number (1 to 28) |
| `day_of_week` | TEXT | Indonesian day name (`Senin`, `Selasa`, etc.) |
| `phase` | TEXT | Phase name (`Fase 1: Base Building`, `Fase 2: Ramadhan Maint.`, etc.) |
| `default_status` | TEXT | Default label (`Puasa Sunnah Senin`, `Normal`, `Puasa Ramadhan`, etc.) |
| `default_category`| TEXT | `Easy Run`, `Tempo Run`, `THE LONG RUN`, `Rest Day`, etc. |
| `default_distance`| REAL | Target distance in km (e.g. 6.0, 15.0, 0.0) |
| `default_pace` | TEXT | Target pace & HR range (e.g. `Pace 8:15 - 8:35 (Zone 2)`) |
| `default_time` | TEXT | Default schedule (e.g. `05.15 - 06.00 WIB` or `20.45 - 21.30 WIB`) |
| `run_menu` | TEXT | Detailed workout description (warmup, main set, cool down) |
| `alt_non_fasting_menu` | TEXT | Alternative running workout if user toggles "Not Fasting" on Mon/Thu |
| `strength_menu`| TEXT | Strength training exercises, sets, and reps |
| `nutrition_menu`| TEXT | Recommended nutrition, hydration, and sahur/iftar guidance |

### 3.2 Table: `user_logs` (User Daily Activity)

| Field | Type | Description |
| :--- | :--- | :--- |
| `date_iso` | TEXT PRIMARY KEY | ISO date string (`YYYY-MM-DD`), FK to `training_days` |
| `is_fasting` | INTEGER | 1 = Yes (Fasting), 0 = No (Not Fasting) |
| `is_completed` | INTEGER | 1 = Completed (Checked), 0 = Pending |
| `actual_distance`| REAL | Distance ran in km (from Strava or manual) |
| `actual_duration`| INTEGER | Moving time in seconds |
| `actual_pace` | TEXT | Calculated or synced pace (e.g. `7:05/km`) |
| `actual_avg_hr` | INTEGER | Average heart rate in bpm |
| `perceived_effort`| INTEGER | Rating 1 (Very Easy) to 5 (Exhausted / Maximum) |
| `notes` | TEXT | Athlete reflection / journal (e.g. "Kaki kanan agak kencang di km 4") |
| `strava_activity_id`| TEXT | Strava activity ID (if synced via API) |
| `swapped_with_date` | TEXT | Nullable; if Saturday/Sunday swapped |
| `updated_at` | TEXT | Timestamp of last edit |

### 3.3 Key-Value Settings (Shared Preferences / Secure Storage)
* `notification_time_normal`: Default `"20:30"` (preview for next day) or `"05:00"` (morning of).
* `notification_time_ramadhan`: Default `"20:15"` (post-Tarawih reminder).
* `strava_client_id`, `strava_client_secret`: Embedded or configured for Strava API.
* `strava_access_token`, `strava_refresh_token`, `strava_token_expires_at`: Managed by OAuth2 lifecycle.

---

## 4. Feature Specifications & User Experience

### 4.1 Home Screen ("Today's Mission")
1. **Header:** Current date, day of week, week number (`Minggu 01 / 28`), and training phase tag.
2. **Adaptive Fasting Switch:**
   * On Mondays and Thursdays, displays: `Hari ini Puasa Sunnah? [✓ Ya] / [  Tidak]`.
   * Toggling to `Tidak` automatically swaps the card view to an Easy Aerobic Run (5–6 km @ 05:15 WIB) with adjusted nutrition instructions.
3. **Mission Card:**
   * Category badge (with color coding: Green for Puasa, Blue for Long Run, Orange for Tempo, Gray for Rest).
   * Scheduled time, target distance, and target pace.
   * Expandable sections: Warmup, Main Set, Cool Down, Strength Training, and Daily Nutrition.
4. **Log Action Bar:**
   * **Button "Sync dari Strava":** Fetches today's latest run activity from Strava, auto-populates distance, duration, pace, and HR.
   * **Button "Catat Manual":** Opens bottom sheet for manual data entry.
   * Effort rating slider/chips (1 to 5) and freeform reflection notes.
   * Checkbox button: `Selesai Latihan` (turns card into green success state).

### 4.2 Calendar & 28-Week Roadmap Screen
1. **Week-by-Week Accordion / List:**
   * View all 28 weeks categorized by the 5 Training Phases.
   * Shows weekly total target distance vs weekly actual distance completed.
2. **Weekend Swap Feature:**
   * In any given week, a button `Tukar Jadwal Sabtu ⇄ Minggu` allows shifting the Saturday Long Run to Sunday if the athlete has family or work commitments on Saturday.
3. **Visual Status Badges:**
   * Checkmark (completed), Cross/Dash (missed/rest), Alert (pending).

### 4.3 Exercise Library Screen (Strength Training for Runners)
Interactive directory of the 8 runner-specific strength exercises:
1. Bulgarian Split Squat (Quadriceps & Pelvic Stability)
2. Single-Leg Calf Raises (Soleus & Achilles / Shin Splints Prevention)
3. Glute Bridge & Single-Leg Glute Bridge (Glute activation for 9-to-6 office posture)
4. Side Plank with Leg Raise (Gluteus Medius / ITBS Prevention)
5. Front Plank with Shoulder Taps (Anti-rotational core)
6. Bird-Dog (Cross-body sling & lower back support)
7. Single-Leg Romanian Deadlift (Hamstring durability & ankle stability)
8. Wall Sit (Isometric knee tendon conditioning)

Each item displays: Target muscles, Half Marathon benefits, step-by-step form cues, recommended sets/reps, and common mistakes to avoid.

### 4.4 AI Coach Export & Progress Analytics Screen
1. **Progress Dashboard:**
   * Overall adherence percentage (e.g. 92% of target workouts completed).
   * Total kilometers logged vs target.
   * Pace progression curve (trend from current 8:15 towards target 7:00).
2. **"Export Report for AI Coach" Action:**
   * Generates a clean Markdown-formatted summary covering:
     * Selected time range (Last 7 days, Last 30 days, or Full Phase).
     * Workouts completed, actual distance, actual pace vs target, average HR.
     * Athlete reflection notes and pain/fatigue markers.
   * Uses `Share.share()` or copy-to-clipboard so the athlete can paste it directly into Gemini AI for personalized coaching feedback and micro-adjustments.

### 4.5 Settings Screen
1. **Notification Preferences:**
   * Time Picker for Morning/Weekday Reminder.
   * Time Picker for Ramadan / Post-Tarawih Reminder.
   * Toggle: Enable/Disable preview notification the night before.
2. **Strava Integration:**
   * Connection status (`Terhubung sebagai: Muhammad Adlan` vs `Belum Terhubung`).
   * "Sambungkan Strava" button (opens OAuth2 in-app browser).
   * "Putuskan Koneksi" option.

---

## 5. Strava API Integration Details

* **Endpoint:** `GET https://www.strava.com/api/v3/athlete/activities`
* **OAuth2 Scope:** `read,activity:read_all`
* **Matching Logic:**
  1. Retrieve athlete's activities starting from `date_iso` 00:00:00 WIB to 23:59:59 WIB.
  2. Filter by `type == "Run"`.
  3. Extract:
     * `distance` (meters / 1000 = km)
     * `moving_time` (seconds)
     * `average_speed` (m/s -> convert to `min:sec/km`)
     * `average_heartrate` (bpm)
     * `max_heartrate` (bpm)
  4. Auto-save to `user_logs` table and mark `is_completed = 1`.
* **Token Refresh Lifecycle:** Check `strava_token_expires_at`. If expired, make `POST https://www.strava.com/oauth/token` with `grant_type=refresh_token` to maintain persistent connection.

---

## 6. Error Handling & Edge Cases

1. **No Internet during Strava Sync:** Gracefully show snackbar: *"Tidak dapat terhubung ke Strava. Anda tetap bisa mencatat latihan secara manual."*
2. **Fasting Toggle after Run Logged:** If user already logged an activity and then toggles fasting status, preserve the actual log while updating the display category.
3. **Android 13+ Notification Permissions:** Prompt user explicitly for `POST_NOTIFICATIONS` permission with clear rationale: *"Diperlukan agar aplikasi bisa mengingatkan menu latihan harian Anda."*
4. **Exact Alarms (Android 12+):** Use `SCHEDULE_EXACT_ALARM` with fallback to inexact window alarms to ensure battery optimization doesn't kill reminder notifications.

---

## 7. Verification & Testing Plan

1. **Unit Tests:**
   * Schedule logic: verify 197 days are accurately mapped to dates.
   * Fasting toggle logic: confirm Monday/Thursday swaps between Rest/Core and Easy Run correctly.
   * Weekend swap logic: confirm Saturday/Sunday swaps exchange targets without corrupting adjacent weeks.
   * Pace conversion utility: convert m/s to `mm:ss/km` string accurately.
2. **Integration Tests:**
   * Database CRUD operations: inserting, updating logs, querying weekly totals.
   * Mock Strava OAuth2 token refresh and activity parsing.
3. **Manual Validation:**
   * Verify notification firing at scheduled custom time.
   * Verify export output formatting by pasting into Gemini AI.
