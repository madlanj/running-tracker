# JAKIM 2027 Half Marathon Tracker Flutter App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a robust, offline-first Flutter Android application that delivers daily tailored workouts for Muhammad Adlan Jazuli's 197-day preparation towards the Jakarta International Marathon (JAKIM) 2027 Half Marathon, featuring 1-tap Strava sync, dynamic fasting & weekend schedule adaptation, visual strength exercise illustrations, and 1-tap AI Coach report export.

**Architecture:** Clean Architecture with Flutter (Domain, Data, and Presentation layers). An offline-first SQLite database holds the 197-day preloaded curriculum and local activity logs, while HTTP services handle Strava OAuth2 activity sync and local notifications handle custom daily reminders.

**Tech Stack:** Flutter / Dart, `sqflite`, `flutter_riverpod`, `flutter_local_notifications`, `http`, `share_plus`, `flutter_secure_storage`.

**Spec:** [`docs/superpowers/specs/2026-11-16-jakim-hm-tracker-design.md`](file:///Users/admin/Documents/adlan/jakim-hm/docs/superpowers/specs/2026-11-16-jakim-hm-tracker-design.md)

---

## Global Constraints

* Target platform: Android SDK 26+ (compatible up to Android 14+ / SDK 34).
* Language: Dart 3.x / Flutter 3.x.
* Offline capability: The entire 197-day schedule, strength exercise library with illustrations, and local logging must function with zero internet connectivity.
* Date range: Fixed from 2026-11-16 through 2027-05-31 (197 continuous days).
* Target race pace: Half Marathon Pace 7:00/km (Sub-2:30 finish target).
* Visual exercise assets: All 8 strength training exercises must include dedicated illustrations bundled in `assets/images/exercises/`.

---

## Review Focus

1. **Date Boundary & Timezone Drift:** All date comparisons must use local calendar dates (`YYYY-MM-DD` in WIB / UTC+7) without timezone shifts corrupting day indices.
2. **Offline Strava Resilience:** If the athlete taps "Sync dari Strava" while offline or token expired, app must fail gracefully and preserve manual logging inputs without data loss.
3. **Weekend Swap Integrity:** Swapping Saturday and Sunday workouts must strictly affect the targeted week and preserve previous completion logs if already checked.
4. **Fasting Toggle State Persistence:** Toggling Monday/Thursday fasting must persist state across app restarts and dynamically update displayed running volume and nutrition cues.
5. **Notification Permission on Android 13+:** Handlers must check `POST_NOTIFICATIONS` runtime permission and exact alarm policies without crashing.

---

## File Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── hr_zones.dart
│   ├── utils/
│   │   ├── date_formatter.dart
│   │   └── pace_calculator.dart
│   └── services/
│       ├── notification_service.dart
│       └── export_service.dart
├── data/
│   ├── datasources/
│   │   ├── database_helper.dart
│   │   ├── preloaded_schedule.dart
│   │   └── strava_api_client.dart
│   ├── models/
│   │   ├── training_day_model.dart
│   │   ├── user_log_model.dart
│   │   └── exercise_model.dart
│   └── repositories/
│       ├── training_repository_impl.dart
│       └── strava_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── training_day.dart
│   │   ├── user_log.dart
│   │   └── exercise.dart
│   └── repositories/
│       ├── training_repository.dart
│       └── strava_repository.dart
└── presentation/
    ├── providers/
    │   ├── today_mission_provider.dart
    │   ├── calendar_provider.dart
    │   ├── strava_provider.dart
    │   └── settings_provider.dart
    ├── screens/
    │   ├── home_dashboard_screen.dart
    │   ├── calendar_roadmap_screen.dart
    │   ├── exercise_library_screen.dart
    │   ├── coach_export_screen.dart
    │   └── settings_screen.dart
    └── widgets/
        ├── mission_card.dart
        ├── log_entry_bottom_sheet.dart
        ├── fasting_toggle_chip.dart
        └── exercise_card.dart
```

---

### Task 1: Project Scaffolding & Asset Preparation

**Files:**
- Create: `pubspec.yaml`
- Create: `assets/data/training_schedule.json`
- Create: `assets/images/exercises/bulgarian_split_squat.png`
- Create: `assets/images/exercises/calf_raises.png`
- Create: `assets/images/exercises/glute_bridge.png`
- Create: `assets/images/exercises/side_plank.png`
- Create: `assets/images/exercises/plank_taps.png`
- Create: `assets/images/exercises/bird_dog.png`
- Create: `assets/images/exercises/single_leg_rdl.png`
- Create: `assets/images/exercises/wall_sit.png`
- Create: `tool/generate_assets.py`

**Interfaces:**
- Produces: Base Flutter directory layout, asset declarations in `pubspec.yaml`, clean 197-day JSON dataset, and 8 visual exercise assets.

- [ ] **Step 1: Write asset generator script**
Create `tool/generate_assets.py` that generates the 197-day JSON schedule file and renders crisp visual illustrations for each of the 8 strength exercises.

- [ ] **Step 2: Run generator script to verify outputs**
Run: `python3 tool/generate_assets.py`
Expected: Generates `assets/data/training_schedule.json` (197 days) and all 8 `.png` exercise illustrations in `assets/images/exercises/`.

- [ ] **Step 3: Create `pubspec.yaml`**
Declare dependencies: `flutter`, `flutter_riverpod: ^2.5.1`, `sqflite: ^2.3.3`, `path: ^1.9.0`, `http: ^1.2.1`, `flutter_local_notifications: ^17.1.2`, `timezone: ^0.9.3`, `share_plus: ^9.0.0`, `flutter_secure_storage: ^9.2.1`, and asset paths.

- [ ] **Step 4: Commit**
```bash
git add pubspec.yaml assets/ tool/
git commit -m "feat: scaffold Flutter project layout and generate exercise assets"
```

---

### Task 2: Domain Entities & Preloaded Training Schedule Models

**Files:**
- Create: `lib/domain/entities/training_day.dart`
- Create: `lib/domain/entities/user_log.dart`
- Create: `lib/domain/entities/exercise.dart`
- Create: `lib/data/models/training_day_model.dart`
- Create: `lib/data/models/user_log_model.dart`
- Create: `test/data/models/training_day_model_test.dart`

**Interfaces:**
- Produces: `TrainingDay`, `UserLog`, and `Exercise` domain models with JSON deserialization and database mapping methods (`fromMap()`, `toMap()`, `fromJson()`).

- [ ] **Step 1: Write failing test for `TrainingDayModel`**
```dart
void main() {
  test('TrainingDayModel correctly parses JSON for day 1', () {
    final json = {'id': 1, 'date_iso': '2026-11-16', 'day_of_week': 'Senin', 'default_distance': 0.0};
    final model = TrainingDayModel.fromJson(json);
    expect(model.id, 1);
    expect(model.dateIso, '2026-11-16');
    expect(model.isFastingDefault, true);
  });
}
```

- [ ] **Step 2: Verify test fails**
Run: `dart test test/data/models/training_day_model_test.dart` (or verify compile structure).

- [ ] **Step 3: Implement domain entities and models**
Implement `TrainingDay`, `UserLog`, `Exercise`, `TrainingDayModel`, and `UserLogModel`.

- [ ] **Step 4: Verify test passes**
Run tests and confirm 100% schema parity with spec.

- [ ] **Step 5: Commit**
```bash
git add lib/domain/ lib/data/models/ test/data/models/
git commit -m "feat: add domain entities and data models"
```

---

### Task 3: Local Database Helper & Training Repository

**Files:**
- Create: `lib/data/datasources/database_helper.dart`
- Create: `lib/domain/repositories/training_repository.dart`
- Create: `lib/data/repositories/training_repository_impl.dart`
- Test: `test/data/repositories/training_repository_test.dart`

**Interfaces:**
- Consumes: `TrainingDayModel`, `UserLogModel`.
- Produces: `TrainingRepository` with:
  * `Future<void> initializeDatabase()`
  * `Future<TrainingDay?> getDayByDate(String dateIso)`
  * `Future<List<TrainingDay>> getAllDays()`
  * `Future<UserLog?> getLogByDate(String dateIso)`
  * `Future<void> saveUserLog(UserLog log)`
  * `Future<void> toggleFasting(String dateIso, bool isFasting)`
  * `Future<void> swapWeekendDays(int weekNumber)`

- [ ] **Step 1: Write failing unit test for database operations**
Write test covering database insertion, pre-population check (197 records), and log update.

- [ ] **Step 2: Run test to confirm failure**

- [ ] **Step 3: Implement `DatabaseHelper` and `TrainingRepositoryImpl`**
Create tables `training_days` and `user_logs`. Pre-load initial schedule from `assets/data/training_schedule.json` on first launch.

- [ ] **Step 4: Verify tests pass**

- [ ] **Step 5: Commit**
```bash
git add lib/data/datasources/ lib/domain/repositories/ lib/data/repositories/ test/
git commit -m "feat: implement SQLite database helper and training repository"
```

---

### Task 4: Dynamic Fasting & Weekend Schedule Swap Logic

**Files:**
- Create: `lib/core/utils/schedule_adapter.dart`
- Modify: `lib/data/repositories/training_repository_impl.dart`
- Test: `test/core/utils/schedule_adapter_test.dart`

**Interfaces:**
- Produces:
  * `TrainingDay adaptDayForFasting(TrainingDay originalDay, bool isFasting)`
  * `(TrainingDay, TrainingDay) swapSaturdaySunday(TrainingDay sat, TrainingDay sun)`

- [ ] **Step 1: Write failing test for fasting toggle and weekend swap**
Test: When `isFasting = false` on Monday, category changes from `Rest Day & Core (Puasa)` to `Easy Aerobic Run`, distance becomes `5.0 km`, and time slot switches to `05.15 - 06.00 WIB`.
Test: Swapping Saturday (16 km Long Run) with Sunday (Rest) properly swaps target distances and menus.

- [ ] **Step 2: Run test to verify failure**

- [ ] **Step 3: Implement `ScheduleAdapter`**
Write clean pure functional transformation methods.

- [ ] **Step 4: Verify test passes**

- [ ] **Step 5: Commit**
```bash
git add lib/core/utils/schedule_adapter.dart test/core/utils/schedule_adapter_test.dart
git commit -m "feat: implement dynamic fasting toggle and weekend swap logic"
```

---

### Task 5: Strava OAuth2 API Client & Sync Service

**Files:**
- Create: `lib/data/datasources/strava_api_client.dart`
- Create: `lib/domain/repositories/strava_repository.dart`
- Create: `lib/data/repositories/strava_repository_impl.dart`
- Test: `test/data/datasources/strava_api_client_test.dart`

**Interfaces:**
- Produces: `StravaRepository` with:
  * `Future<bool> isAuthenticated()`
  * `Future<void> authorizeWithStrava()`
  * `Future<StravaRunSummary?> fetchLatestRunForDate(DateTime date)`
  * `Future<void> disconnect()`

- [ ] **Step 1: Write failing test for Strava run parsing**
Test parsing JSON response from `/athlete/activities`: converts meters to km, calculates pace `min:sec/km`, extracts avg HR, and filters for `type == 'Run'`.

- [ ] **Step 2: Run test to verify failure**

- [ ] **Step 3: Implement `StravaApiClient` and `StravaRepositoryImpl`**
Include token refresh logic and graceful error handling when offline.

- [ ] **Step 4: Verify test passes**

- [ ] **Step 5: Commit**
```bash
git add lib/data/datasources/strava_api_client.dart lib/domain/repositories/strava_repository.dart lib/data/repositories/strava_repository_impl.dart test/
git commit -m "feat: implement Strava API client and activity synchronization"
```

---

### Task 6: Local Notification Service

**Files:**
- Create: `lib/core/services/notification_service.dart`
- Test: `test/core/services/notification_service_test.dart`

**Interfaces:**
- Produces: `NotificationService` with:
  * `Future<void> init()`
  * `Future<void> scheduleDailyReminder({required int hour, required int minute, required String title, required String body})`
  * `Future<void> cancelAll()`

- [ ] **Step 1: Write test for notification timing computation**
Verify conversion of Indonesian time (WIB / UTC+7) to next trigger instant.

- [ ] **Step 2: Implement `NotificationService`**
Use `flutter_local_notifications` with notification channel `jakim_daily_mission`.

- [ ] **Step 3: Verify notification configuration and permissions**

- [ ] **Step 4: Commit**
```bash
git add lib/core/services/notification_service.dart test/core/services/
git commit -m "feat: implement local notification service with custom time scheduling"
```

---

### Task 7: AI Coach Export Engine

**Files:**
- Create: `lib/core/services/export_service.dart`
- Test: `test/core/services/export_service_test.dart`

**Interfaces:**
- Produces: `ExportService` with:
  * `String generateCoachReportMarkdown({required List<TrainingDay> days, required Map<String, UserLog> logs, required String dateRangeLabel})`
  * `Future<void> shareToClipboardOrApp(String reportText)`

- [ ] **Step 1: Write failing test for Markdown report structure**
Test ensures report includes total completed vs planned distance, average pace comparison, fasting adherence, and athlete journal entries formatted specifically for Gemini AI prompting.

- [ ] **Step 2: Run test to verify failure**

- [ ] **Step 3: Implement `ExportService`**

- [ ] **Step 4: Verify test passes**

- [ ] **Step 5: Commit**
```bash
git add lib/core/services/export_service.dart test/core/services/export_service_test.dart
git commit -m "feat: implement AI Coach export report generator"
```

---

### Task 8: Home Screen ("Today's Mission") & Log Entry Sheet

**Files:**
- Create: `lib/presentation/providers/today_mission_provider.dart`
- Create: `lib/presentation/widgets/mission_card.dart`
- Create: `lib/presentation/widgets/fasting_toggle_chip.dart`
- Create: `lib/presentation/widgets/log_entry_bottom_sheet.dart`
- Create: `lib/presentation/screens/home_dashboard_screen.dart`

**Interfaces:**
- Consumes: `TrainingRepository`, `StravaRepository`.
- Produces: Main interactive screen rendering today's mission, fasting switch, Strava 1-tap sync button, and manual log drawer.

- [ ] **Step 1: Implement `TodayMissionProvider` with Riverpod**
Manages current day retrieval, fasting toggle mutation, and completion status.

- [ ] **Step 2: Implement `MissionCard` & `FastingToggleChip`**
Displays category badge, time, distance, target pace, and expandable workout details.

- [ ] **Step 3: Implement `LogEntryBottomSheet`**
Form for actual distance, moving time, pace, average heart rate, 1-5 effort rating, and athlete reflection notes.

- [ ] **Step 4: Assemble `HomeDashboardScreen`**

- [ ] **Step 5: Commit**
```bash
git add lib/presentation/providers/ lib/presentation/widgets/ lib/presentation/screens/home_dashboard_screen.dart
git commit -m "feat: build Home Dashboard and interactive workout logging UI"
```

---

### Task 9: Calendar Roadmap, Exercise Library & Settings Screens

**Files:**
- Create: `lib/presentation/screens/calendar_roadmap_screen.dart`
- Create: `lib/presentation/screens/exercise_library_screen.dart`
- Create: `lib/presentation/widgets/exercise_card.dart`
- Create: `lib/presentation/screens/coach_export_screen.dart`
- Create: `lib/presentation/screens/settings_screen.dart`
- Modify: `lib/main.dart`

**Interfaces:**
- Produces:
  * 28-Week Calendar with `Tukar Jadwal Sabtu ⇄ Minggu` button.
  * Exercise Library with visual illustrations (`assets/images/exercises/*.png`) for all 8 runner exercises.
  * Coach Export Screen with 1-tap copy/share button.
  * Settings Screen with custom notification time picker and Strava connection toggle.

- [ ] **Step 1: Implement `ExerciseLibraryScreen` & `ExerciseCard`**
Renders high-clarity illustrations, target muscles, form cues, and sets/reps for all 8 runner strength exercises.

- [ ] **Step 2: Implement `CalendarRoadmapScreen`**
Lists all 28 weeks, visual phase markers, and weekend schedule swap trigger.

- [ ] **Step 3: Implement `CoachExportScreen` & `SettingsScreen`**
Renders progress analytics and notification configuration.

- [ ] **Step 4: Update `main.dart` with bottom navigation**

- [ ] **Step 5: Commit**
```bash
git add lib/presentation/ lib/main.dart
git commit -m "feat: implement Roadmap, Visual Exercise Library, Export, and Settings screens"
```

---

### Task 10: End-to-End Verification & Documentation

**Files:**
- Create: `README.md`
- Test: Full integration test suite

- [ ] **Step 1: Run all unit and widget tests**
Run: `flutter test` (or `dart test`)
Expected: All tests pass.

- [ ] **Step 2: Verify assets and database integrity**
Verify that `assets/data/training_schedule.json` has 197 days and all 8 image files exist and load.

- [ ] **Step 3: Write comprehensive `README.md`**
Document installation, running on Android emulator / physical device, Strava API setup, and APK build commands.

- [ ] **Step 4: Final Commit**
```bash
git add README.md
git commit -m "docs: add comprehensive README and setup guide"
```
