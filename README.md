# Zed Plus — Field Operations App (Flutter prototype)

Clickable Android & iOS prototype of all **91 screens** from the Zed Plus XD/SVG design package, organised into the same 17 workflows as `APP_FLOW_GUIDE.txt`.

It is a **demo build**: no backend, no real GPS/camera/NFC. Everything is simulated in memory so it runs anywhere with zero extra packages. Restart the app to reset the demo.

---

## 1. Run it

**Requirements:** Flutter 3.24 or newer (`flutter --version`), plus Android Studio (for Android) and/or Xcode on a Mac (for iOS).

```bash
# macOS / Linux
./setup.sh
flutter run

# Windows (PowerShell)
powershell -ExecutionPolicy Bypass -File setup.ps1
flutter run
```

The setup script runs `flutter create .` to generate the `android/` and `ios/` folders (it never overwrites `lib/`), sets the app name to **Zed Plus**, and runs `flutter pub get`. You only need to run it once.

**Build files to share:**

```bash
flutter build apk --release          # Android: build/app/outputs/flutter-apk/app-release.apk
flutter build ios --release          # iOS: then archive in Xcode (needs an Apple developer account)
```

For an iPhone demo without TestFlight, open `ios/Runner.xcworkspace` in Xcode, select your team under *Signing & Capabilities*, plug in the phone and press Run.

---

## 2. Presenter shortcuts

- **Demo role switch** on the Sign in screen: *Guard • Alex* or *Supervisor • Priya*. Home, bottom nav and avatar adapt.
- **Screen index**: tap *Browse all 91 screens* on Welcome, or **long-press the Z+ logo** on any screen. Search by name or code (e.g. `M39`).
- **SOS** chip in the header → Panic alert. **Avatar** → Notifications (badge clears when opened).
- “Demo:” links on some screens trigger exception paths (outside geofence, scan failure, fall alert, reset tour/route).
- Any 4-digit PIN works.

---

## 3. Suggested 5-minute demo script

**Guard journey (sign in as Guard)**
1. Welcome → Sign in → **Guard home**.
2. Tap the shift card → Shift detail → *Confirm shift*.
3. Back home → **Clock in** → GPS locks on the map → *Verify photo* → *Capture* → *Confirm* → **Punch accepted** shows the real time → Active shift (live timer).
4. *Patrol tours* → *Continue perimeter tour* → *Scan next checkpoint* → *Confirm NFC scan* → Questions: “Gate secured? No” → **Report issue** → Incident report → Add evidence → Submit → Report submitted.
5. Start break (live break timer) → End break.
6. *GPS clock-out* → Confirm → Shift completed → Timesheet.
7. Hit **SOS**, press and hold 2 seconds → Panic active → Cancel with any PIN.

**Supervisor journey (go back to Sign in, switch to Supervisor)**
1. Supervisor home → *Start today’s route* → stop 3 → Route stop detail → *Navigate to site* → *I’ve arrived*.
2. Tick the inspection checklist → Client sign-off → **draw a signature** → *Save signature & depart* (route progress updates).
3. Home → Approvals inbox → open REQ-108 → *Approve* → it moves to Approval history.
4. Dispatch jobs → ALM-208 → Accept → live ETA map → Record arrival → Close-out → Dispatch chat (auto-reply).

---

## 4. Project structure

```
lib/
  main.dart                 App entry, theme, portrait lock
  routes.dart               All 91 routes + screen catalogue (matches the flow guide)
  core/
    theme.dart              Colour tokens & text styles taken from the SVGs
    demo_state.dart         In-memory demo state (clock-in, patrol, route, approvals, chat…)
  widgets/
    z_widgets.dart          Design system: scaffold/header/bottom nav, cards, fields, buttons
    visuals.dart            Custom painted map, signature pad, scanner, panic button, keypad
  screens/
    access.dart             M01–M06   Welcome, sign in, join, permissions, PIN, reset
    home_profile.dart       M07, M08, M87–M91
    schedule_briefing.dart  M22–M27, M50–M55
    attendance.dart         M09–M21   Clock-in/out, breaks, timesheets, exceptions, offline
    patrol_reports.dart     M37–M49   Patrol tours and reports
    ops_safety.dart         M56–M70   Dispatch, safety, messages, visitor/vehicle logs
    supervisor_route.dart   M28–M36   Supervisor route & inspection
    equipment_approvals.dart M71–M86  Equipment, requests, approvals
    directory.dart          Presenter screen index
assets/fonts/               DejaVu Sans (from the design package)
```

Every screen file has `// M##` comments matching the design codes, so a designer can map any screen back to its SVG.

---

## 5. Path to production

The prototype is designed to grow into the real app:

| Area | Prototype | Production plan |
|---|---|---|
| State | `DemoState` (ChangeNotifier) | Riverpod or Bloc + repository layer |
| Navigation | Named routes | `go_router` with role guards & deep links |
| Data | Hard-coded sample data | REST/GraphQL API, offline-first local DB (Drift/Isar) + sync queue |
| GPS & geofence | Simulated map | `geolocator` + background location, server-side geofence validation |
| Camera / evidence | Simulated | `camera` / `image_picker`, upload with time & GPS metadata |
| Checkpoints | Simulated | `nfc_manager`, `mobile_scanner` (QR) |
| Maps | Custom painter | Google Maps / Apple Maps SDK, hand-off via `url_launcher` |
| Push / panic | Simulated | FCM / APNs, high-priority alerts, Face ID via `local_auth` |

The demo says “illustrative map • sample data” and “demo control • no alert sent” wherever a real system would act, so nobody mistakes the prototype for live functionality.
