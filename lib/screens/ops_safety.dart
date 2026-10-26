import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/demo_state.dart';
import '../core/theme.dart';
import '../widgets/visuals.dart';
import '../widgets/z_widgets.dart';
import 'attendance.dart' show TickerRebuild;

// M68 Visitor log
class VisitorLogScreen extends StatelessWidget {
  const VisitorLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    return ZScaffold(
      eyebrow: 'Site logs',
      title: 'Visitor log',
      chip: ZChip('${state.visitors.where((v) => v.subtitle.startsWith('Checked in')).length} on site now', kind: ChipKind.info),
      tab: NavTab.reports,
      children: [
        for (final v in state.visitors)
          ListRowCard(
            title: v.title,
            subtitle: v.subtitle,
            leading: StatusDot(color: v.subtitle.startsWith('Checked in') ? ZC.successText : ZC.muted2, icon: Icons.badge_outlined),
            onTap: () => toast(context, v.subtitle),
          ),
        ActionStack(
          primary: 'Register visitor',
          icon: Icons.person_add_alt_rounded,
          onPrimary: () => go(context, '/m69'),
          links: [('Vehicle log', () => go(context, '/m70'))],
        ),
      ],
    );
  }
}

// M69 Visitor check-in
class VisitorCheckInScreen extends StatefulWidget {
  const VisitorCheckInScreen({super.key});

  @override
  State<VisitorCheckInScreen> createState() => _VisitorCheckInScreenState();
}

class _VisitorCheckInScreenState extends State<VisitorCheckInScreen> {
  final name = TextEditingController(text: 'Sam Chen • Northside Supplies');
  String host = 'Facilities manager';

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Site logs',
      title: 'Visitor check-in',
      tab: NavTab.reports,
      children: [
        FormCard(fields: [
          ZField('Name / company', controller: name),
          ZDropdown('Host', options: const ['Facilities manager', 'Property office', 'Security office'], onChanged: (v) => host = v),
          const ZDropdown('Purpose', options: ['Scheduled delivery', 'Contractor work', 'Meeting', 'Inspection']),
          const ZPickerField('Photo / badge', value: 'Visitor photo • badge V-042', icon: Icons.photo_camera_front_outlined),
        ]),
        PrimaryButton('Check visitor in', icon: Icons.how_to_reg_rounded, onPressed: () => fakeSubmit(context, then: () {
              DemoScope.read(context).addVisitor(name.text.trim().isEmpty ? 'Visitor' : name.text.trim(), host.toLowerCase());
              toast(context, 'Visitor checked in • host notified');
              Navigator.of(context).maybePop();
            })),
      ],
    );
  }
}

// M70 Vehicle log
class VehicleLogScreen extends StatelessWidget {
  const VehicleLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Site logs',
      title: 'Vehicle log',
      tab: NavTab.reports,
      children: [
        FormCard(fields: [
          const ZField('Plate', initial: 'MB • DEMO-042'),
          const ZField('Make / colour', initial: 'Ford Transit • white'),
          const ZField('Driver', initial: 'Sam Chen'),
          ZField('Entry / purpose', initial: '${hhmm(DateTime.now())} • delivery'),
          const ZField('Departure', hint: 'Not yet recorded'),
        ]),
        ActionStack(
          primary: 'Record vehicle entry',
          icon: Icons.local_shipping_outlined,
          onPrimary: () => fakeSubmit(context, then: () => toast(context, 'Vehicle MB • DEMO-042 logged')),
          links: [('Visitor log', () => go(context, '/m68'))],
        ),
      ],
    );
  }
}

