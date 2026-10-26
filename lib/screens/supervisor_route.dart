import 'package:flutter/material.dart';

import '../core/demo_state.dart';
import '../core/theme.dart';
import '../widgets/visuals.dart';
import '../widgets/z_widgets.dart';

// M28 Today's supervision route
class TodayRouteScreen extends StatelessWidget {
  const TodayRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final done = state.stopsDone;
    final allDone = state.currentStop == null;
    return ZScaffold(
      eyebrow: 'Routes',
      title: 'Today’s supervision route',
      subtitle: 'Winnipeg West • 4 stops',
      crumb: kRouteCrumb,
      tab: NavTab.schedule,
      children: [
        HeroCard(
          label: 'Route progress',
          badge: ZChip(allDone ? 'Completed' : 'On route', kind: ChipKind.success),
          title: '$done of 4 stops completed',
          progress: done / 4,
          footer: '42.6 km planned • 72 min drive time',
        ),
        for (var i = 0; i < state.stops.length; i++)
          _stopRow(context, i, state.stops[i]),
        ActionStack(
          primary: allDone ? 'Route summary' : 'View route map',
          icon: allDone ? Icons.summarize_outlined : Icons.map_outlined,
          onPrimary: () => go(context, allDone ? '/m35' : '/m29'),
          links: [
            if (!allDone) ('Route summary', () => go(context, '/m35')),
            ('Demo: reset route', () => DemoScope.read(context).resetRoute()),
          ],
        ),
      ],
    );
  }

  Widget _stopRow(BuildContext context, int i, RouteStop s) {
    final color = switch (s.status) {
      'Completed' => ZC.successText,
      'Skipped' => ZC.dangerText,
      'Next' => ZC.gold,
      _ => ZC.muted2,
    };
    final sub = switch (s.status) {
      'Completed' => 'Completed • ${s.window}',
      'Skipped' => 'Skipped • reason sent to dispatch',
      'Next' => i == 2 ? 'Next • ETA 09:17 • late' : 'Next • ${s.window}',
      _ => i == 3 ? 'Upcoming • ETA 10:06 • at risk' : 'Upcoming • ${s.window}',
    };
    return ListRowCard(
      title: '${i + 1} • ${s.name}',
      subtitle: sub,
      subtitleColor: s.status == 'Upcoming' ? ZC.muted : color,
      leading: StatusDot(color: color, icon: s.status == 'Completed' ? Icons.check_rounded : s.status == 'Skipped' ? Icons.block_rounded : Icons.location_on_outlined),
      onTap: s.status == 'Next' ? () => go(context, '/m30') : () => toast(context, '${s.name} • ${s.status.toLowerCase()}'),
    );
  }
}

// M29 Route map
class RouteMapScreen extends StatelessWidget {
  const RouteMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final next = DemoScope.of(context).currentStop;
    return ZScaffold(
      eyebrow: 'Routes',
      title: 'Route map',
      subtitle: 'Winnipeg West • supervisor route',
      chip: const ZChip('Traffic delay • +7 min', kind: ChipKind.danger),
      crumb: kRouteCrumb,
      tab: NavTab.schedule,
      children: [
        const MapIllustration(mode: MapMode.route, height: 250, progress: 0.4),
        const StatGrid([
          Stat('09:17', 'Next stop ETA', color: ZC.goldLight),
          Stat('6.4 km', 'Distance'),
          Stat('09:00–09:10', 'Arrival window'),
          Stat('+7 min', 'Traffic', color: ZC.dangerText),
        ]),
        const Notice('Stop 3 is late. Dispatcher notified. Updated traffic at 09:02.'),
        PrimaryButton(next == null ? 'Route summary' : 'Open next stop', onPressed: () => go(context, next == null ? '/m35' : '/m30')),
      ],
    );
  }
}

