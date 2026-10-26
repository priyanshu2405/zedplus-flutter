import 'package:flutter/material.dart';

import '../core/demo_state.dart';
import '../core/theme.dart';
import '../widgets/visuals.dart';
import '../widgets/z_widgets.dart';

// M71 My equipment
class MyEquipmentScreen extends StatelessWidget {
  const MyEquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Equipment',
      title: 'My equipment',
      tab: NavTab.profile,
      children: [
        ListRowCard(title: 'Radio • R-018', subtitle: 'Good • issued 1 Oct • due 31 Oct', leading: const StatusDot(color: ZC.gold, icon: Icons.settings_input_antenna_rounded), onTap: () => go(context, '/m74')),
        ListRowCard(title: 'Uniform shirt • size M', subtitle: '2 units • issued 1 Oct', leading: const StatusDot(color: ZC.gold, icon: Icons.checkroom_rounded), onTap: () => go(context, '/m75')),
        ListRowCard(title: 'Access card • K-004', subtitle: 'Polo Park • return each shift', leading: const StatusDot(color: ZC.gold, icon: Icons.credit_card_rounded), onTap: () => go(context, '/m77')),
        ActionStack(
          primary: 'Browse equipment',
          icon: Icons.storefront_outlined,
          onPrimary: () => go(context, '/m72'),
          links: [
            ('Lost or damaged item', () => go(context, '/m74')),
            ('Equipment return', () => go(context, '/m75')),
            ('Equipment receipt', () => go(context, '/m76')),
            ('Site keys & assets', () => go(context, '/m77')),
          ],
        ),
      ],
    );
  }
}

// M72 Equipment catalogue
class EquipmentCatalogueScreen extends StatefulWidget {
  const EquipmentCatalogueScreen({super.key});

  @override
  State<EquipmentCatalogueScreen> createState() => _EquipmentCatalogueScreenState();
}

class _EquipmentCatalogueScreenState extends State<EquipmentCatalogueScreen> {
  int selected = 0;
  static const _items = [
    ('Softshell jacket', 'Sizes S–XXL • in stock', Icons.dry_cleaning_outlined),
    ('Two-way radio', 'Serial tracked • limited stock', Icons.settings_input_antenna_rounded),
    ('High-visibility vest', 'Sizes M–XL • in stock', Icons.health_and_safety_outlined),
    ('Flashlight', 'Standard issue • in stock', Icons.flashlight_on_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Equipment',
      title: 'Equipment catalogue',
      tab: NavTab.profile,
      children: [
        for (var i = 0; i < _items.length; i++)
          ListRowCard(
            title: _items[i].$1,
            subtitle: _items[i].$2,
            subtitleColor: _items[i].$2.contains('limited') ? ZC.goldLight : null,
            leading: StatusDot(color: selected == i ? ZC.gold : ZC.muted2, icon: _items[i].$3),
            trailing: Icon(selected == i ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: ZC.gold),
            onTap: () => setState(() => selected = i),
          ),
        PrimaryButton('Request ${_items[selected].$1.toLowerCase()}', onPressed: () => go(context, '/m73')),
      ],
    );
  }
}

// M73 Equipment request
class EquipmentRequestScreen extends StatelessWidget {
  const EquipmentRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Equipment',
      title: 'Equipment request',
      tab: NavTab.profile,
      children: [
        const FormCard(fields: [
          ZDropdown('Item', options: ['Softshell jacket', 'Two-way radio', 'High-visibility vest', 'Flashlight']),
          ZDropdown('Size / quantity', options: ['M • 1', 'L • 1', 'S • 1', 'XL • 1', 'M • 2']),
          ZDropdown('Site', options: ['Polo Park', 'Warehouse', 'Office tower']),
          ZField('Reason', initial: 'Replacement for worn jacket'),
        ]),
        const Notice('Supervisor → Operations Manager. Owner approval applies above the configured limit.'),
        PrimaryButton('Submit equipment request', onPressed: () => fakeSubmit(context, then: () {
              toast(context, 'REQ-104 submitted');
              go(context, '/m81');
            })),
      ],
    );
  }
}

// M76 Equipment receipt
class EquipmentReceiptScreen extends StatefulWidget {
  const EquipmentReceiptScreen({super.key});