// M56 Dispatch jobs
class DispatchJobsScreen extends StatelessWidget {
  const DispatchJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Dispatch',
      title: 'Dispatch jobs',
      tab: NavTab.home,
      children: [
        ListRowCard(title: 'ALM-208 • Warehouse', subtitle: 'New • priority 1 • 15 min target', subtitleColor: ZC.dangerText, leading: const StatusDot(color: ZC.dangerText, icon: Icons.notifications_active_outlined), onTap: () => go(context, '/m57')),
        ListRowCard(title: 'JOB-192 • Retail plaza', subtitle: 'Completed • response 11 min', subtitleColor: ZC.successText, leading: const StatusDot(color: ZC.successText, icon: Icons.check_rounded), onTap: () => toast(context, 'JOB-192 closed • false alarm')),
        PrimaryButton('Open alarm assignment', onPressed: () => go(context, '/m57')),
      ],
    );
  }
}

// M57 Dispatch job detail
class DispatchJobDetailScreen extends StatefulWidget {
  const DispatchJobDetailScreen({super.key});

  @override
  State<DispatchJobDetailScreen> createState() => _DispatchJobDetailScreenState();
}

class _DispatchJobDetailScreenState extends State<DispatchJobDetailScreen> with TickerRebuild {
  final _opened = DateTime.now().subtract(const Duration(minutes: 3, seconds: 12));

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Dispatch',
      title: 'Dispatch job detail',
      chip: const ZChip('Priority 1 • alarm response', kind: ChipKind.danger),
      tab: NavTab.home,
      children: [
        KeyValueCard([
          const ('Ticket', 'ALM-208 • intrusion alarm'),
          const ('Site', 'Warehouse • South gate'),
          const ('Response target', '15 minutes from creation'),
          ('Elapsed', mmss(DateTime.now().difference(_opened))),
          const ('Instructions', 'Check perimeter; contact keyholder before entry'),
          const ('Caller', 'Monitoring centre'),
        ]),
        ActionStack(
          primary: 'Accept & go en route',
          icon: Icons.directions_car_filled_outlined,
          onPrimary: () => fakeSubmit(context, label: 'Notifying dispatch…', then: () => goReplace(context, '/m58')),
          links: [('Dispatch chat', () => go(context, '/m66'))],
        ),
      ],
    );
  }
}

// M58 Dispatch response
class DispatchResponseScreen extends StatefulWidget {
  const DispatchResponseScreen({super.key});

  @override
  State<DispatchResponseScreen> createState() => _DispatchResponseScreenState();
}

class _DispatchResponseScreenState extends State<DispatchResponseScreen> {
  double progress = 0.1;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() => progress = progress >= 0.95 ? 0.95 : progress + 0.03);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eta = (8 * (1 - progress)).ceil();
    return ZScaffold(
      eyebrow: 'Dispatch',
      title: 'Dispatch response',
      subtitle: 'Warehouse • South gate',
      chip: const ZChip('En route • 08:21'),
      tab: NavTab.home,
      children: [
        MapIllustration(mode: MapMode.route, progress: progress),
        StatGrid([
          Stat('$eta min', 'Live ETA'),
          const Stat('11 min', 'Predicted response'),
        ]),
        ActionStack(
          primary: 'Record arrival',
          icon: Icons.place_rounded,
          onPrimary: () => fakeSubmit(context, label: 'Verifying GPS arrival…', then: () => goReplace(context, '/m59')),
          links: [('Dispatch chat', () => go(context, '/m66'))],
        ),
      ],
    );
  }
}

// M59 Alarm close-out report
class AlarmCloseOutScreen extends StatelessWidget {
  const AlarmCloseOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Dispatch',
      title: 'Alarm close-out report',
      tab: NavTab.home,
      children: [
        FormCard(fields: [
          ZField('Arrival', initial: '${hhmm(DateTime.now())} • GPS verified'),
          const ZDropdown('Finding', options: ['No intrusion found', 'Intrusion confirmed', 'Equipment fault']),
          const ZDropdown('Premises secured', options: ['Yes', 'No']),
          const ZField('Keyholder contacted', initial: 'Morgan Reid • 08:31'),
          const ZDropdown('Outcome', options: ['False alarm • premises secure', 'Police attended', 'Keyholder attended']),
          const ZPickerField('Evidence', value: 'Perimeter photos attached', icon: Icons.photo_camera_outlined),
        ]),
        PrimaryButton('Complete dispatch job', icon: Icons.task_alt_rounded, onPressed: () => fakeSubmit(context, then: () {
              toast(context, 'ALM-208 closed • dispatch notified');
              goFromHome(context, '/m56');
            })),
      ],
    );
  }
}