// M30 Route stop detail
class RouteStopDetailScreen extends StatelessWidget {
  const RouteStopDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final next = DemoScope.of(context).currentStop;
    final isSite3 = next?.name == 'Construction site';
    return ZScaffold(
      eyebrow: 'Routes',
      title: 'Route stop detail',
      crumb: kRouteCrumb,
      tab: NavTab.schedule,
      children: [
        KeyValueCard([
          (isSite3 ? 'Stop 3' : 'Stop 4', isSite3 ? 'Construction site • North gate' : 'Warehouse • South gate'),
          ('Address', isSite3 ? '330 St Mary Ave, Winnipeg' : '1450 Inkster Blvd, Winnipeg'),
          ('Window', isSite3 ? '09:00–09:10' : '10:00–10:15'),
          ('Live ETA', isSite3 ? '09:17 • traffic delay' : '10:06 • on time'),
          const ('Site contact', 'Morgan Reid • keyholder'),
          const ('Visit duration', '15 minutes'),
        ]),
        ActionStack(
          primary: 'Navigate to site',
          icon: Icons.navigation_outlined,
          onPrimary: () => go(context, '/m31'),
          links: [
            ('Arrived • site check-in', () => go(context, '/m21')),
            ('Site inspection', () => go(context, '/m32')),
            ('Skip route stop', () => go(context, '/m34')),
          ],
        ),
      ],
    );
  }
}

// M31 Navigation handoff
class NavigationHandoffScreen extends StatelessWidget {
  const NavigationHandoffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Routes',
      title: 'Navigation handoff',
      subtitle: 'Directions to Construction site',
      chip: const ZChip('Maps handoff preview', kind: ChipKind.info),
      crumb: kRouteCrumb,
      tab: NavTab.schedule,
      children: [
        const MapIllustration(mode: MapMode.route, height: 240, progress: 0.75),
        const StatGrid([Stat('6.4 km', 'Remaining'), Stat('17 min', 'Drive time')]),
        const Notice('In production this opens Google Maps or Apple Maps. Route state is preserved when you return.'),
        ActionStack(
          primary: 'I’ve arrived • start inspection',
          icon: Icons.fact_check_outlined,
          onPrimary: () => fakeSubmit(context, label: 'Site check-in by GPS…', then: () => goReplace(context, '/m32')),
          links: [('Return to route', () => Navigator.of(context).maybePop())],
        ),
      ],
    );
  }
}

// M32 Site inspection
class SiteInspectionScreen extends StatefulWidget {
  const SiteInspectionScreen({super.key});

  @override
  State<SiteInspectionScreen> createState() => _SiteInspectionScreenState();
}

class _SiteInspectionScreenState extends State<SiteInspectionScreen> {
  final items = [
    CheckItem('Guard present and on post', 'Verified at 09:17', true),
    CheckItem('Uniform and equipment', 'Photo evidence added', true),
    CheckItem('Post orders acknowledged', 'Version 4 reviewed', true),
    CheckItem('Logbook reviewed', 'No outstanding entries', false),
    CheckItem('Site condition', 'North gate latch needs repair', false),
  ];

  @override
  Widget build(BuildContext context) {
    final count = items.where((i) => i.checked).length;
    return ZScaffold(
      eyebrow: 'Routes',
      title: 'Site inspection',
      chip: ZChip('$count of ${items.length} checks', kind: count == items.length ? ChipKind.success : ChipKind.gold),
      crumb: kRouteCrumb,
      tab: NavTab.schedule,
      children: [
        ChecklistCard(items: items, onChanged: () => setState(() {})),
        const FormCard(title: null, fields: [
          SizedBox(height: 2),
          ZField('Inspector notes', initial: 'Latch repair logged with maintenance.', maxLines: 3),
          ZPickerField('Inspection photos', value: '3 photos attached', icon: Icons.photo_camera_outlined, attachedName: '4 photos attached'),
        ]),
        PrimaryButton('Continue to client sign-off', onPressed: count == items.length ? () => go(context, '/m33') : null),
        if (count != items.length) const Center(child: Text('Complete all checks to continue', style: ZT.rowSub)),
      ],
    );
  }
}

// M33 Client sign-off
class ClientSignOffScreen extends StatefulWidget {
  const ClientSignOffScreen({super.key});

  @override
  State<ClientSignOffScreen> createState() => _ClientSignOffScreenState();
}

class _ClientSignOffScreenState extends State<ClientSignOffScreen> {
  bool signed = false;

