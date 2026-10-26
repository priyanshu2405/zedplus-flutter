#!/usr/bin/env bash
# Zed Plus prototype - one-time setup (macOS / Linux)
# Generates the native Android & iOS folders, sets the app name, fetches packages.
set -e
cd "$(dirname "$0")"

command -v flutter >/dev/null 2>&1 || { echo "Flutter not found. Install it from https://docs.flutter.dev/get-started/install"; exit 1; }

echo "==> Generating Android & iOS project files..."
flutter create . --org com.zedplus --project-name zed_plus_app --platforms android,ios

echo "==> Setting display name to 'Zed Plus'..."
MANIFEST=android/app/src/main/AndroidManifest.xml
PLIST=ios/Runner/Info.plist
if [ -f "$MANIFEST" ]; then
  sed -i.bak 's/android:label="[^"]*"/android:label="Zed Plus"/' "$MANIFEST" && rm -f "$MANIFEST.bak"
fi
if [ -f "$PLIST" ]; then
  perl -0pi -e 's#(<key>CFBundleDisplayName</key>\s*<string>)[^<]*(</string>)#${1}Zed Plus${2}#' "$PLIST"
fi

echo "==> Fetching packages..."
flutter pub get

echo ""
echo "Done. Connect a phone or start an emulator, then run:"
echo "    flutter run"
