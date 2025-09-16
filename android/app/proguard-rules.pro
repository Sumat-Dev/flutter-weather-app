# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Play Core
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.** { *; }
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.gms.** { *; }

# Flutter plugins
-keep class com.baseflow.geolocator.** { *; }
-keep class com.baseflow.permissionhandler.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep all classes that might be accessed via reflection
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <methods>;
}
-keep @androidx.annotation.Keep class * {*;}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <fields>;
}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <init>(...);
}
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep the MainActivity and Flutter related classes
-keep public class com.example.flutter_weather_app.MainActivity
-keep class io.flutter.app.FlutterApplication { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.** { *; }

# Keep the application class
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference

# For Google Fonts
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.gms.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }

# Keep - Workmanager
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.background.systemjob.SystemJobService
-keep class androidx.work.impl.WorkManagerInitializer
-keep class androidx.work.WorkManagerInitializer
-keep class androidx.work.WorkManager
-keep class androidx.work.impl.background.systemalarm.SystemAlarmService
-keep class androidx.work.impl.background.systemalarm.SystemAlarmDispatcher
-keep class androidx.work.impl.background.systemalarm.ConstraintProxyUpdateReceiver
-keep class androidx.work.impl.background.systemalarm.ConstraintProxy$*
-keepclassmembers class androidx.work.impl.background.systemalarm.ConstraintProxy { *; }
