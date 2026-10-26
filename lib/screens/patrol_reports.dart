import 'package:flutter/material.dart';

import '../core/demo_state.dart';
import '../core/theme.dart';
import '../widgets/visuals.dart';
import '../widgets/z_widgets.dart';

// M37 Patrol tours
class PatrolToursScreen extends StatelessWidget {
  const PatrolToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final done = state.checkpointsDone;
    final finished = done == state.checkpoints.length;
    return ZScaffold(
      eyebrow: 'Patrols',
      title: 'Patrol tours',
      tab: NavTab.patrol,
      children: [
        ListRowCard(
          title: 'Perimeter tour',
          subtitle: finished ? 'Completed • 6 / 6' : (done > 2 ? 'In progress • $done / 6 checkpoints' : 'Due now • 6 checkpoints • ordered'),
          subtitleColor: finished ? ZC.successText : ZC.goldLight,
          leading: StatusDot(color: finished ? ZC.successText : ZC.gold, icon: finished ? Icons.check_rounded : Icons.radar_rounded),
          onTap: () => go(context, finished ? '/m42' : '/m38'),
        ),
        ListRowCard(title: 'Interior safety tour', subtitle: '10:00–10:20 • 4 checkpoints', leading: const StatusDot(color: ZC.muted2, icon: Icons.schedule_rounded), onTap: () => toast(context, 'Interior safety tour opens at 10:00')),
        ListRowCard(title: 'Opening tour', subtitle: 'Completed • 06:45 • 6 / 6', subtitleColor: ZC.successText, leading: const StatusDot(color: ZC.successText, icon: Icons.check_rounded), onTap: () => toast(context, 'Opening tour completed at 06:45')),
        ActionStack(
          primary: finished ? 'View tour summary' : (done > 2 ? 'Continue perimeter tour' : 'Start perimeter tour'),
          icon: Icons.play_arrow_rounded,
          onPrimary: () => go(context, finished ? '/m42' : '/m38'),
          links: [if (finished) ('Demo: reset perimeter tour', () => DemoScope.read(context).resetTour())],
        ),
      ],
    );
  }
}

// M38 Tour in progress
class TourInProgressScreen extends StatelessWidget {
  const TourInProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final done = state.checkpointsDone;
    final total = state.checkpoints.length;
    final next = state.nextCheckpoint;
    return ZScaffold(
      eyebrow: 'Patrols',
      title: 'Tour in progress',
      tab: NavTab.patrol,
      children: [
        HeroCard(
          label: 'Perimeter tour',
          badge: ZChip(next == null ? 'Complete' : 'In progress', kind: next == null ? ChipKind.success : ChipKind.gold),
          title: '$done of $total checkpoints completed',
          progress: done / total,
          footer: next == null ? 'All checkpoints scanned' : 'Started 07:08 • next scan: ${next.name}',
        ),
        for (final c in state.checkpoints)
          ListRowCard(
            title: c.name,
            subtitle: c.done ? 'Completed • ${c.doneBy} • ${c.doneAt}' : (identical(c, next) ? 'Next • ${c.method} scan' : 'Pending • ${c.method}'),
            subtitleColor: c.done ? ZC.successText : (identical(c, next) ? ZC.goldLight : null),
            leading: StatusDot(
              color: c.done ? ZC.successText : (identical(c, next) ? ZC.gold : ZC.fieldBorder),
              icon: c.done ? Icons.check_rounded : (c.method == 'NFC' ? Icons.nfc_rounded : c.method == 'QR' ? Icons.qr_code_rounded : Icons.gps_fixed_rounded),
            ),
            onTap: identical(c, next) ? () => go(context, '/m39') : null,
            trailing: identical(c, next) ? null : const SizedBox(),
          ),
        PrimaryButton(next == null ? 'Submit tour' : 'Scan next checkpoint', icon: next == null ? Icons.send_rounded : Icons.nfc_rounded, onPressed: () => go(context, next == null ? '/m42' : '/m39')),
      ],
    );
  }
}

// M39 Checkpoint scan
class CheckpointScanScreen extends StatefulWidget {
  const CheckpointScanScreen({super.key});

  @override
  State<CheckpointScanScreen> createState() => _CheckpointScanScreenState();
}

