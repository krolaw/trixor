# trixor

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## TODOs
x High speed taps
x Pause on leave
x Settings
x Sounds
x High Scores
- In App purchases
x Full screen
x In Game Settings
x Tiles
x Licences (sounds)
x error display (grey)

## Screenshots

6.5" Display: iPhone 11 Pro Max (1242x2688)
5.5" Display: iPhone 8 Plus ()


flutter build apk --obfuscate --split-debug-info=$HOME/junk --target-platform android-arm64
flutter build appbundle --obfuscate --split-debug-info=$HOME/junk

xdg-open build/app/outputs/bundle/release


sudo /home/krolaw/Android/Sdk/platform-tools/adb -s 0A231JEC215299 install build/app/outputs/flutter-apk/app-release.apk