  @override
  State<EquipmentReceiptScreen> createState() => _EquipmentReceiptScreenState();
}

class _EquipmentReceiptScreenState extends State<EquipmentReceiptScreen> {
  bool signed = false;

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    return ZScaffold(
      eyebrow: 'Equipment',
      title: 'Equipment receipt',
      subtitle: 'Request #REQ-104 • ready for issue',
      tab: NavTab.profile,
      children: [
        const KeyValueCard([('Items received', '1 softshell jacket • size M')]),
        ZCard(child: SignaturePad(signer: state.userName, onChanged: (v) => setState(() => signed = v))),
        const Notice('Issued by Dana Wells • Winnipeg store. Confirm quantity and condition before signing.'),
        PrimaryButton('Confirm receipt', onPressed: signed
            ? () => fakeSubmit(context, then: () {
                  toast(context, 'Receipt signed • added to My equipment');
                  goFromHome(context, '/m71');
                })
            : null),
      ],
    );
  }
}

// M77 Site keys & assets
class SiteKeysScreen extends StatelessWidget {
  const SiteKeysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Equipment',
      title: 'Site keys & assets',
      tab: NavTab.profile,
      children: [
        ListRowCard(title: 'K-004 • West entrance card', subtitle: 'Held by Alex • due at shift end', subtitleColor: ZC.goldLight, leading: const StatusDot(color: ZC.gold, icon: Icons.credit_card_rounded), onTap: () => go(context, '/m78')),
        ListRowCard(title: 'K-012 • Service gate key', subtitle: 'Available • stored in secure cabinet', subtitleColor: ZC.successText, leading: const StatusDot(color: ZC.successText, icon: Icons.key_outlined), onTap: () => go(context, '/m78')),
        ListRowCard(title: 'R-023 • Post radio', subtitle: 'Held by Jordan • checked out 06:50', leading: const StatusDot(color: ZC.muted2, icon: Icons.settings_input_antenna_rounded), onTap: () => go(context, '/m78')),
        ActionStack(
          primary: 'Scan asset tag',
          icon: Icons.qr_code_scanner_rounded,
          onPrimary: () => go(context, '/m78'),
          links: [('Stock count', () => go(context, '/m79'))],
        ),
      ],
    );
  }
}

// M78 Asset scan
class AssetScanScreen extends StatefulWidget {
  const AssetScanScreen({super.key});

  @override
  State<AssetScanScreen> createState() => _AssetScanScreenState();
}

class _AssetScanScreenState extends State<AssetScanScreen> {
  int method = 1;
  bool checkedIn = false;

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Equipment',
      title: 'Asset scan',
      subtitle: 'Key K-004 • West entrance',
      chip: checkedIn ? const ZChip('Checked in • cabinet', kind: ChipKind.success) : const ZChip('Held by Alex'),
      tab: NavTab.profile,
      children: [
        ScannerView(key: ValueKey(method), method: method),
        SegmentedTabs(options: const ['NFC', 'QR / barcode', 'GPS'], selected: method, onChanged: (i) => setState(() => method = i)),
        const Notice('Scan the QR label to check the key in or out. Custody is time-stamped.'),
        PrimaryButton(checkedIn ? 'Check asset out' : 'Check asset in', icon: Icons.swap_vert_rounded, onPressed: () => fakeSubmit(context, label: 'Reading tag…', then: () {
              setState(() => checkedIn = !checkedIn);
              toast(context, checkedIn ? 'K-004 checked in at ${hhmm(DateTime.now())}' : 'K-004 checked out to Alex Morgan');
            })),
      ],
    );
  }
}

// M79 Stock count
class StockCountScreen extends StatefulWidget {
  const StockCountScreen({super.key});

  @override
  State<StockCountScreen> createState() => _StockCountScreenState();
}

class _StockCountScreenState extends State<StockCountScreen> {
  int counted = 11;
  static const system = 12;