class _CheckpointScanScreenState extends State<CheckpointScanScreen> {
  int method = 0;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final next = DemoScope.read(context).nextCheckpoint;
    if (next != null) {
      method = next.method == 'QR' ? 1 : next.method == 'GPS' ? 2 : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final next = state.nextCheckpoint;
    final idx = next == null ? state.checkpoints.length : state.checkpoints.indexOf(next) + 1;
    const labels = ['NFC', 'QR', 'GPS'];
    return ZScaffold(
      eyebrow: 'Patrols',
      title: 'Checkpoint scan',
      subtitle: '${next?.name ?? 'Tour complete'} • checkpoint ${idx.toString().padLeft(2, '0')}',
      tab: NavTab.patrol,
      children: [
        ScannerView(key: ValueKey(method), method: method),
        SegmentedTabs(options: const ['NFC', 'QR / barcode', 'GPS'], selected: method, onChanged: (i) => setState(() => method = i)),
        const ZCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ready to scan', style: ZT.cardTitle),
            SizedBox(height: 8),
            Text('Checkpoint method and fallback follow your site’s settings.', style: ZT.body),
          ]),
        ),
        Notice(method == 0
            ? 'Hold your device near the NFC tag, or switch to an allowed QR/GPS method.'
            : method == 1
                ? 'Point the camera at the checkpoint QR label.'
                : 'Stand within 15 m of the checkpoint to confirm by GPS.'),
        ActionStack(
          primary: 'Confirm ${labels[method]} scan',
          icon: Icons.check_rounded,
          onPrimary: next == null
              ? null
              : () => fakeSubmit(context, label: 'Reading tag…', ms: 800, then: () {
                    DemoScope.read(context).completeNextCheckpoint(labels[method]);
                    goReplace(context, '/m40');
                  }),
          links: [('Demo: simulate scan failure', () => goReplace(context, '/m41'))],
        ),
      ],
    );
  }
}

// M40 Checkpoint questions
class CheckpointQuestionsScreen extends StatefulWidget {
  const CheckpointQuestionsScreen({super.key});

  @override
  State<CheckpointQuestionsScreen> createState() => _CheckpointQuestionsScreenState();
}

class _CheckpointQuestionsScreenState extends State<CheckpointQuestionsScreen> {
  String secured = 'No';

  void _continue() {
    final state = DemoScope.read(context);
    toast(context, 'Checkpoint saved • ${state.checkpointsDone}/6');
    if (state.nextCheckpoint == null) {
      goReplace(context, '/m42');
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final issue = secured == 'No';
    return ZScaffold(
      eyebrow: 'Patrols',
      title: 'Checkpoint questions',
      tab: NavTab.patrol,
      children: [
        FormCard(fields: [
          ZDropdown('Gate secured?', options: const ['No', 'Yes'], initial: secured, onChanged: (v) => setState(() => secured = v)),
          ZDropdown('Condition', options: issue ? const ['Latch damaged', 'Lock missing', 'Other'] : const ['Good', 'Minor wear'], key: ValueKey(issue)),
          ZField('Observation', initial: issue ? 'Gate does not lock fully.' : 'No issues observed.', key: ValueKey('o$issue')),
          const ZPickerField('Required photo', value: 'Gate-latch.jpg attached', icon: Icons.photo_camera_outlined),
        ]),
        if (issue) const Notice('A serious finding creates an incident linked to this checkpoint.', danger: true),
        ActionStack(
          primary: issue ? 'Report issue' : 'Save & continue tour',
          icon: issue ? Icons.report_gmailerrorred_rounded : Icons.arrow_forward_rounded,
          danger: issue,
          onPrimary: () {
            if (issue) {
              DemoScope.read(context).addLinkedIncident();
              go(context, '/m45');
            } else {
              _continue();
            }
          },
          links: [if (issue) ('Save checkpoint & continue tour', _continue)],
        ),
      ],
    );
  }
}

// M42 Tour summary
class TourSummaryScreen extends StatelessWidget {
  const TourSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    return ZScaffold(
      eyebrow: 'Patrols',
      title: 'Tour summary',
      tab: NavTab.patrol,
      children: [
        const SuccessPanel(title: 'Perimeter patrol\nsubmitted'),
        StatGrid([
          Stat('${state.checkpointsDone} / ${state.checkpoints.length}', 'Scanned checkpoints'),
          const Stat('22 min', 'Duration'),
          Stat('${state.linkedIncidents}', 'Linked incident', color: state.linkedIncidents > 0 ? ZC.dangerText : null),
        ]),
        const Notice('All required checks complete. GPS and scan timestamps included.'),
        PrimaryButton('Back to tours', onPressed: () => goTab(context, NavTab.patrol)),
      ],
    );
  }
}

