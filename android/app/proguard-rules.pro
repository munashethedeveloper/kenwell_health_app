# ── Flutter ────────────────────────────────────────────────────────────────────
# Keep Flutter engine entry points and platform channels.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# ── Firebase / Google Play Services ───────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Firebase Firestore – keep all model/data classes so that reflection-based
# serialisation used by the Dart SDK does not strip required constructors or
# field accessors at runtime.
-keep class com.google.firebase.firestore.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# ── App domain / data models (Firestore serialisation) ────────────────────────
# Firestore's Flutter plugin converts documents via Map<String,dynamic>.  The
# Dart-generated code handles serialisation, so no Java-level keep rules are
# needed for model classes.  Keep the package anyway as a safety net.
-keep class com.kenwell.healthapp.** { *; }

# ── Kotlin & Coroutines ────────────────────────────────────────────────────────
-keep class kotlin.** { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# ── SQLite / Drift ─────────────────────────────────────────────────────────────
# Drift's native library bridges are loaded via JNI; keep the bindings.
-keep class com.tekartik.sqflite.** { *; }
-keep class io.github.davidmiguel.** { *; }

# ── Suppress common warnings ───────────────────────────────────────────────────
-dontwarn com.google.errorprone.**
-dontwarn javax.annotation.**
-dontwarn org.jetbrains.annotations.**