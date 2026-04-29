plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

dependencies {
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))

    // Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // Core desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

android {
    namespace = "com.example.mepco_esafety_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.mepco_esafety_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true

        // ✔ ABI filters → Reduce APK size
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a")
        }
    }

    lint {
        checkReleaseBuilds = false
    }

    buildTypes {
        getByName("release") {
            // ✔ Enable shrinking + minification (reduces 10–20 MB)
            isMinifyEnabled = true
            isShrinkResources = true

            // Temporary debug signing (you can change later)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}


//plugins {
//    id("com.android.application")
//    id("kotlin-android")
//    id("dev.flutter.flutter-gradle-plugin")
//    id("com.google.gms.google-services")
//}
//
//dependencies {
//    // Import the Firebase BoM
//    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))
//
//    // Firebase dependencies (add what you need)
//    implementation("com.google.firebase:firebase-analytics")
//
//    // Add the core desugaring dependency
//    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.1.5")
//}
//
//android {
//    namespace = "com.example.mepco_esafety_app"
//    compileSdk = flutter.compileSdkVersion
//    ndkVersion = flutter.ndkVersion
//
//    compileOptions {
//        sourceCompatibility = JavaVersion.VERSION_11
//        targetCompatibility = JavaVersion.VERSION_11
//    }
//
//    buildFeatures {
//        // Make sure this block is for enabling specific features (not coreLibraryDesugaring)
//    }
//
//    kotlinOptions {
//        jvmTarget = JavaVersion.VERSION_11.toString()
//    }
//
//    defaultConfig {
//        applicationId = "com.example.mepco_esafety_app"
//        minSdk = flutter.minSdkVersion
//        targetSdk = flutter.targetSdkVersion
//        versionCode = flutter.versionCode
//        versionName = flutter.versionName
//        multiDexEnabled = true
//    }
//
//    lintOptions {
//        // Disable release checks
//        isCheckReleaseBuilds = false
//    }
//
//    buildTypes {
//        release {
//            signingConfig = signingConfigs.getByName("debug")
//        }
//    }
//
//    // Enable desugaring via the `android` block, not `buildFeatures`
//    compileOptions {
//        isCoreLibraryDesugaringEnabled = true
//    }
//}
//
//flutter {
//    source = "../.."
//}
