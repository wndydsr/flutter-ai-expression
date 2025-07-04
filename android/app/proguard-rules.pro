# TensorFlow Lite (TFLite)
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# ML Kit
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.imagepicker.**

# Google Play Services Vision (optional)
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.android.gms.vision.**

# Avoid removing entry points for Flutter
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# General keep for models and delegates (optional safety)
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.**
