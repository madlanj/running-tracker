import os

# 1. CONFIGURE ANDROID MANIFEST
manifest_path = "android/app/src/main/AndroidManifest.xml"
if os.path.exists(manifest_path):
    with open(manifest_path, "r", encoding="utf-8") as f:
        content = f.read()

    permissions = """
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
"""

    strava_intent = """
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="jakimtracker" android:host="strava-callback" />
            </intent-filter>
"""

    if "android.permission.POST_NOTIFICATIONS" not in content:
        content = content.replace("<application", permissions + "\n    <application")
    if "jakimtracker" not in content:
        content = content.replace("</activity>", strava_intent + "\n        </activity>")

    with open(manifest_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Successfully configured AndroidManifest.xml")


# 2. CONFIGURE CORE LIBRARY DESUGARING IN APP BUILD.GRADLE (Required by flutter_local_notifications)
gradle_path = "android/app/build.gradle"
gradle_kts_path = "android/app/build.gradle.kts"

if os.path.exists(gradle_path):
    with open(gradle_path, "r", encoding="utf-8") as f:
        gc = f.read()

    # Enable in compileOptions
    if "coreLibraryDesugaringEnabled" not in gc:
        if "compileOptions {" in gc:
            gc = gc.replace(
                "compileOptions {",
                "compileOptions {\n        coreLibraryDesugaringEnabled true",
            )
        else:
            gc = gc.replace(
                "android {",
                "android {\n    compileOptions {\n        coreLibraryDesugaringEnabled true\n    }",
            )

    # Add dependency
    if "desugar_jdk_libs" not in gc:
        gc += """
dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'
}
"""

    with open(gradle_path, "w", encoding="utf-8") as f:
        f.write(gc)
    print(f"Successfully configured Core Library Desugaring in {gradle_path}")

elif os.path.exists(gradle_kts_path):
    with open(gradle_kts_path, "r", encoding="utf-8") as f:
        gc = f.read()

    if "isCoreLibraryDesugaringEnabled" not in gc and "coreLibraryDesugaringEnabled" not in gc:
        if "compileOptions {" in gc:
            gc = gc.replace(
                "compileOptions {",
                "compileOptions {\n        isCoreLibraryDesugaringEnabled = true",
            )
        else:
            gc = gc.replace(
                "android {",
                "android {\n    compileOptions {\n        isCoreLibraryDesugaringEnabled = true\n    }",
            )

    if "desugar_jdk_libs" not in gc:
        gc += """
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
"""

    with open(gradle_kts_path, "w", encoding="utf-8") as f:
        f.write(gc)
    print(f"Successfully configured Core Library Desugaring in {gradle_kts_path}")
