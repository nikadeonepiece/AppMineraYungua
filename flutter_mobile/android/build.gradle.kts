allprojects {
    repositories {
        google()
        mavenCentral()
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

// Workaround para plugins Flutter antiguos que no declaran `namespace` (AGP 8+ lo exige).
subprojects {
    pluginManager.withPlugin("com.android.library") {
        val androidExt = extensions.findByName("android") ?: return@withPlugin

        val hasNamespace =
            runCatching {
                val current = androidExt.javaClass.getMethod("getNamespace").invoke(androidExt) as? String
                current != null && current.isNotBlank()
            }.getOrDefault(true)

        if (hasNamespace) return@withPlugin

        val manifestFile = file("src/main/AndroidManifest.xml")
        if (!manifestFile.exists()) return@withPlugin

        val manifestText = manifestFile.readText()
        val pkg =
            Regex("""package\s*=\s*"([^"]+)"""")
                .find(manifestText)
                ?.groupValues
                ?.getOrNull(1)
                ?.trim()
                ?.takeIf { it.isNotBlank() }
                ?: return@withPlugin

        runCatching {
            androidExt.javaClass.getMethod("setNamespace", String::class.java).invoke(androidExt, pkg)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
