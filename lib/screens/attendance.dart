import 'dart:async';

import 'package:flutter/material.dart';

import '../core/demo_state.dart';
import '../core/theme.dart';
import '../widgets/visuals.dart';
import '../widgets/z_widgets.dart';

/// Rebuilds every second (for live timers).
mixin TickerRebuild<T extends StatefulWidget> on State<T> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// M09 GPS clock-in
class GpsClockInScreen extends StatefulWidget {
  const GpsClockInScreen({super.key});

  @override
  State<GpsClockInScreen> createState() => _GpsClockInScreenState();
}

class _GpsClockInScreenState extends State<GpsClockInScreen> {
  bool locating = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => locating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Attendance',
      title: 'GPS clock-in',
      subtitle: 'Polo Park • West entrance',
      chip: locating ? const ZChip('Locating…', kind: ChipKind.info) : const ZChip('Inside geofence', kind: ChipKind.success),
      tab: NavTab.home,
      children: [
        const MapIllustration(inside: true),
        StatGrid([
          const Stat('07:00', 'Shift start'),
          Stat(locating ? '—' : '8 m', 'GPS accuracy'),
          Stat(locating ? '—' : '12 m', 'From centre'),
          Stat(hhmm(DateTime.now()), 'Device time'),
        ]),
        const Notice('Allowed window: 06:45–07:15. Selfie verification required.'),
        ActionStack(
          primary: locating ? 'Getting GPS fix…' : 'Verify photo & clock in',
          icon: Icons.photo_camera_front_outlined,
          onPrimary: locating ? null : () => go(context, '/m10'),
          links: [('Demo: simulate outside geofence', () => go(context, '/m16'))],
        ),
      ],
    );
  }
}

// M10 Photo verification
class PhotoVerificationScreen extends StatefulWidget {
  const PhotoVerificationScreen({super.key});

  @override
  State<PhotoVerificationScreen> createState() => _PhotoVerificationScreenState();
}

class _PhotoVerificationScreenState extends State<PhotoVerificationScreen> {
  bool captured = false;

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Attendance',
      title: 'Photo verification',
      subtitle: 'Confirm it’s you',
      tab: NavTab.home,
      children: [
        CameraMock(captured: captured),
        const ZCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Frame your face clearly', style: ZT.cardTitle),
            SizedBox(height: 8),
            Text('Use good lighting. Your verification photo is linked to the attendance record.', style: ZT.body),
          ]),
        ),
        const Notice('Your photo is attached to this punch for attendance verification.'),
        PrimaryButton(
          captured ? 'Confirm & clock in' : 'Capture photo',
          icon: captured ? Icons.check_rounded : Icons.camera_alt_outlined,
          onPressed: () {
            if (!captured) {
              setState(() => captured = true);
              return;
            }
            fakeSubmit(context, label: 'Recording punch…', then: () {
              DemoScope.read(context).clockIn();
              goReplace(context, '/m11');
            });
          },
        ),
      ],
    );
  }
}

// M11 Punch accepted
class PunchAcceptedScreen extends StatelessWidget {
  const PunchAcceptedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final at = state.clockInAt ?? DateTime.now();
    return ZScaffold(
      eyebrow: 'Attendance',
      title: 'Punch accepted',
      chip: const ZChip('GPS verified', kind: ChipKind.success),
      tab: NavTab.home,
      children: [
        SuccessPanel(title: 'Clocked in at ${hhmm(at)}'),
        const StatGrid([
          Stat('07:00–15:00', 'Scheduled shift'),
          Stat('Inside', 'Geofence result', color: ZC.successText),
          Stat('8 m', 'Accuracy'),
          Stat('Matched', 'Photo check', color: ZC.successText),
        ]),
        const Notice('Your shift is active. On-shift location sharing has started.'),
        PrimaryButton('Go to active shift', onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/m12', (r) => r.settings.name == '/m07' || r.isFirst)),
      ],
    );
  }
}

// M12 Active shift
class ActiveShiftScreen extends StatefulWidget {
  const ActiveShiftScreen({super.key});

  @override
  State<ActiveShiftScreen> createState() => _ActiveShiftScreenState();
}

