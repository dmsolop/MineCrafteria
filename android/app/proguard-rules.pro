# ==== Facebook Ads SDK ====
-keep class com.facebook.** { *; }
-keep class com.facebook.infer.annotation.** { *; }
-dontwarn com.facebook.**

# ==== Annotations and general rules ====
-keepattributes *Annotation*

-keep class * {
    @com.facebook.infer.annotation.* *;
}

# ==== Google Play Core ====
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**

# ==== Flutter Split Install / Deferred Components ====
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }

# ==== Flutter ====
-dontwarn io.flutter.embedding.**

# ==== Google Mobile Ads ====
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# ==== Firebase ====
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ==== ADVERTISING AND FACTORIES  ====
-keep class io.flutter.plugins.googlemobileads.** { *; }
-keepclassmembers class io.flutter.plugins.googlemobileads.** { *; }
-keepnames class com.test.mods.CustomNativeAdFactory
-keepclassmembers class com.test.mods.CustomNativeAdFactory { *; }
-keep class com.test.mods.CustomNativeAdFactory { *; }
-keep class * implements io.flutter.plugins.googlemobileads.NativeAdFactory { *; }
-keep class io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry { *; }
-keep class com.cleveradssolutions.** { *; }
-dontwarn com.cleveradssolutions.**
