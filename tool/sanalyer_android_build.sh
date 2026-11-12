#!/bin/bash
# sanalyer Android build: FCM flavor'ıyla AAB (Play) ve ABI başına APK (indir sayfası).
# Gerekenler docs/sanalyer-mobil.md "Android" bölümünde. Sürüm: SANALYER_VERSION, SANALYER_BUILD_NUMBER.
set -euo pipefail
cd "$(dirname "$0")/.."
export LANG=en_US.UTF-8
export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v anaconda | paste -sd: -)
export PATH=~/.local/share/flutter-stable-sanalyer/bin:~/.cargo/bin:$PATH
export JAVA_HOME=${JAVA_HOME_17:-/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home}
export ANDROID_HOME=${ANDROID_HOME:-/opt/homebrew/share/android-commandlinetools}
export ANDROID_SDK_ROOT=$ANDROID_HOME
CFG=~/.config/sanalyer/android
BN=${SANALYER_BUILD_NUMBER:-$(date +%y%m%d)01}; VN=${SANALYER_VERSION:-1.0.0}

cp "$CFG/key.properties" android/key.properties
cp "$CFG/google-services.json" android/app/google-services.json
flutter config --android-sdk "$ANDROID_HOME" --enable-native-assets >/dev/null
dart tool/configure_build.dart --profile=android-fcm
FIREBASE_OPTIONS_JSON="$(python3 tool/sanalyer_firebase_options.py)" dart tool/write_firebase_options.dart --environment=stable
bash tool/apply_macos_pub_overrides.sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
DEFS=(--release --flavor stableFcm --build-name "$VN" --build-number "$BN"
  --dart-define-from-file=tool/dart_defines/stable.json --dart-define=PUSH_PROVIDER=fcm
  --dart-define=BUILD_TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)")
flutter build appbundle "${DEFS[@]}"
flutter build apk --split-per-abi -P force-version-code-ignoring-abi=true "${DEFS[@]}"
# configure_build'in değiştirdiği dosyaları geri al
git checkout -- pubspec.yaml pubspec.lock linux macos windows
ls -la build/app/outputs/bundle/stableFcmRelease/*.aab build/app/outputs/flutter-apk/*.apk
