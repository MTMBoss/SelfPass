import org.gradle.api.tasks.Copy
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Il Flutter Gradle Plugin DEVE essere applicato dopo i plugin Android e Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.selfpass"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // ✅ NECESSARIO
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.selfpass"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Task per copiare e rinominare l'APK
tasks.register<Copy>("copyAndRenameApk") {
    // Cartella di origine: dove Flutter genera l'APK
    from("$buildDir/outputs/flutter-apk")
    // Include il file predefinito "app-release.apk"
    include("app-release.apk")
    // Cartella di destinazione
    into("G:/Il mio Drive/app")
    doLast {
        val destDir = file("G:/Il mio Drive/app")
        val originalApk = File(destDir, "app-release.apk")
        if (originalApk.exists()) {
            // Usa la proprietà flutterProjectName definita in gradle.properties
            val projectName = (findProperty("flutterProjectName") as? String) ?: rootProject.name
            val newName = "${projectName}-release.apk"
            val newApk = File(destDir, newName)
            println("Rinomino ${originalApk.absolutePath} in ${newApk.absolutePath}")
            if (originalApk.renameTo(newApk)) {
                println("Rinomina eseguita con successo!")
            } else {
                println("Rinomina fallita!")
            }
        } else {
            println("File app-release.apk non trovato in ${destDir.absolutePath}")
        }
    }
}

// Collega il task di copia a tutti i task assemble che terminano con "Release"
tasks.matching { it.name.startsWith("assemble") && it.name.endsWith("Release") }.configureEach {
    finalizedBy("copyAndRenameApk")
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.2.0")
}