// M41 Scan failed
class ScanFailedScreen extends StatelessWidget {
  const ScanFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Patrols',
      title: 'Scan failed',
      tab: NavTab.patrol,
      children: [
        const SuccessPanel(title: 'Tag could not be read', icon: Icons.priority_high_rounded, color: ZC.dangerText),
        const Notice('Retry near the tag. Manual entry is available at this site with a reason and evidence.'),
        ActionStack(
          primary: 'Retry checkpoint',
          icon: Icons.refresh_rounded,
          onPrimary: () => goReplace(context, '/m39'),
          links: [('Punch exception request', () => go(context, '/m17'))],
        ),
      ],
    );
  }
}

// M43 Reports & drafts
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Reports',
      title: 'Reports & drafts',
      tab: NavTab.reports,
      children: [
        ListRowCard(title: 'Daily activity • today', subtitle: 'Draft • updated 07:32', subtitleColor: ZC.goldLight, leading: const StatusDot(color: ZC.gold, icon: Icons.edit_note_rounded), onTap: () => go(context, '/m46')),
        ListRowCard(title: 'Incident #INC-1042', subtitle: 'Submitted • high severity', leading: const StatusDot(color: ZC.successText, icon: Icons.check_rounded), onTap: () => go(context, '/m48')),
        ListRowCard(title: 'Maintenance #MT-204', subtitle: 'Returned for correction', subtitleColor: ZC.dangerText, leading: const StatusDot(color: ZC.dangerText, icon: Icons.assignment_return_outlined), onTap: () => go(context, '/m49')),
        ActionStack(
          primary: 'Choose report type',
          icon: Icons.add_rounded,
          onPrimary: () => go(context, '/m44'),
          links: [
            ('Visitor log', () => go(context, '/m68')),
            ('Vehicle log', () => go(context, '/m70')),
          ],
        ),
      ],
    );
  }
}

// M44 Report templates
class ReportTemplatesScreen extends StatelessWidget {
  const ReportTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Reports',
      title: 'Report templates',
      tab: NavTab.reports,
      children: [
        ListRowCard(title: 'Daily activity', subtitle: 'Shift observations and activity', leading: const StatusDot(color: ZC.gold, icon: Icons.today_rounded), onTap: () => go(context, '/m46')),
        ListRowCard(title: 'Incident', subtitle: 'People, vehicles, actions and evidence', leading: const StatusDot(color: ZC.dangerText, icon: Icons.report_outlined), onTap: () => go(context, '/m45')),
        ListRowCard(title: 'Hourly check-in', subtitle: 'Required site status update', leading: const StatusDot(color: ZC.gold, icon: Icons.schedule_rounded), onTap: () => go(context, '/m46')),
        ListRowCard(title: 'Alarm response', subtitle: 'Findings, keyholder and outcome', leading: const StatusDot(color: ZC.gold, icon: Icons.notifications_active_outlined), onTap: () => go(context, '/m59')),
        ListRowCard(title: 'Other site forms', subtitle: 'Maintenance • parking • lost & found', leading: const StatusDot(color: ZC.muted2, icon: Icons.folder_open_rounded), onTap: () => toast(context, 'Custom forms are configured per site')),
        PrimaryButton('Create incident report', onPressed: () => go(context, '/m45')),
      ],
    );
  }
}

// M45 Incident report
class IncidentReportScreen extends StatelessWidget {
  const IncidentReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Reports',
      title: 'Incident report',
      tab: NavTab.reports,
      children: [
        FormCard(fields: [
          const ZDropdown('Type / severity', options: ['Property damage • high', 'Property damage • medium', 'Trespass • high', 'Medical • high', 'Theft • medium']),
          ZField('Location / discovered', initial: 'North gate • ${hhmm(DateTime.now())}'),
          const ZField('Narrative', initial: 'Damaged latch discovered during perimeter patrol.', maxLines: 4),
          const ZField('People / vehicles', initial: 'None observed'),
          const ZDropdown('Emergency services', options: ['Not required', 'Police called', 'Ambulance called', 'Fire called']),
          const ZField('Action taken', initial: 'Gate secured temporarily; supervisor notified.', maxLines: 3),
        ]),
        ActionStack(
          primary: 'Add evidence',
          icon: Icons.add_a_photo_outlined,
          onPrimary: () => go(context, '/m47'),
          links: [('Save as draft', () => fakeSubmit(context, label: 'Saving draft…', then: () => toast(context, 'Draft saved on this device')))],
        ),
      ],
    );
  }
}