// M60 Safety centre
class SafetyCentreScreen extends StatelessWidget {
  const SafetyCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Safety',
      title: 'Safety centre',
      tab: NavTab.home,
      children: [
        ListRowCard(title: 'Lone-worker check-in', subtitle: 'Next check-in in 04:32', leading: const StatusDot(color: ZC.gold, icon: Icons.timer_outlined), onTap: () => go(context, '/m63')),
        ListRowCard(title: 'Emergency contacts', subtitle: 'Supervisor • dispatch • site keyholder', leading: const StatusDot(color: ZC.gold, icon: Icons.contact_phone_outlined), onTap: () => go(context, '/m67')),
        ListRowCard(title: 'Fall detection', subtitle: 'Enabled during active shift', leading: const StatusDot(color: ZC.successText, icon: Icons.personal_injury_outlined), onTap: () => go(context, '/m64')),
        ActionStack(
          primary: 'Open panic control',
          icon: Icons.sos_rounded,
          danger: true,
          onPrimary: () => go(context, '/m61'),
          links: [
            ('Demo: trigger fall alert', () => go(context, '/m64')),
          ],
        ),
      ],
    );
  }
}

// M61 Panic alert
class PanicAlertScreen extends StatelessWidget {
  const PanicAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Safety',
      title: 'Panic alert',
      subtitle: 'Emergency assistance',
      tab: NavTab.home,
      children: [
        Center(child: HoldButton(onComplete: () => goReplace(context, '/m62'))),
        const ZCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Get immediate assistance', style: ZT.cardTitle),
            SizedBox(height: 8),
            Text('Dispatch and your supervisor receive your live location.', style: ZT.body),
            SizedBox(height: 10),
            ZChip('Demo control • no alert sent', kind: ChipKind.danger),
          ]),
        ),
        const Notice('Press and hold for 2 seconds to send your name, site and live location to dispatch and your supervisor.'),
      ],
    );
  }
}

// M62 Panic active
class PanicActiveScreen extends StatefulWidget {
  const PanicActiveScreen({super.key});

  @override
  State<PanicActiveScreen> createState() => _PanicActiveScreenState();
}

class _PanicActiveScreenState extends State<PanicActiveScreen> with TickerRebuild {
  final _start = DateTime.now();

  Future<void> _cancel() async {
    final ok = await showDialog<bool>(context: context, builder: (_) => const _PinDialog());
    if (ok == true && mounted) {
      toast(context, 'Panic alert cancelled • dispatch informed');
      goTab(context, NavTab.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ZScaffold(
        eyebrow: 'Safety',
        title: 'Panic active',
        chip: const ZChip('Emergency alert active', kind: ChipKind.danger),
        tab: null,
        showNav: false,
        children: [
          const SuccessPanel(title: 'Dispatch has your\nlocation', icon: Icons.priority_high_rounded, color: ZC.dangerText),
          StatGrid([
            Stat(mmss(DateTime.now().difference(_start)), 'Alert active', color: ZC.dangerText),
            const Stat('Live', 'Location sharing'),
          ]),
          const Notice('Location continues sharing until cancelled. If safe, call dispatch. Cancel requires your PIN.', danger: true),
          ActionStack(
            primary: 'Cancel with PIN',
            icon: Icons.pin_outlined,
            onPrimary: _cancel,
            links: [('Call dispatch (demo)', () => toast(context, 'Demo: would call the 24/7 dispatch centre'))],
          ),
        ],
      ),
    );
  }
}

class _PinDialog extends StatefulWidget {
  const _PinDialog();

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  String pin = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ZC.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: ZC.surfaceBorder)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 14),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Enter PIN to cancel', style: ZT.cardTitle),
          const SizedBox(height: 14),
          PinDots(length: pin.length),
          const SizedBox(height: 12),
          Keypad(
            onDigit: (d) {
              if (pin.length >= 4) return;
              setState(() => pin += d);
              if (pin.length == 4) {
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (mounted) Navigator.pop(context, true);
                });
              }
            },
            onDelete: () => setState(() => pin = pin.isEmpty ? pin : pin.substring(0, pin.length - 1)),
          ),
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep alert active', style: TextStyle(color: ZC.muted2))),
        ]),
      ),
    );
  }
}

