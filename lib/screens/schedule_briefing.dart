import 'package:flutter/material.dart';

import '../core/demo_state.dart';
import '../core/theme.dart';
import '../widgets/z_widgets.dart';

class _Shift {
  const _Shift(this.site, this.time, this.status);
  final String site;
  final String time;
  final String status;
}

const _week = <int, _Shift?>{
  12: _Shift('Polo Park • West entrance', '07:00–15:00', 'Confirmed'),
  13: _Shift('Polo Park • West entrance', '07:00–15:00', 'Unconfirmed'),
  14: _Shift('Office tower • Lobby', '08:00–16:00', 'Confirmed'),
  15: _Shift('Warehouse • South gate', '07:00–15:00', 'Confirmed'),
  16: _Shift('Polo Park • West entrance', '07:00–15:00', 'Confirmed'),
  17: null,
  18: null,
};

// M22 My schedule
class MyScheduleScreen extends StatefulWidget {
  const MyScheduleScreen({super.key});

  @override
  State<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen> {
  int day = 12;
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _full = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];

  @override
  Widget build(BuildContext context) {
    final shift = _week[day];
    return ZScaffold(
      eyebrow: 'Scheduling',
      title: 'My schedule',
      tab: NavTab.schedule,
      children: [
        Row(children: [
          for (var i = 0; i < 7; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => day = 12 + i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: day == 12 + i ? ZC.gold : ZC.field,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: day == 12 + i ? ZC.gold : ZC.fieldBorder),
                  ),
                  child: Column(children: [
                    Text(_days[i], style: TextStyle(fontSize: 10, color: day == 12 + i ? ZC.navy : ZC.muted2)),
                    const SizedBox(height: 4),
                    Text('${12 + i}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: day == 12 + i ? ZC.navy : ZC.text)),
                    const SizedBox(height: 4),
                    Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: _week[12 + i] == null ? Colors.transparent : (day == 12 + i ? ZC.navy : ZC.gold))),
                  ]),
                ),
              ),
            ),
          ],
        ]),
        if (shift != null)
          HeroCard(
            label: '${_full[day - 12]} $day OCT',
            badge: ZChip(shift.status, kind: shift.status == 'Confirmed' ? ChipKind.success : ChipKind.gold),
            title: shift.site,
            time: shift.time,
            footer: '8h scheduled • 30m unpaid break',
            onTap: () => go(context, '/m23'),
          )
        else
          ZCard(
            child: Column(children: [
              const Icon(Icons.weekend_outlined, color: ZC.muted, size: 34),
              const SizedBox(height: 10),
              Text('${_full[day - 12]} $day OCT', style: ZT.caps),
              const SizedBox(height: 6),
              const Text('Day off • no shifts scheduled', style: ZT.rowTitle),
            ]),
          ),
        ListRowCard(title: 'Tue 13 • Polo Park', subtitle: '07:00–15:00 • unconfirmed', subtitleColor: ZC.goldLight, onTap: () => go(context, '/m23')),
        ListRowCard(title: 'Wed 14 • Office tower', subtitle: '08:00–16:00 • confirmed', onTap: () => go(context, '/m23')),
        ListRowCard(title: 'Thu 15 • Warehouse', subtitle: '07:00–15:00 • confirmed', onTap: () => go(context, '/m23')),
        ActionStack(
          primary: 'Open shift detail',
          onPrimary: () => go(context, '/m23'),
          links: [
            ('Open shifts', () => go(context, '/m24')),
            ('Availability', () => go(context, '/m25')),
            ('Time off request', () => go(context, '/m26')),
            ('Shift swap', () => go(context, '/m27')),
          ],
        ),
      ],
    );
  }
}

// M23 Shift detail
class ShiftDetailScreen extends StatefulWidget {
  const ShiftDetailScreen({super.key});

  @override
  State<ShiftDetailScreen> createState() => _ShiftDetailScreenState();
}

