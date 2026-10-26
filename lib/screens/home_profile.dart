import 'dart:async';

import 'package:flutter/material.dart';

import '../core/demo_state.dart';
import '../core/theme.dart';
import '../widgets/z_widgets.dart';

// M88 My profile
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final guard = state.role == Role.guard;
    return ZScaffold(
      eyebrow: 'Account',
      title: 'My profile',
      tab: NavTab.profile,
      children: [
        FormCard(key: ValueKey(state.role), fields: [
          ZField('Employee', initial: guard ? 'Alex Morgan • ZP-042' : 'Priya Shah • ZP-007'),
          ZField('Contact', initial: guard ? 'alex.morgan@zedplus.example' : 'priya.shah@zedplus.example'),
          ZField('Emergency contact', initial: guard ? 'Jamie Morgan' : 'Ravi Shah'),
          ZField('Branch / role', initial: guard ? 'Manitoba • Guard • office controlled' : 'Manitoba • Supervisor • office controlled'),
        ]),
        ActionStack(
          primary: 'Save profile',
          onPrimary: () => fakeSubmit(context, then: () => toast(context, 'Profile saved')),
          links: [
            ('Licences & certificates', () => go(context, '/m89')),
            ('Assigned sites', () => go(context, '/m90')),
            ('App settings', () => go(context, '/m91')),
            ('My requests', () => go(context, '/m80')),
            ('My equipment', () => go(context, '/m71')),
          ],
        ),
      ],
    );
  }
}

// M89 Licences & certificates
class LicencesScreen extends StatelessWidget {
  const LicencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void detail(String t, String s) => showModalBottomSheet<void>(
          context: context,
          backgroundColor: ZC.surface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (c) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t, style: ZT.cardTitle.copyWith(fontSize: 18)),
                const SizedBox(height: 8),
                Text(s, style: ZT.body),
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: ZC.field, borderRadius: BorderRadius.circular(12), border: Border.all(color: ZC.fieldBorder)),
                  child: const Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.badge_outlined, color: ZC.gold, size: 48),
                    SizedBox(height: 8),
                    Text('Document preview', style: ZT.rowSub),
                  ]),
                ),
                const SizedBox(height: 16),
                PrimaryButton('Close', onPressed: () => Navigator.pop(c)),
              ]),
            ),
          ),
        );
    return ZScaffold(
      eyebrow: 'Account',
      title: 'Licences & certificates',
      tab: NavTab.profile,
      children: [
        ListRowCard(title: 'Security guard licence', subtitle: 'Valid until 31 Dec 2027', leading: const StatusDot(color: ZC.successText, icon: Icons.verified_outlined), onTap: () => detail('Security guard licence', 'Manitoba licence MB-SG-20419 • valid until 31 Dec 2027')),
        ListRowCard(title: 'First aid', subtitle: 'Expires in 30 days • update required', subtitleColor: ZC.goldLight, leading: const StatusDot(color: ZC.gold, icon: Icons.medical_services_outlined), onTap: () => detail('First aid', 'Standard First Aid & CPR-C • expires in 30 days')),
        ListRowCard(title: 'WHMIS certificate', subtitle: 'Valid • document available', leading: const StatusDot(color: ZC.successText, icon: Icons.science_outlined), onTap: () => detail('WHMIS certificate', 'Workplace Hazardous Materials Information System • valid')),
        const ZPickerField('Renewal document', value: 'First aid renewal • choose file', attachedName: 'FirstAid-2026.pdf attached'),
        PrimaryButton('Upload renewal', onPressed: () => fakeSubmit(context, label: 'Uploading…', then: () => toast(context, 'Renewal sent to the office for verification'))),
      ],
    );
  }
}

// M90 Assigned sites
class AssignedSitesScreen extends StatelessWidget {
  const AssignedSitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Account',
      title: 'Assigned sites',
      tab: NavTab.profile,
      children: [
        ListRowCard(title: 'Polo Park', subtitle: 'West entrance • Winnipeg', leading: const StatusDot(color: ZC.gold, icon: Icons.location_on_outlined), onTap: () => go(context, '/m52')),
        ListRowCard(title: 'Warehouse', subtitle: 'South gate • Winnipeg', leading: const StatusDot(color: ZC.muted2, icon: Icons.warehouse_outlined), onTap: () => go(context, '/m21')),
        ListRowCard(title: 'Office tower', subtitle: 'Lobby • Winnipeg', leading: const StatusDot(color: ZC.muted2, icon: Icons.apartment_rounded), onTap: () => go(context, '/m52')),
        PrimaryButton('View site instructions', onPressed: () => go(context, '/m53')),
      ],
    );
  }
}