  @override
  Widget build(BuildContext context) {
    final diff = counted - system;
    return ZScaffold(
      eyebrow: 'Equipment',
      title: 'Stock count',
      tab: NavTab.profile,
      children: [
        const FormCard(fields: [
          ZDropdown('Location', options: ['Winnipeg branch store', 'Polo Park site cabinet']),
          ZDropdown('Item / size', options: ['Softshell jacket • M', 'Softshell jacket • L', 'High-visibility vest • M']),
        ]),
        ZCard(
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('SYSTEM QUANTITY', style: ZT.caps),
                const SizedBox(height: 6),
                const Text('$system', style: ZT.statValue),
                const SizedBox(height: 14),
                const Text('COUNTED QUANTITY', style: ZT.caps),
                const SizedBox(height: 6),
                Text('$counted', style: ZT.statValue.copyWith(color: diff == 0 ? ZC.successText : ZC.goldLight)),
              ]),
            ),
            Column(children: [
              IconButton.filledTonal(onPressed: () => setState(() => counted++), icon: const Icon(Icons.add_rounded)),
              const SizedBox(height: 8),
              IconButton.filledTonal(onPressed: () => setState(() => counted = counted > 0 ? counted - 1 : 0), icon: const Icon(Icons.remove_rounded)),
            ]),
          ]),
        ),
        if (diff != 0) const FormCard(title: null, fields: [SizedBox(height: 2), ZField('Variance reason', initial: 'One damaged item awaiting write-off')]),
        Notice(diff == 0 ? 'Count matches the system. No approval needed.' : 'Difference of ${diff > 0 ? '+' : '−'}${diff.abs()} is submitted for manager approval.'),
        PrimaryButton(diff == 0 ? 'Submit count' : 'Submit count variance', onPressed: () => fakeSubmit(context, then: () {
              toast(context, diff == 0 ? 'Stock count recorded' : 'Variance sent for manager approval');
              Navigator.of(context).maybePop();
            })),
      ],
    );
  }
}

// M74 Lost or damaged item
class LostDamagedScreen extends StatelessWidget {
  const LostDamagedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Equipment',
      title: 'Lost or damaged item',
      tab: NavTab.profile,
      children: [
        const FormCard(fields: [
          ZDropdown('Item / serial', options: ['Radio • R-018', 'Uniform shirt • size M', 'Access card • K-004']),
          ZDropdown('Issue', options: ['Damaged', 'Lost', 'Stolen']),
          ZField('Date / place', initial: '12 Oct • Polo Park'),
          ZField('Description', initial: 'Battery clip broken during patrol.', maxLines: 3),
          ZPickerField('Evidence', value: 'Radio-damage.jpg', icon: Icons.photo_camera_outlined),
          ZDropdown('Replacement requested', options: ['Yes', 'No']),
        ]),
        PrimaryButton('Submit damage report', onPressed: () => fakeSubmit(context, then: () {
              toast(context, 'Damage report submitted • replacement requested');
              go(context, '/m80');
            })),
      ],
    );
  }
}

// M75 Equipment return
class EquipmentReturnScreen extends StatelessWidget {
  const EquipmentReturnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Equipment',
      title: 'Equipment return',
      tab: NavTab.profile,
      children: [
        const FormCard(fields: [
          ZDropdown('Item', options: ['Softshell jacket • size M', 'Uniform shirt • size M', 'Radio • R-018']),
          ZDropdown('Condition', options: ['Worn • usable', 'Like new', 'Damaged']),
          ZDropdown('Reason', options: ['Size exchange', 'End of assignment', 'Replacement received']),
          ZDropdown('Return location', options: ['Winnipeg branch store', 'Polo Park site cabinet']),
          ZPickerField('Evidence', value: 'Condition photo attached', icon: Icons.photo_camera_outlined),
        ]),
        const Notice('Stock updates after the storekeeper confirms receipt and condition.'),
        PrimaryButton('Start return', onPressed: () => fakeSubmit(context, then: () {
              toast(context, 'Return started • bring item to Winnipeg store');
              Navigator.of(context).maybePop();
            })),
      ],
    );
  }
}