class _ShiftDetailScreenState extends State<ShiftDetailScreen> {
  bool confirmed = false;

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Scheduling',
      title: 'Shift detail',
      chip: confirmed ? const ZChip('Confirmed', kind: ChipKind.success) : const ZChip('Awaiting confirmation'),
      tab: NavTab.schedule,
      children: [
        const KeyValueCard([
          ('Site / post', 'Polo Park • West entrance'),
          ('Local schedule', '13 Oct • 07:00–15:00 CDT'),
          ('Break', '30 min • unpaid'),
          ('Supervisor', 'Priya Shah'),
          ('Required kit', 'Uniform • radio • access card'),
          ('Instructions', 'Read post orders v4 before arrival'),
        ]),
        ActionStack(
          primary: confirmed ? 'Shift confirmed' : 'Confirm shift',
          icon: confirmed ? Icons.check_rounded : null,
          onPrimary: confirmed
              ? null
              : () => fakeSubmit(context, label: 'Confirming…', then: () {
                    setState(() => confirmed = true);
                    toast(context, 'Shift confirmed • your supervisor has been notified');
                  }),
          links: [
            ('Post orders reader', () => go(context, '/m53')),
            ('Shift swap', () => go(context, '/m27')),
          ],
        ),
      ],
    );
  }
}

// M24 Open shifts
class OpenShiftsScreen extends StatefulWidget {
  const OpenShiftsScreen({super.key});

  @override
  State<OpenShiftsScreen> createState() => _OpenShiftsScreenState();
}

class _OpenShiftsScreenState extends State<OpenShiftsScreen> {
  int selected = 0;
  static const _shifts = [
    ('Office tower • concierge', '14 Oct • 08:00–16:00 • 8 hours'),
    ('Warehouse • night patrol', '15 Oct • 22:00–06:00 • 8 hours'),
    ('Retail plaza • static post', '16 Oct • 12:00–20:00 • 8 hours'),
  ];

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Scheduling',
      title: 'Open shifts',
      tab: NavTab.schedule,
      children: [
        for (var i = 0; i < _shifts.length; i++)
          ListRowCard(
            title: _shifts[i].$1,
            subtitle: _shifts[i].$2,
            onTap: () => setState(() => selected = i),
            trailing: Icon(selected == i ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: ZC.gold),
          ),
        const Notice('Only shifts matching your licences, skills and approved sites are shown.'),
        PrimaryButton('Request selected shift', onPressed: () {
          fakeSubmit(context, label: 'Sending request…', then: () {
            toast(context, 'Requested: ${_shifts[selected].$1}');
            go(context, '/m80');
          });
        }),
      ],
    );
  }
}

// M25 Availability
class AvailabilityScreen extends StatelessWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Scheduling',
      title: 'Availability',
      tab: NavTab.schedule,
      children: [
        ToggleListCard(items: [
          ToggleItem('Monday–Friday', '06:00–18:00 • available', true),
          ToggleItem('Saturday', '08:00–16:00 • available', true),
          ToggleItem('Sunday', 'Unavailable', false),
          ToggleItem('One-time exception', '20 October • unavailable', true),
        ]),
        const FormCard(title: 'Add exception', fields: [
          ZPickerField('Date', value: '20 October 2026', kind: PickerKind.date),
          ZDropdown('Status', options: ['Unavailable', 'Available • limited hours']),
        ]),
        PrimaryButton('Save availability', onPressed: () => fakeSubmit(context, then: () {
              toast(context, 'Availability saved • scheduling notified');
              Navigator.of(context).maybePop();
            })),
      ],
    );
  }
}

// M26 Time off request
class TimeOffScreen extends StatelessWidget {
  const TimeOffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Scheduling',
      title: 'Time off request',
      tab: NavTab.schedule,
      children: [
        const FormCard(fields: [
          ZDropdown('Type', options: ['Unpaid time off', 'Vacation', 'Sick leave', 'Bereavement']),
          ZPickerField('From', value: '20 October 2026', kind: PickerKind.date),
          ZPickerField('To', value: '21 October 2026', kind: PickerKind.date),
          ZField('Reason', initial: 'Personal appointment'),
          ZPickerField('Attachment', value: 'Optional document'),
        ]),
        PrimaryButton('Submit request', onPressed: () => fakeSubmit(context, then: () {
              toast(context, 'REQ-112 submitted for approval');
              go(context, '/m80');
            })),
      ],
    );
  }
}

