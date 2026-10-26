import 'package:flutter/material.dart';

import '../core/demo_state.dart';
import '../core/theme.dart';
import '../routes.dart';
import '../widgets/z_widgets.dart';

/// Presenter tool: every design screen, grouped by workflow, one tap away.
/// Open it from the Welcome screen or by long-pressing the Zed Plus logo.
class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final q = query.toLowerCase();
    final groups = screenGroups
        .map((g) => ScreenGroup(g.title, g.flow, g.screens.where((s) => q.isEmpty || s.title.toLowerCase().contains(q) || s.code.toLowerCase().contains(q)).toList()))
        .where((g) => g.screens.isNotEmpty)
        .toList();

    return ZScaffold(
      eyebrow: 'Demo index',
      title: 'All 91 screens',
      subtitle: 'Tap any screen to open it. Long-press the logo anywhere to return here.',
      crumb: null,
      showActions: false,
      showNav: false,
      gap: 10,
      children: [
        ZCard(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DEMO ROLE', style: ZT.caps.copyWith(color: ZC.gold)),
            const SizedBox(height: 10),
            SegmentedTabs(
              options: const ['Guard • Alex', 'Supervisor • Priya'],
              selected: state.role == Role.guard ? 0 : 1,
              onChanged: (i) => DemoScope.read(context).setRole(i == 0 ? Role.guard : Role.supervisor),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(state.homeRoute, (r) => false),
                  style: OutlinedButton.styleFrom(foregroundColor: ZC.goldLight, side: const BorderSide(color: ZC.fieldBorder)),
                  icon: const Icon(Icons.home_rounded, size: 18),
                  label: const Text('Home', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/m01', (r) => false),
                  style: OutlinedButton.styleFrom(foregroundColor: ZC.goldLight, side: const BorderSide(color: ZC.fieldBorder)),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Welcome', style: TextStyle(fontSize: 12)),
                ),
              ),
            ]),
          ]),
        ),
        TextField(
          onChanged: (v) => setState(() => query = v),
          style: const TextStyle(color: ZC.text, fontSize: 13),
          decoration: zInputDecoration(hint: 'Search screens (e.g. “patrol” or “M39”)', suffix: const Icon(Icons.search_rounded, color: ZC.muted)),
        ),
        for (final g in groups) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 2),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g.title.toUpperCase(), style: ZT.eyebrow.copyWith(fontSize: 10.5, letterSpacing: 1.4)),
              const SizedBox(height: 4),
              Text(g.flow, style: ZT.rowSub),
            ]),
          ),
          for (final s in g.screens)
            ListRowCard(
              title: s.title,
              subtitle: '${s.number.toString().padLeft(3, '0')} • ${s.code}',
              leading: Container(
                width: 40,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ZC.field, borderRadius: BorderRadius.circular(6), border: Border.all(color: ZC.fieldBorder)),
                child: Text(s.code, style: const TextStyle(color: ZC.goldLight, fontSize: 10.5, fontWeight: FontWeight.w700)),
              ),
              onTap: () => go(context, s.route),
            ),
        ],
      ],
    );
  }
}