class _ActiveShiftScreenState extends State<ActiveShiftScreen> with TickerRebuild {
  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final inAt = state.clockInAt;
    final elapsed = inAt == null ? Duration.zero : DateTime.now().difference(inAt);
    return ZScaffold(
      eyebrow: 'Attendance',
      title: 'Active shift',
      tab: NavTab.home,
      children: [
        HeroCard(
          label: 'Today’s shift',
          badge: ZChip(state.onBreak ? 'On break' : inAt == null ? 'Not clocked in' : 'On duty', kind: state.onBreak ? ChipKind.gold : ChipKind.success),
          title: 'Polo Park',
          subtitle: 'West entrance • static guarding',
          time: '07:00–15:00',
          footer: inAt == null ? 'Clock in to start your shift' : 'Clocked in ${hhmm(inAt)} • GPS verified • on shift ${mmss(elapsed)}',
        ),
        StatGrid([
          Stat('${state.checkpointsDone == 6 ? 1 : 2}', 'Tours due'),
          const Stat('3', 'Open tasks'),
        ]),
        WorkQueueCard(items: [
          ('Patrol tours', () => go(context, '/m37')),
          ('Tasks & checklists', () => go(context, '/m50')),
          ('Post orders & policies', () => go(context, '/m52')),
          ('Visitor log', () => go(context, '/m68')),
          ('Write a report', () => go(context, '/m44')),
        ]),
        GestureDetector(onTap: () => go(context, '/m54'), child: const Notice('Read the latest passdown before taking over the post.')),
        ActionStack(
          primary: state.onBreak ? 'Return to break' : 'Start break',
          icon: Icons.free_breakfast_outlined,
          onPrimary: () {
            if (!state.onBreak) DemoScope.read(context).startBreak();
            go(context, '/m15');
          },
          links: [
            ('GPS clock-out', () => go(context, '/m13')),
            ('My timesheet', () => go(context, '/m19')),
            ('Site check-in & check-out', () => go(context, '/m21')),
          ],
        ),
      ],
    );
  }
}

// M21 Site check-in & check-out
class SiteCheckInScreen extends StatefulWidget {
  const SiteCheckInScreen({super.key});

  @override
  State<SiteCheckInScreen> createState() => _SiteCheckInScreenState();
}

class _SiteCheckInScreenState extends State<SiteCheckInScreen> {
  String? checkedInAt;

  @override
  Widget build(BuildContext context) {
    final inside = checkedInAt != null;
    return ZScaffold(
      eyebrow: 'Attendance',
      title: 'Site check-in & check-out',
      subtitle: 'Warehouse • vehicle patrol visit',
      chip: ZChip(inside ? 'Checked in $checkedInAt' : 'Inside site boundary', kind: ChipKind.success),
      tab: NavTab.home,
      children: [
        const MapIllustration(inside: true),
        StatGrid([
          Stat(checkedInAt ?? '10:04', 'Arrival'),
          const Stat('12 min', 'Planned visit'),
          const Stat('9 m', 'GPS accuracy'),
        ]),
        PrimaryButton(inside ? 'Check out of site' : 'Check in to site', icon: inside ? Icons.logout_rounded : Icons.login_rounded, onPressed: () {
          fakeSubmit(context, label: 'Verifying location…', then: () {
            if (inside) {
              toast(context, 'Checked out • dwell time recorded');
              setState(() => checkedInAt = null);
            } else {
              setState(() => checkedInAt = hhmm(DateTime.now()));
              toast(context, 'Checked in to Warehouse');
            }
          });
        }),
      ],
    );
  }
}

// M16 Geofence punch blocked
class GeofenceBlockedScreen extends StatefulWidget {
  const GeofenceBlockedScreen({super.key});

  @override
  State<GeofenceBlockedScreen> createState() => _GeofenceBlockedScreenState();
}

class _GeofenceBlockedScreenState extends State<GeofenceBlockedScreen> {
  int attempts = 1;

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Attendance',
      title: 'Geofence punch blocked',
      subtitle: 'Polo Park • West entrance',
      chip: const ZChip('Outside • punch blocked', kind: ChipKind.danger),
      tab: NavTab.home,
      children: [
        const MapIllustration(inside: false),
        StatGrid([
          const Stat('86 m', 'Outside boundary', color: ZC.dangerText),
          const Stat('11 m', 'GPS accuracy'),
          Stat('$attempts', 'Attempts recorded'),
        ]),
        const Notice('Move inside the site boundary and retry. This attempt is recorded.', danger: true),
        ActionStack(
          primary: 'Retry GPS check',
          icon: Icons.refresh_rounded,
          onPrimary: () => fakeSubmit(context, label: 'Checking GPS…', then: () {
            setState(() => attempts++);
            if (attempts >= 3) {
              toast(context, 'Now inside geofence');
              goReplace(context, '/m09');
            } else {
              toast(context, 'Still outside the boundary (demo: retry once more)');
            }
          }),
          links: [('Punch exception request', () => go(context, '/m17'))],
        ),
      ],
    );
  }
}

