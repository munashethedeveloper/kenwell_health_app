plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("com.google.firebase.firebase-perf")
}

android {
    namespace = "com.kenwell.healthapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Release signing configuration.
    //
    // Required environment variables (set in CI / local keystore.properties):
    //   KEYSTORE_PATH   – absolute path to the .jks / .keystore file
    //   KEY_ALIAS       – alias of the signing key inside the keystore
    //   KEY_PASSWORD    – password for the signing key
    //   STORE_PASSWORD  – password for the keystore itself
    //
    // If the env vars are absent the release build falls back to debug signing
    // so that `flutter run --release` still works during development.
    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("KEYSTORE_PATH")
            val keyAlias = System.getenv("KEY_ALIAS")
            val keyPassword = System.getenv("KEY_PASSWORD")
            val storePassword = System.getenv("STORE_PASSWORD")

            if (keystorePath != null && keyAlias != null &&
                keyPassword != null && storePassword != null) {
                storeFile = file(keystorePath)
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
                this.storePassword = storePassword
            } else {
                // Fallback: use debug keystore when release credentials are
                // not available (local development, unsigned PR builds).
                storeFile = signingConfigs.getByName("debug").storeFile
                this.keyAlias = signingConfigs.getByName("debug").keyAlias
                this.keyPassword = signingConfigs.getByName("debug").keyPassword
                this.storePassword = signingConfigs.getByName("debug").storePassword
            }
        }
    }

    defaultConfig {
        applicationId = "com.kenwell.healthapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}