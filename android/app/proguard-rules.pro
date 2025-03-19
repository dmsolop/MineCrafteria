# Keep all classes of Facebook Ads SDK
-keep class com.facebook.** { *; }
-keep class com.facebook.infer.annotation.** { *; }
-dontwarn com.facebook.**

# Exclude checking of certain annotations
-keepattributes *Annotation*

# Prevent R8 errors
-keep class * {
    @com.facebook.infer.annotation.* *;
}
# Keep Google Play Core classes
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**

# Prevent R8 from removing Deferred Components API
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Keep SplitInstallManager and related classes
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Ensure SplitCompatApplication is not removed
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }

# Flutter
-dontwarn io.flutter.embedding.**

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