  @override
  Widget build(BuildContext context) {
    final stop = DemoScope.of(context).currentStop;
    return ZScaffold(
      eyebrow: 'Routes',
      title: 'Client sign-off',
      subtitle: '${stop?.name ?? 'Construction site'} • visit proof',
      crumb: kRouteCrumb,
      tab: NavTab.schedule,
      children: [
        ZCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const ZDropdown('Client contact', options: ['Morgan Reid', 'Site manager on duty']),
            SignaturePad(signer: 'Morgan Reid', onChanged: (v) => setState(() => signed = v)),
          ]),
        ),
        const Notice('Arrival 09:17 • inspection complete • 3 photos attached.'),
        PrimaryButton('Save signature & depart', icon: Icons.logout_rounded, onPressed: signed
            ? () => fakeSubmit(context, label: 'Saving visit proof…', then: () {
                  final s = DemoScope.read(context);
                  s.completeCurrentStop();
                  toast(context, 'Site checked out • ${s.stopsDone} of 4 stops done');
                  goFromHome(context, s.currentStop == null ? '/m35' : '/m28');
                })
            : null),
      ],
    );
  }
}

// M35 Route summary
class RouteSummaryScreen extends StatelessWidget {
  const RouteSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final complete = state.currentStop == null;
    return ZScaffold(
      eyebrow: 'Routes',
      title: 'Route summary',
      crumb: kRouteCrumb,
      tab: NavTab.schedule,
      children: [
        SuccessPanel(title: complete ? 'Winnipeg West route\ncompleted' : 'Route in progress', icon: complete ? Icons.check_rounded : Icons.route_rounded),
        StatGrid([
          Stat('${state.stopsDone} / 4', 'Stops visited'),
          const Stat('1', 'Late stop', color: ZC.goldLight),
          const Stat('42.6 km', 'Route distance'),
          const Stat('1h 12m', 'Drive time'),
        ]),
        const Notice('Arrival, departure, dwell times and inspection evidence are ready for review.'),
        PrimaryButton('Claim mileage', icon: Icons.directions_car_outlined, onPressed: () => go(context, '/m36')),
      ],
    );
  }
}

// M36 Mileage claim
class MileageClaimScreen extends StatelessWidget {
  const MileageClaimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Routes',
      title: 'Mileage claim',
      crumb: kRouteCrumb,
      tab: NavTab.schedule,
      children: [
        const FormCard(fields: [
          ZField('Route', initial: 'Winnipeg West • 12 October'),
          ZField('Verified distance', initial: '42.6 km'),
          ZField('Claim distance', initial: '42.6 km', keyboard: TextInputType.number),
          ZField('Notes', initial: 'Completed all assigned stops', maxLines: 2),
        ]),
        const Notice('Supervisor and payroll review the claim under company mileage rules.'),
        PrimaryButton('Submit mileage claim', onPressed: () => fakeSubmit(context, then: () {
              toast(context, 'Mileage claim submitted • 42.6 km');
              goTab(context, NavTab.home);
            })),
      ],
    );
  }
}

// M34 Skip route stop
class SkipStopScreen extends StatelessWidget {
  const SkipStopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stop = DemoScope.of(context).currentStop;
    return ZScaffold(
      eyebrow: 'Routes',
      title: 'Skip route stop',
      crumb: kRouteCrumb,
      tab: NavTab.schedule,
      children: [
        FormCard(fields: [
          ZField('Stop', initial: stop == null ? '—' : '${stop.name} • North gate'),
          const ZDropdown('Reason', options: ['Access unavailable', 'Site closed', 'Safety concern', 'Re-prioritised by dispatch']),
          const ZField('Notes', initial: 'Site contact advised gate closed until 10:30.', maxLines: 3),
        ]),
        const Notice('Dispatch receives the reason. The skipped stop remains in route history.'),
        PrimaryButton('Submit skip request', onPressed: stop == null
            ? null
            : () => fakeSubmit(context, then: () {
                  final s = DemoScope.read(context);
                  s.completeCurrentStop(skipped: true);
                  toast(context, 'Stop skipped • dispatch notified');
                  goFromHome(context, s.currentStop == null ? '/m35' : '/m28');
                })),
      ],
    );
  }
}
