# --- GOOGLE PLAY CORE HATASI İÇİN (Yeni Eklenen) ---
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# --- BİLDİRİMLER İÇİN ---
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# --- TIMEZONE (SAAT DİLİMİ) VE ÇÖKME ÖNLEYİCİLER ---
-keep class com.timezone.** { *; }
-keep class org.threeten.bp.** { *; }
-keep class androidx.window.** { *; }

# --- FLUTTER TEMEL YAPILARI ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }