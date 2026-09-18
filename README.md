# Wallora

A curated wallpaper browser built with Flutter, powered by the Pexels API. Browse a live feed of high-quality wallpapers, preview them full screen, and set them directly as your home or lock screen — or save to Photos on iOS.

<!-- Add a screenshot or two here once you have them:
<p align="center">
  <img src="docs/screenshot_grid.png" width="250" />
  <img src="docs/screenshot_full.png" width="250" />
</p>
-->

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- Infinite-scroll grid of curated wallpapers, fetched live from the Pexels API
- Full-screen preview before applying
- Set wallpaper directly on Android — Home screen, Lock screen, or Both
- iOS: saves to Photos (Apple provides no public API for setting wallpaper directly)
- Disk-cached thumbnails so scrolling back doesn't re-download images
- Graceful loading, empty, and error states with retry

## Tech stack

- **Flutter** / **Dart**
- **provider** for state management
- **http** for networking
- **cached_network_image** for image caching
- **flutter_dotenv** for API key management
- **wallpaper_manager_flutter** (Android wallpaper setting)
- **gal** (iOS Photos saving)

## Architecture

The app follows a layered structure — UI never talks to the network or the OS directly, only to the layer immediately below it:

```
Screens/Widgets  →  Provider (state)  →  Services  →  API / Device OS
```

```
lib/
  models/       Data classes (WallpaperModel)
  services/     Talks to the outside world (ApiService, WallpaperService)
  providers/    App state (WallpaperProvider, a ChangeNotifier)
  screens/      Full-page widgets (HomeScreen, FullScreenView)
  widgets/      Reusable UI pieces (grid item, loading/error views)
  utils/        Shared constants
  main.dart     Composition root — wires dependencies together
tool/
  smoke_test.dart   Standalone script to verify the API layer without Flutter
```

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and on your PATH
- A free API key from [pexels.com/api](https://www.pexels.com/api/)

### Setup

```bash
git clone https://github.com/<your-username>/wallora.git
cd wallora
flutter pub get
cp .env.example .env
```

Open `.env` and add your real key:

```
PEXELS_API_KEY=your_real_key_here
```

> `.env` is git-ignored — never commit your real key.

Run the app:

```bash
flutter run
```

## Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.SET_WALLPAPER"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app saves wallpapers to your Photos library so you can set them from Settings.</string>
```

## Building a release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

For Play Store submission, build an app bundle instead:

```bash
flutter build appbundle --release
```

See [Google's docs on signing](https://docs.flutter.dev/deployment/android#signing-the-app) for setting up a real release keystore before publishing.

## Roadmap / ideas

- [ ] Search and categories
- [ ] Favorites / local collections
- [ ] Unit tests for `ApiService` and `WallpaperProvider`
- [ ] Riverpod migration (optional — current architecture makes this a low-risk swap)

## Contributing

Issues and pull requests are welcome. Please keep new code within the existing layered structure (models → services → providers → UI) rather than calling services or the network directly from widgets.

## License

[MIT](LICENSE) — wallpaper images are provided by [Pexels](https://www.pexels.com) and used under their [license](https://www.pexels.com/license/).