// M63 Lone-worker check-in
class LoneWorkerScreen extends StatefulWidget {
  const LoneWorkerScreen({super.key});

  @override
  State<LoneWorkerScreen> createState() => _LoneWorkerScreenState();
}

class _LoneWorkerScreenState extends State<LoneWorkerScreen> with TickerRebuild {
  DateTime _due = DateTime.now().add(const Duration(minutes: 4, seconds: 32));

  @override
  Widget build(BuildContext context) {
    var left = _due.difference(DateTime.now());
    if (left.isNegative) left = Duration.zero;
    return ZScaffold(
      eyebrow: 'Safety',
      title: 'Lone-worker check-in',
      tab: NavTab.home,
      children: [
        BigTimerCard(
          label: 'Your next check-in',
          value: mmss(left),
          chip: const ZChip('Active shift', kind: ChipKind.success),
          caption: 'Remaining before safety escalation',
        ),
        const Notice('A missed check-in escalates to your supervisor, then dispatch.'),
        PrimaryButton('I’m OK', icon: Icons.thumb_up_alt_outlined, onPressed: () {
          setState(() => _due = DateTime.now().add(const Duration(minutes: 30)));
          toast(context, 'Check-in recorded • next in 30 minutes');
        }),
      ],
    );
  }
}

// M64 Fall alert countdown
class FallAlertScreen extends StatefulWidget {
  const FallAlertScreen({super.key});

  @override
  State<FallAlertScreen> createState() => _FallAlertScreenState();
}

class _FallAlertScreenState extends State<FallAlertScreen> with TickerRebuild {
  final _due = DateTime.now().add(const Duration(seconds: 25));
  bool _escalated = false;

  @override
  Widget build(BuildContext context) {
    var left = _due.difference(DateTime.now());
    if (left.isNegative) left = Duration.zero;
    if (left == Duration.zero && !_escalated) {
      _escalated = true;
      HapticFeedback.heavyImpact();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) goReplace(context, '/m62');
      });
    }
    return ZScaffold(
      eyebrow: 'Safety',
      title: 'Fall alert countdown',
      tab: NavTab.home,
      children: [
        const SuccessPanel(title: 'A possible fall was\ndetected', icon: Icons.priority_high_rounded, color: ZC.dangerText),
        BigTimerCard(label: 'Time to escalation', value: mmss(left), valueColor: ZC.dangerText),
        const Notice('Confirm you are OK before the timer ends. Otherwise dispatch receives a location alert.', danger: true),
        PrimaryButton('I’m OK — dismiss alert', onPressed: () {
          _escalated = true;
          toast(context, 'Fall alert dismissed');
          Navigator.of(context).maybePop();
        }),
      ],
    );
  }
}