// M80 My requests
class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Approvals',
      title: 'My requests',
      tab: NavTab.profile,
      children: [
        ListRowCard(title: 'REQ-104 • Jacket', subtitle: 'Ready for pickup • Winnipeg store', subtitleColor: ZC.successText, leading: const StatusDot(color: ZC.successText, icon: Icons.inventory_2_outlined), onTap: () => go(context, '/m81')),
        ListRowCard(title: 'REQ-108 • Punch correction', subtitle: 'Pending payroll • step 2', subtitleColor: ZC.goldLight, leading: const StatusDot(color: ZC.gold, icon: Icons.hourglass_top_rounded), onTap: () => go(context, '/m81')),
        ListRowCard(title: 'REQ-112 • Time off', subtitle: 'More information needed', subtitleColor: ZC.goldLight, leading: const StatusDot(color: ZC.gold, icon: Icons.info_outline_rounded), onTap: () => go(context, '/m26')),
        ListRowCard(title: 'REQ-089 • Shift swap', subtitle: 'Rejected • scheduling conflict', subtitleColor: ZC.dangerText, leading: const StatusDot(color: ZC.dangerText, icon: Icons.close_rounded), onTap: () => toast(context, 'Rejected by Priya Shah • scheduling conflict')),
        PrimaryButton('View request trail', onPressed: () => go(context, '/m81')),
      ],
    );
  }
}

// M81 Request tracking
class RequestTrackingScreen extends StatelessWidget {
  const RequestTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Approvals',
      title: 'Request tracking',
      subtitle: 'REQ-104 • Softshell jacket',
      tab: NavTab.profile,
      children: [
        const TimelineCard([
          ('Submitted • 07:22', 'Alex Morgan • jacket request'),
          ('Supervisor approved • 07:35', 'Priya Shah • quantity 1'),
          ('Manager approved • 08:10', 'Morgan Reid • within limit'),
          ('Ready for pickup • 09:05', 'Dana Wells • Winnipeg store'),
          ('Collected', 'Sign the receipt at the store'),
        ], doneCount: 4),
        PrimaryButton('Confirm collection', onPressed: () => go(context, '/m76')),
      ],
    );
  }
}

// M82 Approvals inbox
class ApprovalsInboxScreen extends StatelessWidget {
  const ApprovalsInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    return ZScaffold(
      eyebrow: 'Approvals',
      title: 'Approvals inbox',
      chip: ZChip('${state.approvals.length} pending', kind: state.approvals.isEmpty ? ChipKind.success : ChipKind.gold),
      tab: NavTab.home,
      children: [
        if (state.approvals.isEmpty)
          const SuccessPanel(title: 'Inbox clear', subtitle: 'All requests have been actioned'),
        for (final a in state.approvals)
          ListRowCard(
            title: '${a.id} • ${a.person}',
            subtitle: a.type,
            leading: const StatusDot(color: ZC.gold, icon: Icons.pending_actions_rounded),
            onTap: () => Navigator.of(context).pushNamed('/m83', arguments: a.id),
          ),
        ActionStack(
          primary: 'Review selected request',
          onPrimary: state.approvals.isEmpty ? null : () => Navigator.of(context).pushNamed('/m83', arguments: state.approvals.first.id),
          links: [
            ('Delegate approvals', () => go(context, '/m85')),
            ('Approval history', () => go(context, '/m86')),
          ],
        ),
      ],
    );
  }
}

const _approvalDetails = <String, List<(String, String)>>{
  'REQ-108': [
    ('Requester', 'Alex Morgan'),
    ('Type', 'Punch correction'),
    ('Original', '07:12 • outside boundary'),
    ('Requested', '07:02 • alternate gate'),
    ('Reason', 'Main gate locked; evidence attached'),
    ('Next step', 'Payroll review'),
  ],
  'REQ-114': [
    ('Requester', 'Jordan Lee'),
    ('Type', 'Equipment replacement'),
    ('Item', 'Two-way radio • R-023'),
    ('Cost', '\$85 • within your limit'),
    ('Reason', 'Battery no longer holds charge'),
    ('Next step', 'Store issue'),
  ],
  'REQ-116': [
    ('Requester', 'Taylor Reed'),
    ('Type', 'Mileage claim'),
    ('Route', 'Winnipeg East • 11 October'),
    ('Distance', '42.6 km • GPS verified'),
    ('Reason', 'Completed all assigned stops'),
    ('Next step', 'Payroll'),
  ],
};

