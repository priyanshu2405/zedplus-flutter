# Zed Plus prototype - one-time setup (Windows PowerShell)
# Usage:  right-click > Run with PowerShell   or   powershell -ExecutionPolicy Bypass -File setup.ps1
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Host "Flutter not found. Install it from https://docs.flutter.dev/get-started/install"
  exit 1
}

Write-Host "==> Generating Android & iOS project files..."
flutter create . --org com.zedplus --project-name zed_plus_app --platforms android,ios

Write-Host "==> Setting display name to 'Zed Plus'..."
$manifest = "android/app/src/main/AndroidManifest.xml"
if (Test-Path $manifest) {
  (Get-Content $manifest -Raw) -replace 'android:label="[^"]*"', 'android:label="Zed Plus"' | Set-Content $manifest -NoNewline
}
$plist = "ios/Runner/Info.plist"
if (Test-Path $plist) {
  (Get-Content $plist -Raw) -replace '(<key>CFBundleDisplayName</key>\s*<string>)[^<]*(</string>)', '${1}Zed Plus${2}' | Set-Content $plist -NoNewline
}

Write-Host "==> Fetching packages..."
flutter pub get

Write-Host ""
Write-Host "Done. Connect a phone or start an emulator, then run:  flutter run"
