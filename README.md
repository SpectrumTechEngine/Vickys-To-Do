# Vicky's To Do's & To Don'ts

A claymation-style notepad app for Android. Vicky keeps two lists: things to do and things to steer clear of. You sort them into categories, cross them off with a pen stroke, and get reminder notifications when something is due.

The whole app is one HTML file, `vickys-lists.html`, with its pictures and fonts built in. [Capacitor](https://capacitorjs.com) wraps it into an Android app.

## Install on a phone

Download `VickysLists.apk` from the [latest release](https://github.com/SpectrumTechEngine/Vickys-To-Do/releases/latest) and open it on the phone. Android asks you to allow installing apps from your browser or files app the first time. The first time you set a reminder, allow notifications.

## Working on it

You'll need Node.js and Android Studio installed.

```bash
npm install
npm run apk
```

`npm run apk` copies `vickys-lists.html` into the app, syncs Capacitor and builds `VickysLists.apk` in this folder. To try changes in a browser first, just open `vickys-lists.html`.

| Path | What it is |
| --- | --- |
| `vickys-lists.html` | The app: layout, styles, logic and embedded images |
| `VAdo.jpg`, `VAdont.jpg`, `VAmainheader.jpg` | Original artwork the embedded images were cut from |
| `android/` | The Capacitor Android project (icons, splash, permissions) |
| `scripts/make-android-art.ps1` | Regenerates the launcher icons and splash screens from `VAdo.jpg` |
| `scripts/build-apk.js` | Builds the APK, picking a Java version Gradle supports |

Lists are saved on the phone itself. Uninstalling the app, or clearing its storage, erases them.