// M27 Shift swap
class ShiftSwapScreen extends StatelessWidget {
  const ShiftSwapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Scheduling',
      title: 'Shift swap',
      tab: NavTab.schedule,
      children: [
        const FormCard(fields: [
          ZDropdown('My shift', options: ['14 Oct • Office tower • 08:00–16:00', '13 Oct • Polo Park • 07:00–15:00']),
          ZDropdown('Qualified colleague', options: ['Jordan Lee', 'Taylor Reed', 'Sam Okafor']),
          ZDropdown('Swap for', options: ['15 Oct • Warehouse • 07:00–15:00', '16 Oct • Polo Park • 07:00–15:00']),
          ZField('Reason', initial: 'Family commitment'),
        ]),
        const Notice('Both schedules change only after manager approval.'),
        PrimaryButton('Send swap request', onPressed: () => fakeSubmit(context, then: () {
              toast(context, 'Swap request sent to Jordan Lee & scheduling');
              go(context, '/m80');
            })),
      ],
    );
  }
}

// M52 Post orders & policies
class PostOrdersScreen extends StatelessWidget {
  const PostOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    String status(String doc, String pending) => state.acknowledged.contains(doc) ? 'Acknowledged • today' : pending;
    return ZScaffold(
      eyebrow: 'Work orders',
      title: 'Post orders & policies',
      tab: NavTab.home,
      children: [
        ListRowCard(
          title: 'Polo Park post orders • v4',
          subtitle: status('Polo Park post orders • v4', 'Acknowledgement required'),
          subtitleColor: state.acknowledged.contains('Polo Park post orders • v4') ? ZC.successText : ZC.goldLight,
          onTap: () => go(context, '/m53'),
        ),
        ListRowCard(title: 'Emergency escalation plan', subtitle: state.acknowledged.contains('Emergency escalation plan') ? 'Acknowledged • 11 Oct' : 'Acknowledgement required', onTap: () => go(context, '/m53')),
        ListRowCard(title: 'Company lone-worker policy', subtitle: status('Company lone-worker policy', 'Updated • action required'), subtitleColor: ZC.goldLight, onTap: () => go(context, '/m53')),
        ListRowCard(title: 'Floor plans & site documents', subtitle: 'Restricted to assigned site', leading: const Icon(Icons.lock_outline_rounded, color: ZC.muted, size: 18), onTap: () => toast(context, 'Opens site documents (restricted)')),
        PrimaryButton('Read post orders', onPressed: () => go(context, '/m53')),
      ],
    );
  }
}

// M53 Post orders reader
class PostOrdersReaderScreen extends StatelessWidget {
  const PostOrdersReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    const doc = 'Polo Park post orders • v4';
    final done = state.acknowledged.contains(doc);
    Widget section(String title, String body) => ZCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: ZT.cardTitle),
            const SizedBox(height: 8),
            Text(body, style: ZT.body),
          ]),
        );
    return ZScaffold(
      eyebrow: 'Work orders',
      title: 'Post orders reader',
      subtitle: 'Polo Park • Version 4',
      tab: NavTab.home,
      children: [
        section('Start-of-shift checks', 'Confirm west entrance, radio channel 2 and key custody. Review incoming passdown before patrol.'),
        section('Escalation procedure', 'Report site safety issues to the supervisor. Contact dispatch for urgent assistance. Use panic only for an immediate threat.'),
        section('Access control', 'All contractors sign in at the west entrance. Issue visitor badges only after host confirmation. Deliveries use the north gate between 07:00 and 20:00.'),
        PrimaryButton(done ? 'Version 4 acknowledged' : 'Acknowledge version 4', icon: done ? Icons.check_rounded : Icons.edit_note_rounded, onPressed: done
            ? null
            : () => fakeSubmit(context, label: 'Recording acknowledgement…', then: () {
                  DemoScope.read(context).acknowledge(doc);
                  toast(context, 'Acknowledged • time-stamped to your record');
                })),
      ],
    );
  }
}

