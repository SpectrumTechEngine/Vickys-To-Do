// Builds the Android APK and copies it to the project folder as VickysLists.apk.
// Uses Android Studio's bundled Java and the default Android SDK location if none are set.
const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFileSync } = require("child_process");

const root = path.join(__dirname, "..");
const android = path.join(root, "android");
const env = { ...process.env };

// Gradle 8.14 runs on Java 17-24, and Android Studio's bundled Java is newer than that,
// so prefer a Java 21 or 17 that Android Studio downloaded into ~/.jdks.
if (!env.JAVA_HOME) {
  const jdks = path.join(os.homedir(), ".jdks");
  const downloaded = fs.existsSync(jdks)
    ? fs.readdirSync(jdks).filter((d) => /-(21|17)\./.test(d)).sort().reverse().map((d) => path.join(jdks, d))
    : [];
  const candidates = downloaded.concat(["C:\\Program Files\\Android\\Android Studio\\jbr"]);
  const jdk = candidates.find((p) => fs.existsSync(path.join(p, "bin", "java.exe")));
  if (jdk) env.JAVA_HOME = jdk;
}
console.log("Using Java: " + env.JAVA_HOME);
const localProps = path.join(android, "local.properties");
if (!fs.existsSync(localProps)) {
  const sdk = env.ANDROID_HOME || env.ANDROID_SDK_ROOT || path.join(os.homedir(), "AppData\\Local\\Android\\Sdk");
  fs.writeFileSync(localProps, "sdk.dir=" + sdk.replace(/\\/g, "\\\\") + "\n");
}

// Run gradlew relative to android/ so spaces in the folder path don't break the command.
const gradlew = process.platform === "win32" ? ".\\gradlew.bat" : "./gradlew";
execFileSync(gradlew, ["assembleDebug"], { cwd: android, env, stdio: "inherit", shell: process.platform === "win32" });

const apk = path.join(android, "app", "build", "outputs", "apk", "debug", "app-debug.apk");
fs.copyFileSync(apk, path.join(root, "VickysLists.apk"));
console.log("\nAPK ready: " + path.join(root, "VickysLists.apk"));
