import os

manifest_path = "android/app/src/main/AndroidManifest.xml"
if not os.path.exists(manifest_path):
    print(f"Error: {manifest_path} not found")
    exit(1)

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

content = content.replace("<application", permissions + "\n    <application")
content = content.replace("</activity>", strava_intent + "\n        </activity>")

with open(manifest_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Successfully injected permissions and Strava intent filter into AndroidManifest.xml")
