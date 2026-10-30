import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: android/key.properties (not tracked) holds storeFile,
// storePassword, keyAlias and keyPassword (storeFile is relative to
// android/app, or absolute). Without it the release build falls back to the
// debug key so `flutter run --release` still works locally.
val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
val hasReleaseKey = keyPropertiesFile.exists()
if (hasReleaseKey) {
    keyPropertiesFile.inputStream().use { keyProperties.load(it) }
}

// Push (FCM): android/firebase.properties (not tracked) holds appId, apiKey,
// projectId and senderId of the Firebase Android app. Without it the app
// builds with no push (PushBridge.kt answers null) and notifies as before.
val firebaseProperties = Properties()
rootProject.file("firebase.properties").takeIf { it.exists() }?.inputStream()?.use {
    firebaseProperties.load(it)
}
fun firebase(key: String) = "\"${firebaseProperties.getProperty(key, "")}\""

android {
    namespace = "se.royan.pomelu"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications needs java.time on older API levels.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "se.royan.pomelu"
        minSdk = 29
        // Pinned, not flutter.targetSdkVersion: a Flutter upgrade must not move
        // the target (and its behavior changes) without a review. Play needs 35+.
        targetSdk = 36
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        buildConfigField("String", "FIREBASE_APP_ID", firebase("appId"))
        buildConfigField("String", "FIREBASE_API_KEY", firebase("apiKey"))
        buildConfigField("String", "FIREBASE_PROJECT_ID", firebase("projectId"))
        buildConfigField("String", "FIREBASE_SENDER_ID", firebase("senderId"))
    }

    buildFeatures {
        buildConfig = true
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                // `quiet`, not `warn`: Flutter runs Gradle with -q, which hides
                // warnings.
                logger.quiet(
                    "WARNING: android/key.properties not found. " +
                        "Signing the release build with the DEBUG key. " +
                        "Do not upload this build to a store.",
                )
                signingConfigs.getByName("debug")
            }
            // No rules of the app's own: the plugins ship theirs
            // (shared_preferences_android since 2.5.2 keeps its JNI types).
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"))
            // Native symbol table for readable crash reports in Play Console.
            ndk {
                debugSymbolLevel = "SYMBOL_TABLE"
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    // Push only: no Analytics, no google-services plugin (PushBridge.kt
    // starts Firebase from BuildConfig).
    implementation(platform("com.google.firebase:firebase-bom:35.1.0"))
    implementation("com.google.firebase:firebase-messaging")
}