// M54 Passdown log
class PassdownLogScreen extends StatelessWidget {
  const PassdownLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    return ZScaffold(
      eyebrow: 'Work orders',
      title: 'Passdown log',
      tab: NavTab.home,
      children: [
        for (final p in state.passdowns)
          ListRowCard(
            title: p.title,
            subtitle: p.subtitle,
            leading: const StatusDot(color: ZC.gold, icon: Icons.swap_horiz_rounded),
            onTap: () => toast(context, p.subtitle),
          ),
        PrimaryButton('Write passdown', icon: Icons.edit_outlined, onPressed: () => go(context, '/m55')),
      ],
    );
  }
}

// M50 Tasks & checklists
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Work orders',
      title: 'Tasks & checklists',
      tab: NavTab.home,
      children: [
        ListRowCard(title: 'Opening safety checks', subtitle: 'Completed • 06:52', subtitleColor: ZC.successText, leading: const StatusDot(color: ZC.successText, icon: Icons.check_rounded), onTap: () => toast(context, 'Completed at 06:52 by Alex Morgan')),
        ListRowCard(title: 'Check temporary gate repair', subtitle: 'High priority • due 10:00', subtitleColor: ZC.dangerText, leading: const StatusDot(color: ZC.dangerText, icon: Icons.priority_high_rounded), onTap: () => go(context, '/m51')),
        ListRowCard(title: 'Lobby visitor log review', subtitle: 'Due 11:00', leading: const StatusDot(color: ZC.muted2, icon: Icons.schedule_rounded), onTap: () => go(context, '/m68')),
        PrimaryButton('Open task checklist', onPressed: () => go(context, '/m51')),
      ],
    );
  }
}

// M51 Task detail
class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final items = [
    CheckItem('Inspect gate latch', 'Check temporary repair is secure', true),
    CheckItem('Capture condition photo', 'Required before completion', false),
    CheckItem('Notify maintenance', 'Add reference number', false),
  ];

  @override
  Widget build(BuildContext context) {
    final allDone = items.every((i) => i.checked);
    final count = items.where((i) => i.checked).length;
    return ZScaffold(
      eyebrow: 'Work orders',
      title: 'Task detail',
      subtitle: 'Check temporary gate repair',
      chip: ZChip('$count of ${items.length} steps', kind: allDone ? ChipKind.success : ChipKind.gold),
      tab: NavTab.home,
      children: [
        ChecklistCard(items: items, onChanged: () => setState(() {})),
        const FormCard(title: null, fields: [
          SizedBox(height: 2),
          ZPickerField('Condition photo', value: 'Tap to capture', icon: Icons.photo_camera_outlined, attachedName: 'Gate-repair.jpg attached'),
          ZField('Maintenance reference', hint: 'e.g. MT-204'),
        ]),
        ActionStack(
          primary: 'Complete task',
          onPrimary: allDone
              ? () => fakeSubmit(context, then: () {
                    toast(context, 'Task completed • logged at ${hhmm(DateTime.now())}');
                    Navigator.of(context).maybePop();
                  })
              : null,
          links: [('Incident report', () => go(context, '/m45'))],
        ),
      ],
    );
  }
}

// M55 Create passdown
class CreatePassdownScreen extends StatefulWidget {
  const CreatePassdownScreen({super.key});

  @override
  State<CreatePassdownScreen> createState() => _CreatePassdownScreenState();
}

class _CreatePassdownScreenState extends State<CreatePassdownScreen> {
  final msg = TextEditingController(text: 'North gate temporarily secured. Recheck every patrol.');

  @override
  void dispose() {
    msg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Work orders',
      title: 'Create passdown',
      tab: NavTab.home,
      children: [
        FormCard(fields: [
          const ZDropdown('Site / post', options: ['Polo Park • West entrance', 'Polo Park • North gate']),
          const ZDropdown('Priority', options: ['Attention required', 'Information', 'Urgent']),
          ZField('Message', controller: msg, maxLines: 4),
          const ZPickerField('Attachment', value: 'Gate-repair.jpg'),
        ]),
        PrimaryButton('Save handover note', onPressed: () => fakeSubmit(context, then: () {
              DemoScope.read(context).addPassdown(msg.text.trim().isEmpty ? 'Handover note' : msg.text.trim());
              toast(context, 'Passdown saved for the next shift');
              Navigator.of(context).maybePop();
            })),
      ],
    );
  }
}
