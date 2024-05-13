import com.github.gradle.node.yarn.task.YarnTask
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import org.jetbrains.kotlin.de.undercouch.gradle.tasks.download.Download
import java.io.ByteArrayOutputStream
import org.apache.commons.lang.SystemUtils.*
import java.time.Instant

buildscript {
    repositories {
        mavenLocal()
        gradlePluginPortal()
        arrayOf("releases", "public").forEach { r ->
            maven {
                url = uri("${project.property("nexusBaseUrl")}/repositories/${r}")
                credentials {
                    username = project.property("nexusUserName").toString()
                    password = project.property("nexusPassword").toString()
                }
            }
        }
    }

    dependencies {
        classpath("com.xebialabs.gradle.plugins:gradle-commit:${properties["gradleCommitPluginVersion"]}")
        classpath("com.xebialabs.gradle.plugins:gradle-xl-defaults-plugin:${properties["xlDefaultsPluginVersion"]}")
        classpath("com.xebialabs.gradle.plugins:gradle-xl-plugins-plugin:${properties["xlPluginsPluginVersion"]}")
    }
}

plugins {
    kotlin("jvm") version "1.8.10"

    id("com.github.node-gradle.node") version "4.0.0"
    id("idea")
    id("nebula.release") version (properties["nebulaReleasePluginVersion"] as String)
    id("maven-publish")
}

apply(plugin = "ai.digital.gradle-commit")
apply(plugin = "com.xebialabs.dependency")

group = "ai.digital.release.helm"
project.defaultTasks = listOf("build")

val helmVersion = properties["helmVersion"]
val operatorSdkVersion = properties["operatorSdkVersion"]
val kustomizeVersion = properties["kustomizeVersion"]
val operatorBundleChannels = properties["operatorBundleChannels"]
val kubeRbacProxyImage = properties["kubeRbacProxyImage"]?.toString()
val os = detectOs()
val arch = detectHostArch()
val currentTime = Instant.now().toString()
val dockerHubRepository = System.getenv()["DOCKER_HUB_REPOSITORY"] ?: "xebialabsunsupported"
val releasedVersion = System.getenv()["RELEASE_EXPLICIT"] ?: "24.3.0-${
    LocalDateTime.now().format(DateTimeFormatter.ofPattern("Mdd.Hmm"))
}"
project.extra.set("releasedVersion", releasedVersion)
val releasedAppVersion = System.getenv()["RELEASE_APP_EXPLICIT"] ?: releasedVersion
project.extra.set("releasedAppVersion", releasedAppVersion)

enum class Os {
    DARWIN {
        override fun toString(): String = "darwin"
    },
    LINUX {
        override fun toString(): String = "linux"
    },
    WINDOWS {
        override fun packaging(): String = "zip"
        override fun toString(): String = "windows"
    };
    open fun packaging(): String = "tar.gz"
    fun toStringCamelCase(): String = toString().replaceFirstChar { it.uppercaseChar() }
}

enum class Arch {
    AMD64 {
        override fun toString(): String = "amd64"
    },
    ARM64 {
        override fun toString(): String = "arm64"
    };

    fun toStringCamelCase(): String = toString().replaceFirstChar { it.uppercaseChar() }
}

allprojects {
    apply(plugin = "kotlin")

    repositories {
        mavenLocal()
        mavenCentral()
        arrayOf("releases", "public", "thirdparty").forEach { r ->
            maven {
                url = uri("${project.property("nexusBaseUrl")}/repositories/${r}")
                credentials {
                    username = project.property("nexusUserName").toString()
                    password = project.property("nexusPassword").toString()
                }
            }
        }
    }
}

idea {
    module {
        setDownloadJavadoc(true)
        setDownloadSources(true)
    }
}

dependencies {
    implementation(gradleApi())
    implementation(gradleKotlinDsl())

}

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
    withSourcesJar()
    withJavadocJar()
}

tasks.named<Test>("test") {
    useJUnitPlatform()
}