// M46 Daily & hourly activity
class DailyActivityScreen extends StatelessWidget {
  const DailyActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Reports',
      title: 'Daily & hourly activity',
      tab: NavTab.reports,
      children: [
        FormCard(fields: [
          const ZDropdown('Report type', options: ['Daily activity', 'Hourly check-in']),
          const ZField('Site / shift', initial: 'Polo Park • 07:00–15:00'),
          ZField('Observation time', initial: hhmm(DateTime.now())),
          const ZField('Activity', initial: 'Perimeter patrol completed. North gate issue reported.', maxLines: 4),
          const ZField('Follow-up', initial: 'Recheck temporary gate repair at 10:00', maxLines: 2),
        ]),
        PrimaryButton('Review report', onPressed: () => go(context, '/m47')),
      ],
    );
  }
}

// M47 Report evidence
class ReportEvidenceScreen extends StatelessWidget {
  const ReportEvidenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Reports',
      title: 'Report evidence',
      tab: NavTab.reports,
      children: [
        Row(children: [
          for (final n in const ['Gate-latch.jpg', 'North-gate.jpg']) ...[
            Expanded(
              child: Container(
                height: 96,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(colors: [Color(0xFF3B5470), Color(0xFF26364A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  border: Border.all(color: ZC.fieldBorder),
                ),
                child: Stack(children: [
                  const Center(child: Icon(Icons.image_outlined, color: ZC.muted2, size: 34)),
                  Positioned(left: 8, bottom: 6, child: Text(n, style: const TextStyle(color: ZC.textSoft, fontSize: 9.5))),
                ]),
              ),
            ),
          ],
        ]),
        const FormCard(fields: [
          ZPickerField('Photo evidence', value: 'Gate-latch.jpg • North-gate.jpg', icon: Icons.photo_camera_outlined, attachedName: 'Gate-latch.jpg • North-gate.jpg • +1 photo'),
          ZPickerField('Video / audio', value: 'Add short video or voice note', icon: Icons.mic_none_rounded, attachedName: 'Voice-note-0042.m4a attached'),
          ZPickerField('Sketch / signature', value: 'Optional supporting evidence', icon: Icons.draw_outlined, attachedName: 'Sketch attached'),
        ]),
        const Notice('Capture time and GPS are attached automatically. Required fields must be complete.'),
        PrimaryButton('Submit report', icon: Icons.send_rounded, onPressed: () => fakeSubmit(context, label: 'Uploading evidence…', ms: 1300, then: () => goReplace(context, '/m48'))),
      ],
    );
  }
}

// M48 Report submitted
class ReportSubmittedScreen extends StatelessWidget {
  const ReportSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    return ZScaffold(
      eyebrow: 'Reports',
      title: 'Report submitted',
      chip: const ZChip('Awaiting review'),
      tab: NavTab.reports,
      children: [
        SuccessPanel(title: 'Report #${state.lastReportId}\nsubmitted'),
        const Notice('The operations manager has been notified. Evidence and captured location are attached.'),
        ActionStack(
          primary: 'View report history',
          onPrimary: () => goTab(context, NavTab.reports),
          links: [
            if (state.nextCheckpoint != null && state.checkpointsDone > 2) ('Continue patrol tour', () => goFromHome(context, '/m38')),
          ],
        ),
      ],
    );
  }
}

// M49 Report correction
class ReportCorrectionScreen extends StatelessWidget {
  const ReportCorrectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Reports',
      title: 'Report correction',
      chip: const ZChip('Returned • MT-204', kind: ChipKind.danger),
      tab: NavTab.reports,
      children: [
        const ZCard(
          color: ZC.notice,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('REVIEWER NOTE • PRIYA SHAH', style: ZT.caps),
            SizedBox(height: 8),
            Text('Please add a clear photo of the temporary repair.', style: TextStyle(color: ZC.text, fontSize: 13.5, height: 1.5)),
          ]),
        ),
        const FormCard(fields: [
          ZField('Response', initial: 'Repair photo added with follow-up details.', maxLines: 3),
          ZPickerField('Additional evidence', value: 'Temporary-repair.jpg', icon: Icons.photo_camera_outlined),
        ]),
        const Notice('Version 1 remains in history. Resubmission creates a revised version.'),
        PrimaryButton('Resubmit report', onPressed: () => fakeSubmit(context, then: () {
              toast(context, 'MT-204 v2 resubmitted for review');
              Navigator.of(context).maybePop();
            })),
      ],
    );
  }
}