// M67 Emergency contacts
class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void call(String who) => toast(context, 'Demo: calling $who…');
    return ZScaffold(
      eyebrow: 'Communication',
      title: 'Emergency contacts',
      tab: NavTab.home,
      children: [
        ListRowCard(title: 'Dispatch centre', subtitle: '24/7 • contact available on site record', leading: const StatusDot(color: ZC.gold, icon: Icons.headset_mic_outlined), trailing: const Icon(Icons.call_rounded, color: ZC.gold), onTap: () => call('dispatch centre')),
        ListRowCard(title: 'Priya Shah', subtitle: 'Assigned supervisor', leading: const StatusDot(color: ZC.gold, icon: Icons.person_outline_rounded), trailing: const Icon(Icons.call_rounded, color: ZC.gold), onTap: () => call('Priya Shah')),
        ListRowCard(title: 'Morgan Reid', subtitle: 'Site keyholder', leading: const StatusDot(color: ZC.gold, icon: Icons.key_outlined), trailing: const Icon(Icons.call_rounded, color: ZC.gold), onTap: () => call('Morgan Reid')),
        ListRowCard(title: 'Emergency services', subtitle: 'Use the local emergency number', leading: const StatusDot(color: ZC.dangerText, icon: Icons.local_hospital_outlined), trailing: const Icon(Icons.call_rounded, color: ZC.dangerText), onTap: () => call('911')),
        PrimaryButton('View active site', onPressed: () => go(context, '/m90')),
      ],
    );
  }
}

// M65 Messages
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    return ZScaffold(
      eyebrow: 'Communication',
      title: 'Messages',
      tab: NavTab.home,
      children: [
        ListRowCard(title: 'Dispatch • 2 unread', subtitle: state.chat.last.text, leading: const StatusDot(color: ZC.gold, icon: Icons.headset_mic_outlined), onTap: () => go(context, '/m66')),
        ListRowCard(title: 'Polo Park team', subtitle: 'New entrance instructions posted.', leading: const StatusDot(color: ZC.muted2, icon: Icons.groups_outlined), onTap: () => go(context, '/m54')),
        ListRowCard(title: 'Priya Shah', subtitle: 'Your equipment request is approved.', leading: const StatusDot(color: ZC.muted2, icon: Icons.person_outline_rounded), onTap: () => go(context, '/m81')),
        ActionStack(
          primary: 'Open dispatch conversation',
          onPrimary: () => go(context, '/m66'),
          links: [('Create passdown', () => go(context, '/m55'))],
        ),
      ],
    );
  }
}

// M66 Dispatch chat
class DispatchChatScreen extends StatefulWidget {
  const DispatchChatScreen({super.key});

  @override
  State<DispatchChatScreen> createState() => _DispatchChatScreenState();
}

class _DispatchChatScreenState extends State<DispatchChatScreen> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _send() {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    DemoScope.read(context).sendChat(t);
    _c.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    return ZScaffold(
      eyebrow: 'Communication',
      title: 'Dispatch chat',
      tab: NavTab.home,
      footer: Row(children: [
        Expanded(
          child: TextField(
            controller: _c,
            style: const TextStyle(color: ZC.text, fontSize: 13),
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
            decoration: zInputDecoration(hint: 'Message dispatch'),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 46,
          width: 46,
          child: IconButton.filled(
            onPressed: _send,
            style: IconButton.styleFrom(backgroundColor: ZC.gold, foregroundColor: ZC.navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            icon: const Icon(Icons.send_rounded, size: 20),
          ),
        ),
      ]),
      children: [
        const ZChip('Dispatch • online • ticket ALM-208', kind: ChipKind.info),
        for (final m in state.chat)
          Align(
            alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                decoration: BoxDecoration(
                  color: m.mine ? const Color(0xFF1C3D66) : ZC.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: Radius.circular(m.mine ? 14 : 4),
                    bottomRight: Radius.circular(m.mine ? 4 : 14),
                  ),
                  border: Border.all(color: m.mine ? ZC.heroBorder : ZC.surfaceBorder),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m.text, style: const TextStyle(color: ZC.text, fontSize: 12.5, height: 1.5)),
                  const SizedBox(height: 6),
                  Text(m.meta, style: const TextStyle(color: ZC.muted2, fontSize: 10)),
                ]),
              ),
            ),
          ),
      ],
    );
  }
}
