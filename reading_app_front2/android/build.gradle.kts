buildscript {
    repositories {
        // 🟢 الاعتماد على سيرفر هواوي كمرايا أساسية ومستقرة وتجنب السيرفر الصيني المعطل حالياً
        maven { url = uri("https://repo.huaweicloud.com/repository/maven/") }
        mavenCentral()
        google()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0") 
    }
}

allprojects {
    repositories {
        // 🟢 نفس الترتيب للمكتبات الخارجية
        maven { url = uri("https://repo.huaweicloud.com/repository/maven/") }
        mavenCentral()
        google()
    }
}

// 🟢 إجبار المكتبات الخارجية (مثل device_info_plus) على استخدام سيرفر هواوي المستقر
subprojects {
    buildscript {
        repositories {
            maven { url = uri("https://repo.huaweicloud.com/repository/maven/") }
            mavenCentral()
            google()
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}