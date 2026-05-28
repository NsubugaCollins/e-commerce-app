# Android build fixes (Ubuntu)

## Error: `java-21-openjdk-amd64` does not provide `JAVA_COMPILER`

You have **Java 21 JRE** (runtime only) as default `java`, but **no JDK 21**. Gradle needs a full JDK.

You already have **JDK 17** installed. Use it:

```bash
# One-time Flutter setting
flutter config --jdk-dir=/usr/lib/jvm/java-17-openjdk-amd64

# Per terminal session (optional)
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

# Verify compiler exists
javac -version   # should show 17.x
```

`android/gradle.properties` already contains:

```properties
org.gradle.java.home=/usr/lib/jvm/java-17-openjdk-amd64
```

Then clean and run:

```bash
cd ~/campus_mall/campus_mall_mobile
flutter clean
flutter pub get
flutter run
```

**Alternative:** install JDK 21 instead of switching:

```bash
sudo apt install openjdk-21-jdk
sudo update-alternatives --config java
flutter config --jdk-dir=/usr/lib/jvm/java-21-openjdk-amd64
```

---

## Error: `adb: device '...' not found`

Phone disconnected during build. Reconnect USB, enable **USB debugging**, then:

```bash
adb devices
flutter devices
flutter run -d 104501939V005487
```

---

## Gradle / Kotlin warnings

Project uses Gradle 8.14+ and AGP 8.11.1. If warnings persist after `flutter clean`, upgrade wrapper:

```bash
cd android && ./gradlew wrapper --gradle-version=8.14
```

---

## Connect app to Render API on physical device

Profile → Settings → API URL:

```
https://cycle-jgso.onrender.com/api
```

Or use a release build (uses Render by default).