tasks {

    compileKotlin {
        kotlinOptions.jvmTarget = JavaVersion.VERSION_17.toString()
    }

    compileTestKotlin {
        kotlinOptions.jvmTarget = JavaVersion.VERSION_17.toString()
    }

    val operatorImageUrl = "docker.io/$dockerHubRepository/release-operator:$releasedVersion"
    val bundleImageUrl = "docker.io/$dockerHubRepository/release-operator-bundle:$releasedVersion"
    val buildXlrDir = layout.buildDirectory.dir("xlr")
    val buildXlrOperatorDir = layout.buildDirectory.dir("xlr/${project.name}")
    val operatorFolder = projectDir.resolve("operator")
    val helmDir = layout.buildDirectory.dir("helm").get()
    val helmCli = helmDir.dir("$os-$arch").file("helm")
    val operatorSdkDir = layout.buildDirectory.dir("operatorSdk").get()
    val operatorSdkCli = operatorSdkDir.file("operator-sdk")
    val kustomizeDir = layout.buildDirectory.dir("kustomize").get()
    val kustomizeCli = kustomizeDir.file("kustomize")

    register<Download>("installHelm") {
        group = "helm"
        src("https://get.helm.sh/helm-v$helmVersion-$os-$arch.tar.gz")
        dest(helmDir.file("helm.tar.gz").getAsFile())
        doLast {
            copy {
                from(tarTree(helmDir.file("helm.tar.gz")))
                into(helmDir)
                fileMode = 0b111101101
            }
        }
    }

    register<Download>("installOperatorSdk") {
        group = "operatorSdk"
        src("https://github.com/operator-framework/operator-sdk/releases/download/v$operatorSdkVersion/operator-sdk_${os}_$arch")
        dest(operatorSdkDir.dir("operator-sdk-tool").file("operator-sdk").getAsFile())
        doLast {
            copy {
                from(operatorSdkDir.dir("operator-sdk-tool").file("operator-sdk"))
                into(operatorSdkDir)
                fileMode = 0b111101101
            }
        }
    }

    register<Download>("installKustomize") {
        group = "kustomize"
        src("https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v$kustomizeVersion/kustomize_v5.0.1_${os}_$arch.tar.gz")
        dest(kustomizeDir.file("kustomize.tar.gz").getAsFile())
        doLast {
            copy {
                from(tarTree(kustomizeDir.file("kustomize.tar.gz")))
                into(kustomizeDir)
                fileMode = 0b111101101
            }
            copy {
                from(kustomizeDir)
                into(buildXlrDir.get().dir("bin"))
                fileMode = 0b111101101
            }
        }
    }

    register<Delete>("cleanHelmAndOperator") {
        group = "helm"
        delete(buildXlrDir)
    }

    register<Copy>("prepareHelmPackage") {
        group = "helm"
        dependsOn("dumpVersion", "installHelm", "cleanHelmAndOperator")
        from(layout.projectDirectory)
        exclude(
            layout.buildDirectory.get().asFile.name,
            "buildSrc/",
            "docs/",
            "documentation/",
            "gradle/",
            "integration-tests/",
            "operator/",
            "scripts/",
            "tests/",
            "*gradle*",
            ".*/",
            "*.iml",
            "*.sh"
        )
        into(buildXlrOperatorDir)
        doFirst {
            delete(buildXlrDir)
        }
    }

    register<Exec>("prepareHelmDeps") {
        group = "helm"
        dependsOn("prepareHelmPackage")
        workingDir(buildXlrOperatorDir)
        commandLine(helmCli, "dependency", "update", ".")

        doLast {
            exec {
                workingDir(buildXlrOperatorDir)
                commandLine("rm", "-f", "Chart.lock")
            }
        }
        doLast {
            logger.lifecycle("Prepare helm deps finished")
        }
    }

    register<Exec>("runHelmLint") {
        group = "helm-test"
        dependsOn("prepareHelmDeps")

        commandLine(helmCli, "lint", "-f", "tests/values/basic.yaml")

        doLast {
            logger.lifecycle("Finished running helm lint")
        }
    }

    register<Exec>("installHelmUnitTestPlugin") {
        group = "helm-test"
        dependsOn("prepareHelmDeps")

        commandLine(helmCli, "plugin", "list")

        doLast {
            val unitTestPluginExists = standardOutput.toString()
            if(!unitTestPluginExists.contains("unittest")) {
                commandLine(helmCli, "plugin", "install", "https://github.com/helm-unittest/helm-unittest")
                logger.lifecycle("Install helm unit test plugin finished")
            } else {
                logger.info("Plugin exists. Skipping helm unit test plugin installation")
            }
        }
    }

    register<Exec>("runHelmUnitTest") {
        group = "helm-test"
        dependsOn("installHelmUnitTestPlugin", "runHelmLint")

        commandLine(helmCli, "unittest", "--file=tests/unit/*_test.yaml", ".")

        doLast {
            logger.lifecycle("Finished running unit tests")
        }
    }

    register<Exec>("buildHelmPackage") {
        group = "helm"
        dependsOn("prepareHelmDeps")
        workingDir(buildXlrDir)
        commandLine(helmCli, "package", "--app-version=$releasedAppVersion", project.name)

        doLast {
            copy {
                from(buildXlrDir)
                include("*.tgz")
                into(buildXlrDir)
                rename("digitalai-release-.*.tgz", "xlr.tgz")
                duplicatesStrategy = DuplicatesStrategy.WARN
            }
            logger.lifecycle("Helm package finished created ${buildXlrDir}/xlr.tgz")
        }
    }

    register<Exec>("prepareOperatorImage") {
        group = "operator"
        dependsOn("buildHelmPackage", "installOperatorSdk")
        workingDir(buildXlrDir)
        commandLine(operatorSdkCli, "init", "--domain=digital.ai", "--plugins=helm")

        val targetFile = buildXlrDir.get().file("config/manager/manager.yaml")

        doLast {
            // config/manager/manager.yaml replace resource memory
            exec {
                workingDir(buildXlrDir)
                commandLine("sed", "-i.bak",
                    "-e", "s#memory: 128Mi#memory: 512Mi#g",
                    targetFile)
            }
            logger.lifecycle("Init operator image finished")
        }
    }

    register<Exec>("buildReadme") {
        group = "readme"
        workingDir(layout.projectDirectory)
        commandLine("readme-generator-for-helm", "--readme", "README.md", "--values", "values.yaml")

        doLast {
            logger.lifecycle("Update README.md finished")
        }
    }

    register<Exec>("buildOperatorApi") {
        group = "operator"
        dependsOn("prepareOperatorImage")
        workingDir(buildXlrDir)
        commandLine(operatorSdkCli, "create", "api", "--group=xlr", "--version=v1alpha1", "--helm-chart=xlr.tgz")

        doLast {
            logger.lifecycle("Create operator image finished")
        }
    }

    register<Exec>("buildOperatorImage") {
        group = "operator"
        dependsOn("installKustomize", "buildOperatorApi")
        workingDir(buildXlrDir)
        commandLine("make", "docker-build",
            "IMG=$operatorImageUrl", "OPERATOR_SDK=${operatorSdkCli.toString().replace(" ", "\\\\ ")}", "KUSTOMIZE=${kustomizeCli.toString().replace(" ", "\\\\ ")}")

        val sourceDockerFile = operatorFolder.resolve("Dockerfile")
        val targetDockerFile = buildXlrDir.get().dir("Dockerfile")

        val sourceWatchesFile = operatorFolder.resolve("watches.yaml")
        val targetWatchesFile = buildXlrDir.get().dir("watches.yaml")

        doFirst {
            // operator/Dockerfile -> Dockerfile
            exec {
                workingDir(buildXlrDir)
                commandLine("sed", "-i.bak",
                    "-e", "/^FROM.*/r $sourceDockerFile",
                    targetDockerFile)
            }
            // operator/Dockerfile replace VERSION
            exec {
                workingDir(buildXlrDir)
                commandLine("sed", "-i.bak",
                    "-e", "s#\${VERSION}#$releasedVersion#g",
                    targetDockerFile)
            }
            // operator/watches.yaml -> watches.yaml
            exec {
                workingDir(buildXlrDir)
                commandLine("sed", "-i.bak",
                    "-e", "/^#+kubebuilder:scaffold:watch.*/r $sourceWatchesFile",
                    targetWatchesFile)
            }
            // operator/licenses/* -> licenses
            copy {
                from(operatorFolder)
                include("licenses/*")
                into(buildXlrDir)
                duplicatesStrategy = DuplicatesStrategy.WARN
            }
        }
        doLast {
            if (!kubeRbacProxyImage.isNullOrBlank()) {
                exec {
                    workingDir(buildXlrDir.get().dir("config/default"))
                    commandLine(kustomizeCli, "edit", "set", "image", kubeRbacProxyImage)
                }
            }
            logger.lifecycle("Build operator image $operatorImageUrl finished")
        }
    }

    register<Exec>("publishOperatorToDockerHub") {
        group = "operator"
        dependsOn("installKustomize", "buildOperatorImage")
        workingDir(buildXlrDir)
        commandLine("make", "docker-push",
            "IMG=$operatorImageUrl", "OPERATOR_SDK=$operatorSdkCli", "KUSTOMIZE=$kustomizeCli")

        doLast {
            logger.lifecycle("Publish to DockerHub $operatorImageUrl finished")
        }
    }

    register<Exec>("buildOperatorBundle") {
        group = "operator-bundle"
        dependsOn("installKustomize", "buildOperatorApi")
        workingDir(buildXlrDir)
        commandLine("make", "bundle",
            "IMG=$operatorImageUrl", "BUNDLE_GEN_FLAGS=--overwrite --version=$releasedVersion --channels=$operatorBundleChannels --package=digitalai-release-operator --use-image-digests",
            "OPERATOR_SDK=$operatorSdkCli", "KUSTOMIZE=$kustomizeCli")

        val sourceDockerFile = operatorFolder.resolve("bundle.Dockerfile")
        val targetDockerFile = buildXlrDir.get().dir("bundle.Dockerfile")
        val sourceAnnotationsFile = operatorFolder.resolve("annotations.yaml")
        val targetAnnotationsFile = buildXlrDir.get().dir("bundle").dir("metadata").dir("annotations.yaml")

        doFirst {
            // config/**/*.yaml -> config
            copy {
                from(operatorFolder)
                include("config/**/*.yaml")
                into(buildXlrDir)
                duplicatesStrategy = DuplicatesStrategy.WARN
            }
            exec {
                workingDir(buildXlrDir.get().dir("config/samples"))
                commandLine(kustomizeCli, "edit", "add", "resource", "xlr_minimal.yaml")
            }
            exec {
                workingDir(buildXlrDir.get().dir("config/samples"))
                commandLine(kustomizeCli, "edit", "add", "resource", "xlr_placeholders.yaml")
            }
            exec {
                workingDir(buildXlrDir.get().dir("config/default"))
                commandLine(kustomizeCli, "edit", "remove", "resource", "../manager")
            }
            exec {
                workingDir(buildXlrDir.get().dir("config/default"))
                commandLine(kustomizeCli, "edit", "add", "resource", "../custom")
            }
            // config/manifests/bases/xlr.clusterserviceversion.yaml replace VERSION
            exec {
                workingDir(buildXlrDir)
                commandLine("sed", "-i.bak",
                    "-e", "s#\${VERSION}#$releasedVersion#g",
                    buildXlrDir.get().dir("config/manifests/bases/xlr.clusterserviceversion.yaml"))
            }
            // config/manifests/bases/xlr.clusterserviceversion.yaml replace APP_VERSION
            exec {
                workingDir(buildXlrDir)
                commandLine("sed", "-i.bak",
                    "-e", "s#\${APP_VERSION}#$releasedAppVersion#g",
                    buildXlrDir.get().dir("config/manifests/bases/xlr.clusterserviceversion.yaml"))
            }
            // config/custom/manager_config_patch.yaml replace APP_VERSION
            exec {
                workingDir(buildXlrDir)
                commandLine("sed", "-i.bak",
                    "-e", "s#\${APP_VERSION}#$releasedAppVersion#g",
                    buildXlrDir.get().dir("config/custom/manager_config_patch.yaml"))
            }
            // config/manifests/bases/xlr.clusterserviceversion.yaml replace CONTAINER_IMAGE
            exec {
                workingDir(buildXlrDir)
                commandLine("sed", "-i.bak",
                    "-e", "s#\${CONTAINER_IMAGE}#$operatorImageUrl#g",
                    buildXlrDir.get().dir("config/manifests/bases/xlr.clusterserviceversion.yaml"))
            }
            // config/manifests/bases/xlr.clusterserviceversion.yaml replace CURRENT_TIME
            exec {
                workingDir(buildXlrDir)
                commandLine("sed", "-i.bak",
                    "-e", "s#\${CURRENT_TIME}#$currentTime#g",
                    buildXlrDir.get().dir("config/manifests/bases/xlr.clusterserviceversion.yaml"))
            }
        }
        doLast {
            // bundle.Dockerfile -> bundle.Dockerfile
            exec {
                workingDir(buildXlrDir)
                commandLine("sed", "-i.bak",
                    "-e", "/^LABEL operators.operatorframework.io.test.config.*/r $sourceDockerFile",
                    targetDockerFile)
            }
            // annotations.yaml -> bundle/annotations.yaml
            exec {
                workingDir(buildXlrDir)
                commandLine("sed", "-i.bak",
                    "-e", "/^.*operators.operatorframework.io.test.config.v1.*/r $sourceAnnotationsFile",
                    targetAnnotationsFile)
            }
            // bundle/annotations.yaml remove empty lines
            exec {
                workingDir(buildXlrDir)
                commandLine("sed", "-i.bak",
                    "-e", "/^\$/d",
                    targetAnnotationsFile)
            }
            logger.lifecycle("Build operator bundle finished")
        }
    }

    register<Exec>("buildBundleImage") {
        group = "operator-bundle"
        dependsOn("installKustomize", "buildOperatorBundle")
        workingDir(buildXlrDir)
        commandLine("make", "bundle-build",
            "BUNDLE_IMG=$bundleImageUrl", "OPERATOR_SDK=$operatorSdkCli", "KUSTOMIZE=$kustomizeCli")

        doLast {
            logger.lifecycle("Build bundle image $bundleImageUrl finished")
        }
    }

    register<Exec>("publishBundleToDockerHub") {
        group = "operator-bundle"
        dependsOn("installKustomize", "buildBundleImage")
        workingDir(buildXlrDir)
        commandLine("make", "bundle-push",
            "BUNDLE_IMG=$bundleImageUrl", "OPERATOR_SDK=$operatorSdkCli", "KUSTOMIZE=$kustomizeCli")

        doLast {
            logger.lifecycle("Publish to DockerHub $bundleImageUrl finished")
        }
    }

    register("publishToDockerHub") {
        group = "operator"
        dependsOn("publishOperatorToDockerHub")
    }

    register("checkDependencyVersions") {
        // a placeholder to unify with release in jenkins-job
    }

    register("uploadArchives") {
        group = "upload"
        dependsOn("dumpVersion", "publish")
    }
    register("uploadArchivesMavenRepository") {
        group = "upload"
        dependsOn("dumpVersion","publishAllPublicationsToMavenRepository")
    }
    register("uploadArchivesToMavenLocal") {
        group = "upload"
        dependsOn("dumpVersion", "publishToMavenLocal")
    }

    register("dumpVersion") {
        group = "release"
        doLast {
            file(buildDir).mkdirs()
            file("$buildDir/version.dump").writeText("version=${releasedVersion}")
        }
    }

    register<NebulaRelease>("nebulaRelease") {
        group = "release"
        dependsOn(named("updateDocs"))
    }

    named<YarnTask>("yarn_install") {
        group = "doc"
        args.set(listOf("--mutex", "network"))
        workingDir.set(file("${rootDir}/documentation"))
    }

    register<YarnTask>("yarnRunStart") {
        group = "doc"
        dependsOn(named("yarn_install"))
        args.set(listOf("run", "start"))
        workingDir.set(file("${rootDir}/documentation"))
    }

    register<YarnTask>("yarnRunBuild") {
        group = "doc"
        dependsOn(named("yarn_install"))
        args.set(listOf("run", "build"))
        workingDir.set(file("${rootDir}/documentation"))
    }

    register<Delete>("docCleanUp") {
        group = "doc"
        delete(file("${rootDir}/docs"))
        delete(file("${rootDir}/documentation/build"))
        delete(file("${rootDir}/documentation/.docusaurus"))
        delete(file("${rootDir}/documentation/node_modules"))
    }

    register<Copy>("docBuild") {
        group = "doc"
        dependsOn(named("yarnRunBuild"), named("docCleanUp"))
        from(file("${rootDir}/documentation/build"))
        into(file("${rootDir}/docs"))
    }

    register<GenerateDocumentation>("updateDocs") {
        group = "doc"
        dependsOn(named("docBuild"))
    }
}

