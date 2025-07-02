# Flutter eklentileri için genel kurallar
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# flutter_sound_record eklentisi için özel kurallar
-keep class com.josephcrowell.flutter_sound_record.** { *; }
-keep class com.josephcrowell.flutter_sound_record.FlutterSoundRecordPlugin { *; }
-dontwarn com.josephcrowell.flutter_sound_record.**

# AndroidX ve diğer bağımlılıklar için
-keep class androidx.** { *; }
-dontwarn androidx.**

# Flutter motoru için gerekli
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Plugin registrants için
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-dontwarn io.flutter.plugins.GeneratedPluginRegistrant