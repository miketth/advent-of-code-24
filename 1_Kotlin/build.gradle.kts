plugins {
    kotlin("jvm") version "2.0.20"
}

group = "industries.disappointment"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(kotlin("test"))
}

kotlin {
    jvmToolchain(21)
}