tasks.withType<AbstractPublishToMaven> {
    dependsOn("buildHelmPackage")
}

tasks.named("build") {
    dependsOn("buildOperatorImage")
}

publishing {
    publications {
        register("digitalai-release-helm", MavenPublication::class) {
            artifact("${buildDir}/xlr/xlr.tgz") {
                artifactId = "release-helm"
                version = releasedVersion
            }
        }
    }

    repositories {
        maven {
            url = uri("${project.property("nexusBaseUrl")}/repositories/releases")
            credentials {
                username = project.property("nexusUserName").toString()
                password = project.property("nexusPassword").toString()
            }
        }
    }
}

node {
    version.set("14.17.5")
    yarnVersion.set("1.22.11")
    download.set(true)
}

fun detectOs(): Os {

    val osDetectionMap = mapOf(
        Pair(Os.LINUX, IS_OS_LINUX),
        Pair(Os.WINDOWS, IS_OS_WINDOWS),
        Pair(Os.DARWIN, IS_OS_MAC_OSX),
    )

    return osDetectionMap
        .filter { it.value }
        .firstNotNullOfOrNull { it.key } ?: throw IllegalStateException("Unrecognized os")
}

fun detectHostArch(): Arch {

    val archDetectionMap = mapOf(
        Pair("x86_64", Arch.AMD64),
        Pair("x64", Arch.AMD64),
        Pair("amd64", Arch.AMD64),
        Pair("aarch64", Arch.ARM64),
        Pair("arm64", Arch.ARM64),
    )

    val arch: String = System.getProperty("os.arch")
    if (archDetectionMap.containsKey(arch)) {
        return archDetectionMap[arch]!!
    }
    throw IllegalStateException("Unrecognized architecture: $arch")
}
