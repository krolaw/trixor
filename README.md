# Trixor

A Flutter based tile card puzzle game.

## Build Notes

### Google Play

https://flutter.dev/docs/deployment/android

1. flutter build appbundle --obfuscate --split-debug-info=../aabDebug
1. https://play.google.com/apps/publish
1. Click on App
1. Release -> Production -> Create Release
1. Upload bundle
1. Type in version
1. Type in changes
1. Click Save
1. Click Review

keyPass: myappkey

### App Store

https://flutter.dev/docs/deployment/ios

1. On command line: `flutter clean ; flutter build ios --obfuscate --split-debug-info=../aabDebug`
1. In Code Product > Scheme > Runner.
1. Product > Destination > Generic iOS Device.
1. Verify version
1. Product > Archive (wait)
1. Click Validate (and continue etc)
1. Click Distribute (and cont. etc)
1. Upload and wait for email
1. https://appstoreconnect.apple.com/
1. Click My Apps
1. Click + Version or Platform

### Bits

flutter build apk --obfuscate --split-debug-info=$HOME/junk --target-platform android-arm64
flutter build appbundle --obfuscate --split-debug-info=$HOME/junk

xdg-open build/app/outputs/bundle/release


sudo /home/krolaw/Android/Sdk/platform-tools/adb -s 0A231JEC215299 install build/app/outputs/flutter-apk/app-release.apk