// M17 Punch exception request
class PunchExceptionScreen extends StatelessWidget {
  const PunchExceptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Attendance',
      title: 'Punch exception request',
      tab: NavTab.home,
      children: [
        const FormCard(fields: [
          ZDropdown('Exception type', options: ['Outside site boundary', 'Device or GPS fault', 'Forgot to punch', 'Scan tag unreadable']),
          ZPickerField('Requested punch time', value: '07:02', kind: PickerKind.time),
          ZField('Reason', initial: 'Entrance closed; waiting at the approved alternate gate.', maxLines: 3),
          ZPickerField('Evidence', value: 'Attach entrance photo', icon: Icons.photo_camera_outlined, attachedName: 'Alternate-gate.jpg attached'),
        ]),
        const Notice('Your supervisor reviews the evidence. Original punch values are preserved.'),
        PrimaryButton('Submit for review', onPressed: () => fakeSubmit(context, then: () {
              toast(context, 'REQ-108 sent to Priya Shah for review');
              go(context, '/m81');
            })),
      ],
    );
  }
}

// M18 Offline sync queue
class OfflineSyncScreen extends StatefulWidget {
  const OfflineSyncScreen({super.key});

  @override
  State<OfflineSyncScreen> createState() => _OfflineSyncScreenState();
}

class _OfflineSyncScreenState extends State<OfflineSyncScreen> {
  bool synced = false;

  @override
  Widget build(BuildContext context) {
    Widget row(String t, String s) => ListRowCard(
          title: t,
          subtitle: synced ? 'Synced • ${hhmm(DateTime.now())}' : s,
          subtitleColor: synced ? ZC.successText : null,
          leading: StatusDot(color: synced ? ZC.successText : ZC.gold, icon: synced ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined),
          trailing: const SizedBox(),
        );
    return ZScaffold(
      eyebrow: 'Attendance',
      title: 'Offline sync queue',
      chip: synced ? const ZChip('Online • all records synced', kind: ChipKind.success) : const ZChip('Offline • 3 records queued'),
      tab: NavTab.home,
      children: [
        row('Clock-in • 06:58', 'GPS captured • awaiting sync'),
        row('North gate checkpoint', 'QR scan • 07:16'),
        row('Daily activity draft', 'Saved on this device'),
        const Notice('Records retain the captured device time and GPS fix. Pending until connection returns.'),
        PrimaryButton(synced ? 'All synced' : 'Retry sync', icon: Icons.sync_rounded, onPressed: synced
            ? null
            : () => fakeSubmit(context, label: 'Syncing 3 records…', ms: 1400, then: () => setState(() => synced = true))),
      ],
    );
  }
}

// M15 Break timer
class BreakTimerScreen extends StatefulWidget {
  const BreakTimerScreen({super.key});

  @override
  State<BreakTimerScreen> createState() => _BreakTimerScreenState();
}

class _BreakTimerScreenState extends State<BreakTimerScreen> with TickerRebuild {
  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final start = state.breakStartedAt ?? DateTime.now();
    final elapsed = DateTime.now().difference(start);
    final over = elapsed > const Duration(minutes: 30);
    return ZScaffold(
      eyebrow: 'Attendance',
      title: 'Break timer',
      tab: NavTab.home,
      children: [
        BigTimerCard(
          label: 'Unpaid meal break',
          value: mmss(elapsed),
          valueColor: over ? ZC.dangerText : ZC.goldLight,
          chip: const ZChip('Active shift', kind: ChipKind.success),
          caption: 'Elapsed break time • 30-minute allowance',
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: (elapsed.inSeconds / 1800).clamp(0.0, 1.0), minHeight: 8, backgroundColor: ZC.field, color: over ? ZC.dangerText : ZC.gold),
        ),
        StatGrid([
          Stat(hhmm(start), 'Started'),
          const Stat('30 min', 'Allowed'),
        ]),
        PrimaryButton('End break', icon: Icons.play_arrow_rounded, onPressed: () {
          DemoScope.read(context).endBreak();
          toast(context, 'Break ended • ${mmss(elapsed)} recorded');
          Navigator.of(context).maybePop();
        }),
      ],
    );
  }
}

