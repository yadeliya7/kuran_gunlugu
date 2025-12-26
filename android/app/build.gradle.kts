plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.kuran_gunlugu"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // <-- BURASI 17 OLMALI
        targetCompatibility = JavaVersion.VERSION_17  // <-- BURASI 17 OLMALI
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"  // <-- BURASI ZATEN 17 İDİ, AYNI KALSIN
    }
    
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.kuran_gunlugu"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Şimdilik debug imzasını kullanıyoruz (TestFlight için sorun olmaz)
            signingConfig = signingConfigs.getByName("debug")

            // 👇 İŞTE KOTLIN FORMATI BÖYLE OLMALI:
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.0") 
    // DİKKAT: Parantez ve çift tırnak kullanıyoruz
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.2.2")
}