// M91 App settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Account',
      title: 'App settings',
      tab: NavTab.profile,
      children: [
        const ZCard(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 2),
          child: Column(children: [
            ZDropdown('Language', options: ['English', 'Français']),
            ZDropdown('Appearance', options: ['Deep navy • dark theme', 'Follow device']),
          ]),
        ),
        ToggleListCard(
          icons: const [Icons.pin_outlined, Icons.notifications_none_rounded, Icons.text_fields_rounded, Icons.phone_iphone_rounded],
          items: [
            ToggleItem('Security', 'PIN and biometric unlock', true),
            ToggleItem('Notifications', 'Shifts • dispatch • approvals', true),
            ToggleItem('Accessibility', 'Follow device text size', true),
            ToggleItem('Device sessions', 'This phone • active', true),
          ],
        ),
        ActionStack(
          primary: 'Save preferences',
          onPrimary: () => fakeSubmit(context, then: () => toast(context, 'Preferences saved')),
          links: [
            ('Offline sync queue', () => go(context, '/m18')),
            ('Sign out', () async {
              final ok = await confirmDialog(context, title: 'Sign out?', message: 'You will need your password or PIN to sign in again.', ok: 'Sign out');
              if (ok && context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/m01', (r) => false);
            }),
          ],
        ),
      ],
    );
  }
}

// M07 Guard home
class GuardHomeScreen extends StatelessWidget {
  const GuardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final onDuty = state.clockedIn;
    final done = state.clockOutAt != null;
    return ZScaffold(
      eyebrow: 'Home',
      title: 'Guard home',
      subtitle: '${_greeting()}, ${state.firstName}',
      crumb: null,
      tab: NavTab.home,
      children: [
        HeroCard(
          label: 'Today’s shift',
          badge: ZChip(onDuty ? 'On duty' : done ? 'Completed' : 'Confirmed', kind: ChipKind.success),
          title: 'Polo Park',
          subtitle: 'West entrance • static guarding',
          time: '07:00–15:00',
          footer: onDuty ? 'Clocked in ${hhmm(state.clockInAt!)} • GPS verified' : done ? 'Shift complete • timesheet pending approval' : 'Start in 2 minutes • local site time',
          onTap: () => go(context, '/m23'),
        ),
        StatGrid([
          Stat('${state.checkpointsDone == 6 ? 1 : 2}', 'Tours due'),
          const Stat('3', 'Open tasks'),
        ]),
        WorkQueueCard(items: [
          ('Patrol tours', () => go(context, '/m37')),
          ('Tasks & checklists', () => go(context, '/m50')),
          ('Post orders & policies', () => go(context, '/m52')),
          ('Messages', () => go(context, '/m65')),
          ('Safety centre', () => go(context, '/m60')),
        ]),
        GestureDetector(onTap: () => go(context, '/m54'), child: const Notice('Read the latest passdown before taking over the post.')),
        if (onDuty)
          PrimaryButton('Go to active shift', onPressed: () => go(context, '/m12'))
        else if (done)
          PrimaryButton('View timesheet', onPressed: () => go(context, '/m19'))
        else
          PrimaryButton('Clock in', icon: Icons.fingerprint_rounded, onPressed: () => go(context, '/m09')),
      ],
    );
  }
}

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

// M08 Supervisor home
class SupervisorHomeScreen extends StatelessWidget {
  const SupervisorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final next = state.currentStop;
    return ZScaffold(
      eyebrow: 'Home',
      title: 'Supervisor home',
      subtitle: '${_greeting()}, ${state.firstName}',
      crumb: null,
      tab: NavTab.home,
      children: [
        HeroCard(
          label: 'Today’s route',
          badge: ZChip(next == null ? 'Completed' : 'On route', kind: ChipKind.success),
          title: 'Winnipeg West',
          subtitle: '4 stops • assigned to Priya Shah',
          time: '08:00–12:00',
          footer: next == null ? 'All stops visited • summary ready' : 'Next stop: ${next.name} • ${next.window}',
          onTap: () => go(context, '/m28'),
        ),
        StatGrid([
          Stat('${4 - state.stopsDone}', 'Route stops left'),
          Stat('${state.approvals.length}', 'Pending approvals'),
        ]),
        WorkQueueCard(items: [
          ('Today’s supervision route', () => go(context, '/m28')),
          ('Approvals inbox', () => go(context, '/m82')),
          ('Dispatch jobs', () => go(context, '/m56')),
          ('Messages', () => go(context, '/m65')),
        ]),
        const Notice('Traffic delay at stop 3. Dispatch has been notified.'),
        PrimaryButton(next == null ? 'View route summary' : 'Start today’s route', icon: Icons.route_rounded, onPressed: () => go(context, next == null ? '/m35' : '/m28')),
      ],
    );
  }
}

// M87 Notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      if (mounted) DemoScope.read(context).readNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Account',
      title: 'Notifications',
      children: [
        ListRowCard(title: 'Route changed', subtitle: 'Dispatch reordered stops 3 and 4 • now', leading: const StatusDot(color: ZC.gold, icon: Icons.alt_route_rounded), onTap: () => go(context, '/m28')),
        ListRowCard(title: 'Equipment ready', subtitle: 'REQ-104 • collect from Winnipeg store', leading: const StatusDot(color: ZC.successText, icon: Icons.inventory_2_outlined), onTap: () => go(context, '/m81')),
        ListRowCard(title: 'Licence reminder', subtitle: 'First aid expires in 30 days', leading: const StatusDot(color: ZC.gold, icon: Icons.badge_outlined), onTap: () => go(context, '/m89')),
        ListRowCard(title: 'Report returned', subtitle: 'MT-204 • evidence requested', leading: const StatusDot(color: ZC.dangerText, icon: Icons.assignment_return_outlined), onTap: () => go(context, '/m49')),
        PrimaryButton('Open latest alert', onPressed: () => go(context, '/m28')),
      ],
    );
  }
}