// M83 Approval detail
class ApprovalDetailScreen extends StatelessWidget {
  const ApprovalDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final id = arg is String ? arg : 'REQ-108';
    final rows = _approvalDetails[id] ?? _approvalDetails['REQ-108']!;
    final pending = DemoScope.of(context).approvals.any((a) => a.id == id);
    return ZScaffold(
      eyebrow: 'Approvals',
      title: 'Approval detail',
      chip: ZChip(pending ? '$id • pending' : '$id • decided', kind: pending ? ChipKind.gold : ChipKind.success),
      tab: NavTab.home,
      children: [
        KeyValueCard(rows),
        const Notice('You cannot approve your own request. All decisions remain in the audit trail.'),
        ActionStack(
          primary: 'Approve to next step',
          icon: Icons.check_rounded,
          onPrimary: pending
              ? () => fakeSubmit(context, label: 'Recording decision…', then: () {
                    DemoScope.read(context).decide(id, 'Approved');
                    toast(context, '$id approved • moved to next step');
                    Navigator.of(context).maybePop();
                  })
              : null,
          links: [if (pending) ('Reject or return request', () => Navigator.of(context).pushNamed('/m84', arguments: id))],
        ),
      ],
    );
  }
}

// M84 Reject or return request
class RejectReturnScreen extends StatefulWidget {
  const RejectReturnScreen({super.key});

  @override
  State<RejectReturnScreen> createState() => _RejectReturnScreenState();
}

class _RejectReturnScreenState extends State<RejectReturnScreen> {
  String decision = 'Return for more information';

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final id = arg is String ? arg : 'REQ-108';
    return ZScaffold(
      eyebrow: 'Approvals',
      title: 'Reject or return request',
      subtitle: id,
      tab: NavTab.home,
      children: [
        FormCard(fields: [
          ZDropdown('Decision', options: const ['Return for more information', 'Reject'], onChanged: (v) => setState(() => decision = v)),
          const ZField('Required reason', initial: 'Please attach the alternate gate photo.', maxLines: 3),
        ]),
        PrimaryButton('Send decision', danger: decision == 'Reject', onPressed: () => fakeSubmit(context, then: () {
              DemoScope.read(context).decide(id, decision == 'Reject' ? 'Rejected' : 'Returned');
              toast(context, '$id ${decision == 'Reject' ? 'rejected' : 'returned to requester'}');
              Navigator.of(context).popUntil((r) => r.settings.name == '/m82' || r.isFirst);
            })),
      ],
    );
  }
}

// M85 Delegate approvals
class DelegateApprovalsScreen extends StatelessWidget {
  const DelegateApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Approvals',
      title: 'Delegate approvals',
      tab: NavTab.home,
      children: [
        const FormCard(fields: [
          ZDropdown('Delegate', options: ['Morgan Reid • Operations Manager', 'Dana Wells • Store Supervisor']),
          ZPickerField('Start', value: '20 October 2026', kind: PickerKind.date),
          ZPickerField('End', value: '23 October 2026', kind: PickerKind.date),
          ZDropdown('Scope', options: ['Assigned sites and approval limits', 'Equipment only', 'Attendance only']),
        ]),
        const Notice('Decisions record both the original approver and the delegate.'),
        PrimaryButton('Save delegation', onPressed: () => fakeSubmit(context, then: () {
              toast(context, 'Delegation saved • Morgan Reid notified');
              Navigator.of(context).maybePop();
            })),
      ],
    );
  }
}

// M86 Approval history
class ApprovalHistoryScreen extends StatelessWidget {
  const ApprovalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    return ZScaffold(
      eyebrow: 'Approvals',
      title: 'Approval history',
      tab: NavTab.home,
      children: [
        for (final h in state.approvalHistory)
          ListRowCard(
            title: h.title,
            subtitle: h.subtitle,
            subtitleColor: h.subtitle.startsWith('Rejected') ? ZC.dangerText : h.subtitle.startsWith('Returned') ? ZC.goldLight : ZC.successText,
            leading: StatusDot(
              color: h.subtitle.startsWith('Rejected') ? ZC.dangerText : h.subtitle.startsWith('Returned') ? ZC.gold : ZC.successText,
              icon: h.subtitle.startsWith('Rejected') ? Icons.close_rounded : h.subtitle.startsWith('Returned') ? Icons.undo_rounded : Icons.check_rounded,
            ),
            onTap: () => toast(context, 'Full audit trail available in the web console'),
          ),
        PrimaryButton('View approval trail', onPressed: () => go(context, '/m81')),
      ],
    );
  }
}