// M13 GPS clock-out
class GpsClockOutScreen extends StatelessWidget {
  const GpsClockOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final inAt = state.clockInAt;
    final worked = inAt == null ? const Duration(hours: 8, minutes: 1) : DateTime.now().difference(inAt);
    return ZScaffold(
      eyebrow: 'Attendance',
      title: 'GPS clock-out',
      subtitle: 'Polo Park • West entrance',
      chip: const ZChip('Ready to clock out', kind: ChipKind.success),
      tab: NavTab.home,
      children: [
        const MapIllustration(inside: true),
        StatGrid([
          Stat(hhmm(DateTime.now()), 'Local time'),
          Stat(inAt == null ? '7h 31m' : hm(worked), 'Time on shift'),
          const Stat('30m', 'Unpaid break'),
          const Stat('8 m', 'GPS accuracy'),
        ]),
        const Notice('Passdown submitted. No open breaks. End-of-shift report complete.'),
        ActionStack(
          primary: 'Confirm clock-out',
          icon: Icons.logout_rounded,
          onPrimary: () => fakeSubmit(context, label: 'Recording punch…', then: () {
            DemoScope.read(context).clockOut();
            goReplace(context, '/m14');
          }),
          links: [('Write passdown first', () => go(context, '/m55'))],
        ),
      ],
    );
  }
}

// M14 Shift completed
class ShiftCompletedScreen extends StatelessWidget {
  const ShiftCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final inAt = state.clockInAt;
    final outAt = state.clockOutAt;
    final raw = (inAt != null && outAt != null) ? '${hhmm(inAt)}–${hhmm(outAt)}' : '06:58–14:59';
    return ZScaffold(
      eyebrow: 'Attendance',
      title: 'Shift completed',
      tab: NavTab.home,
      children: [
        const SuccessPanel(title: 'Your shift is complete'),
        StatGrid([
          Stat(raw, 'Raw punches'),
          const Stat('30 minutes', 'Unpaid break'),
          const Stat('7h 31m', 'Pending approval', color: ZC.goldLight),
        ]),
        const Notice('Location sharing has stopped. Approved hours appear in your timesheet.'),
        ActionStack(primary: 'View timesheet', onPrimary: () => go(context, '/m19'), links: [('Back to home', () => goTab(context, NavTab.home))]),
      ],
    );
  }
}

// M19 My timesheet
class MyTimesheetScreen extends StatelessWidget {
  const MyTimesheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Attendance',
      title: 'My timesheet',
      subtitle: '12–25 October • own records only',
      tab: NavTab.schedule,
      children: [
        const StatGrid([
          Stat('38h 30m', 'Approved hours'),
          Stat('7h 42m', 'Pending review', color: ZC.goldLight),
        ]),
        ListRowCard(title: 'Mon 12 • Polo Park', subtitle: 'Scheduled 8h • approved 7h 30m', onTap: () => go(context, '/m20')),
        ListRowCard(title: 'Sun 11 • Warehouse', subtitle: 'Scheduled 8h • pending 7h 42m', subtitleColor: ZC.goldLight, onTap: () => go(context, '/m20')),
        ListRowCard(title: 'Sat 10 • Office tower', subtitle: 'Scheduled 8h • approved 8h', onTap: () => go(context, '/m20')),
        PrimaryButton('View shift evidence', onPressed: () => go(context, '/m20')),
      ],
    );
  }
}

// M20 Timesheet detail
class TimesheetDetailScreen extends StatelessWidget {
  const TimesheetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Attendance',
      title: 'Timesheet detail',
      tab: NavTab.schedule,
      children: [
        const KeyValueCard([
          ('Scheduled', '07:00–15:00'),
          ('Raw punch', '06:58–14:59'),
          ('Unpaid break', '30 minutes'),
          ('Adjustment', '−1 minute • reviewed by Priya'),
          ('Approved payable', '7h 30m'),
        ]),
        const Notice('Original punches remain visible. Submit a correction if something looks wrong.'),
        PrimaryButton('Request correction', onPressed: () => go(context, '/m17')),
      ],
    );
  }
}
