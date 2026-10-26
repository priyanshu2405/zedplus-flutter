import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/demo_state.dart';
import '../core/theme.dart';

const String kSiteCrumb = 'MANITOBA   /   POLO PARK • ACTIVE SITE';
const String kRouteCrumb = 'MANITOBA   /   ASSIGNED ROUTE';

enum NavTab { home, schedule, patrol, reports, profile }

// ---------------------------------------------------------------------------
// Navigation helpers
// ---------------------------------------------------------------------------

void go(BuildContext context, String route) => Navigator.of(context).pushNamed(route);

void goReplace(BuildContext context, String route) => Navigator.of(context).pushReplacementNamed(route);

/// Clears the stack back to the role's home and then opens [route].
void goFromHome(BuildContext context, String route) {
  final home = DemoScope.read(context).homeRoute;
  final nav = Navigator.of(context);
  nav.pushNamedAndRemoveUntil(home, (r) => false);
  if (route != home) nav.pushNamed(route);
}

void goTab(BuildContext context, NavTab tab) {
  final state = DemoScope.read(context);
  switch (tab) {
    case NavTab.home:
      goFromHome(context, state.homeRoute);
    case NavTab.schedule:
      goFromHome(context, state.role == Role.guard ? '/m22' : '/m28');
    case NavTab.patrol:
      goFromHome(context, '/m37');
    case NavTab.reports:
      goFromHome(context, '/m43');
    case NavTab.profile:
      goFromHome(context, '/m88');
  }
}

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 1800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: ZC.surfaceBorder)),
    ));
}

/// Shows a short "working…" overlay, then runs [then]. Makes submits feel real.
Future<void> fakeSubmit(BuildContext context, {String label = 'Saving securely…', required VoidCallback then, int ms = 900}) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0xAA000000),
    builder: (_) => PopScope(
      canPop: false,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
          decoration: BoxDecoration(color: ZC.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: ZC.surfaceBorder)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.6, color: ZC.gold)),
            const SizedBox(height: 14),
            Text(label, style: const TextStyle(color: ZC.text, fontSize: 13, decoration: TextDecoration.none, fontFamily: 'DejaVuSans', fontWeight: FontWeight.w400)),
          ]),
        ),
      ),
      ),
    ),
  );
  await Future<void>.delayed(Duration(milliseconds: ms));
  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop();
  then();
}

Future<bool> confirmDialog(BuildContext context, {required String title, required String message, String ok = 'Confirm', bool danger = false}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: ZC.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: ZC.surfaceBorder)),
      title: Text(title, style: const TextStyle(color: ZC.text, fontSize: 17, fontWeight: FontWeight.w700)),
      content: Text(message, style: ZT.body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel', style: TextStyle(color: ZC.muted2))),
        TextButton(onPressed: () => Navigator.pop(c, true), child: Text(ok, style: TextStyle(color: danger ? ZC.dangerText : ZC.gold, fontWeight: FontWeight.w700))),
      ],
    ),
  );
  return r ?? false;
}

// ---------------------------------------------------------------------------
// Scaffold
// ---------------------------------------------------------------------------

class ZScaffold extends StatelessWidget {
  const ZScaffold({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.chip,
    this.crumb = kSiteCrumb,
    this.showActions = true,
    this.tab,
    this.showNav = true,
    required this.children,
    this.footer,
    this.gap = 12,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? chip;
  final String? crumb;
  final bool showActions;
  final NavTab? tab;
  final bool showNav;
  final List<Widget> children;
  final Widget? footer;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[];
    if (crumb != null) spaced.add(Breadcrumb(crumb!));
    spaced.addAll(children);
    final items = <Widget>[];
    for (var i = 0; i < spaced.length; i++) {
      if (i > 0) items.add(SizedBox(height: gap));
      items.add(spaced[i]);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: ZC.bg,
        body: Column(
          children: [
            ZHeader(eyebrow: eyebrow, title: title, subtitle: subtitle, chip: chip, showActions: showActions),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                children: items,
              ),
            ),
            if (footer != null)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                decoration: const BoxDecoration(color: ZC.bg, border: Border(top: BorderSide(color: ZC.surfaceBorder))),
                child: SafeArea(top: false, bottom: !showNav, child: footer!),
              ),
            if (showNav) ZBottomNav(active: tab),
          ],
        ),
      ),
    );
  }
}

class ZHeader extends StatelessWidget {
  const ZHeader({super.key, required this.eyebrow, required this.title, this.subtitle, this.chip, this.showActions = true});
  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? chip;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final canPop = Navigator.of(context).canPop();
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: ZC.navy, border: Border(bottom: BorderSide(color: ZC.surfaceBorder))),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (canPop) ...[
                    InkResponse(
                      onTap: () => Navigator.of(context).maybePop(),
                      radius: 22,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.chevron_left_rounded, color: ZC.textSoft, size: 30),
                      ),
                    ),
                  ],
                  GestureDetector(
                    onLongPress: () => go(context, '/directory'),
                    child: const BrandMark(),
                  ),
                  const Spacer(),
                  if (showActions) ...[
                    GestureDetector(
                      onTap: () => go(context, '/m61'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(color: ZC.danger, borderRadius: BorderRadius.circular(8), border: Border.all(color: ZC.dangerBorder)),
                        child: const Text('SOS', style: TextStyle(color: ZC.dangerText, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => go(context, '/m87'),
                      child: Stack(clipBehavior: Clip.none, children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: ZC.avatar, shape: BoxShape.circle, border: Border.all(color: ZC.heroBorder)),
                          child: Text(state.initials, style: const TextStyle(color: ZC.goldLight, fontWeight: FontWeight.w700, fontSize: 12.5)),
                        ),
                        if (state.unreadNotifications > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 16,
                              height: 16,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: ZC.gold, shape: BoxShape.circle, border: Border.all(color: ZC.navy, width: 2)),
                              child: Text('${state.unreadNotifications}', style: const TextStyle(color: ZC.navy, fontSize: 8, fontWeight: FontWeight.w700)),
                            ),
                          ),
                      ]),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              Text(eyebrow.toUpperCase(), style: ZT.eyebrow),
              const SizedBox(height: 6),
              Text(title, style: ZT.title),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle!, style: ZT.subtitle),
              ],
              if (chip != null) ...[const SizedBox(height: 10), chip!],
            ],
          ),
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 36});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: ZC.gold, borderRadius: BorderRadius.circular(size * 0.27)),
        child: Text('Z+', style: TextStyle(color: ZC.navy, fontWeight: FontWeight.w700, fontSize: size * 0.44)),
      ),
      const SizedBox(width: 10),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text('ZED PLUS', style: TextStyle(color: ZC.text, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 2)),
        SizedBox(height: 2),
        Text('SECURITY\nSERVICES', style: TextStyle(color: ZC.textSoft, fontWeight: FontWeight.w700, fontSize: 7.5, letterSpacing: 1.6, height: 1.15)),
      ]),
    ]);
  }
}

class ZBottomNav extends StatelessWidget {
  const ZBottomNav({super.key, this.active});
  final NavTab? active;

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final items = <(NavTab, IconData, String)>[
      (NavTab.home, Icons.home_rounded, 'Home'),
      (NavTab.schedule, Icons.calendar_view_month_rounded, state.role == Role.guard ? 'Schedule' : 'Route'),
      (NavTab.patrol, Icons.radar_rounded, 'Patrol'),
      (NavTab.reports, Icons.article_outlined, 'Reports'),
      (NavTab.profile, Icons.person_outline_rounded, 'Profile'),
    ];
    return Container(
      decoration: const BoxDecoration(color: ZC.navy, border: Border(top: BorderSide(color: ZC.surfaceBorder))),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (final it in items)
                Expanded(
                  child: InkWell(
                    onTap: () => goTab(context, it.$1),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(it.$2, size: 22, color: active == it.$1 ? ZC.gold : ZC.muted2),
                      const SizedBox(height: 4),
                      Text(it.$3, style: TextStyle(fontSize: 10, color: active == it.$1 ? ZC.gold : ZC.muted2)),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Breadcrumb extends StatelessWidget {
  const Breadcrumb(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(color: ZC.field, borderRadius: BorderRadius.circular(10), border: Border.all(color: ZC.surfaceBorder)),
      child: Text(text, style: const TextStyle(color: ZC.textSoft, fontSize: 10.5, letterSpacing: 0.3)),
    );
  }
}

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------

enum ChipKind { gold, success, danger, info }

class ZChip extends StatelessWidget {
  const ZChip(this.label, {super.key, this.kind = ChipKind.gold});
  final String label;
  final ChipKind kind;

  @override
  Widget build(BuildContext context) {
    late Color bg, border, fg;
    switch (kind) {
      case ChipKind.gold:
        bg = ZC.warn;
        border = ZC.warnBorder;
        fg = ZC.goldLight;
      case ChipKind.success:
        bg = ZC.success;
        border = ZC.successBorder;
        fg = ZC.successText;
      case ChipKind.danger:
        bg = ZC.danger;
        border = ZC.dangerBorder;
        fg = ZC.dangerText;
      case ChipKind.info:
        bg = ZC.info;
        border = ZC.infoBorder;
        fg = ZC.infoText;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: border)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10.5)),
    );
  }
}

class ZCard extends StatelessWidget {
  const ZCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color = ZC.surface, this.borderColor = ZC.surfaceBorder, this.radius = 16});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: BorderSide(color: borderColor)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.label, this.badge, required this.title, this.subtitle, this.time, this.footer, this.progress, this.onTap});
  final String label;
  final Widget? badge;
  final String title;
  final String? subtitle;
  final String? time;
  final String? footer;
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [ZC.heroTop, ZC.heroBottom], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZC.heroBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(label.toUpperCase(), style: ZT.caps.copyWith(color: ZC.muted2))),
            if (badge != null) badge!,
          ]),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: ZC.text, fontSize: 21, fontWeight: FontWeight.w700)),
          if (subtitle != null) ...[const SizedBox(height: 8), Text(subtitle!, style: const TextStyle(color: ZC.textSoft, fontSize: 12.5))],
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: ZC.fieldBorder, color: ZC.gold),
            ),
          ],
          if (time != null) ...[const SizedBox(height: 12), Text(time!, style: ZT.bigTime)],
          if (footer != null) ...[const SizedBox(height: 12), Text(footer!, style: const TextStyle(color: ZC.muted2, fontSize: 11.5))],
        ]),
      ),
    );
  }
}

class Stat {
  const Stat(this.value, this.label, {this.color});
  final String value;
  final String label;
  final Color? color;
}

class StatGrid extends StatelessWidget {
  const StatGrid(this.stats, {super.key});
  final List<Stat> stats;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < stats.length; i += 2) {
      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _tile(stats[i])),
        const SizedBox(width: 10),
        Expanded(child: i + 1 < stats.length ? _tile(stats[i + 1]) : const SizedBox()),
      ]));
      if (i + 2 < stats.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }

  Widget _tile(Stat s) => ZCard(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        radius: 12,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.value, style: ZT.statValue.copyWith(color: s.color)),
          const SizedBox(height: 6),
          Text(s.label, style: ZT.rowSub),
        ]),
      );
}

class ListRowCard extends StatelessWidget {
  const ListRowCard({super.key, required this.title, this.subtitle, this.onTap, this.leading, this.trailing, this.subtitleColor});
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    return ZCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      radius: 12,
      onTap: onTap,
      child: Row(children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: ZT.rowTitle),
            if (subtitle != null) ...[const SizedBox(height: 5), Text(subtitle!, style: ZT.rowSub.copyWith(color: subtitleColor))],
          ]),
        ),
        trailing ?? const Icon(Icons.chevron_right_rounded, color: ZC.gold, size: 22),
      ]),
    );
  }
}

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.color, this.icon});
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withAlpha(40), border: Border.all(color: color)),
      child: Icon(icon ?? Icons.circle, size: icon == null ? 8 : 16, color: color),
    );
  }
}

class WorkQueueCard extends StatelessWidget {
  const WorkQueueCard({super.key, this.title = 'Work queue', required this.items});
  final String title;
  final List<(String, VoidCallback)> items;

  @override
  Widget build(BuildContext context) {
    return ZCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: ZT.cardTitle),
        const SizedBox(height: 6),
        for (var i = 0; i < items.length; i++) ...[
          InkWell(
            onTap: items[i].$2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Row(children: [
                Expanded(child: Text(items[i].$1, style: const TextStyle(color: ZC.text, fontSize: 13.5))),
                const Icon(Icons.chevron_right_rounded, color: ZC.muted, size: 20),
              ]),
            ),
          ),
          if (i < items.length - 1) const Divider(height: 1, color: ZC.divider),
        ],
      ]),
    );
  }
}

class Notice extends StatelessWidget {
  const Notice(this.text, {super.key, this.danger = false});
  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
      child: Container(
        color: danger ? ZC.danger : ZC.notice,
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(width: 3, color: danger ? ZC.dangerText : ZC.gold),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
                child: Text(text, style: TextStyle(color: danger ? ZC.dangerText : ZC.textSoft, fontSize: 11.5, height: 1.5)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, required this.onPressed, this.icon, this.danger = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        style: FilledButton.styleFrom(
          backgroundColor: danger ? ZC.dangerSolid : ZC.gold,
          foregroundColor: danger ? ZC.text : ZC.navy,
          disabledBackgroundColor: ZC.fieldBorder,
          disabledForegroundColor: ZC.muted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, fontFamily: 'DejaVuSans'),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}

class LinkButton extends StatelessWidget {
  const LinkButton(this.label, {super.key, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(foregroundColor: ZC.goldLight, minimumSize: const Size(0, 40)),
        child: Text(label, style: const TextStyle(fontSize: 12.5)),
      ),
    );
  }
}

/// A primary button followed by optional secondary text links.
class ActionStack extends StatelessWidget {
  const ActionStack({super.key, required this.primary, required this.onPrimary, this.links = const [], this.icon, this.danger = false});
  final String primary;
  final VoidCallback? onPrimary;
  final List<(String, VoidCallback)> links;
  final IconData? icon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      PrimaryButton(primary, onPressed: onPrimary, icon: icon, danger: danger),
      if (links.isNotEmpty) const SizedBox(height: 6),
      for (final l in links) LinkButton(l.$1, onTap: l.$2),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Forms
// ---------------------------------------------------------------------------

class FormCard extends StatelessWidget {
  const FormCard({super.key, this.title = 'Record details', this.subtitle, required this.fields});
  final String? title;
  final String? subtitle;
  final List<Widget> fields;

  @override
  Widget build(BuildContext context) {
    return ZCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null) Text(title!, style: ZT.cardTitle),
        if (subtitle != null) ...[const SizedBox(height: 6), Text(subtitle!, style: ZT.rowSub)],
        if (title != null) const SizedBox(height: 12),
        ...fields,
      ]),
    );
  }
}

InputDecoration zInputDecoration({String? hint, Widget? suffix}) => InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: const TextStyle(color: ZC.muted, fontSize: 12.5),
      filled: true,
      fillColor: ZC.field,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: ZC.fieldBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: ZC.gold, width: 1.4)),
    );

class ZField extends StatelessWidget {
  const ZField(this.label, {super.key, this.initial, this.hint, this.maxLines = 1, this.obscure = false, this.keyboard, this.controller, this.suffix});
  final String label;
  final String? initial;
  final String? hint;
  final int maxLines;
  final bool obscure;
  final TextInputType? keyboard;
  final TextEditingController? controller;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: ZT.label),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initial : null,
          maxLines: obscure ? 1 : maxLines,
          minLines: 1,
          obscureText: obscure,
          keyboardType: keyboard,
          style: const TextStyle(color: ZC.text, fontSize: 12.5),
          decoration: zInputDecoration(hint: hint, suffix: suffix),
        ),
      ]),
    );
  }
}

class ZDropdown extends StatefulWidget {
  const ZDropdown(this.label, {super.key, required this.options, this.initial, this.onChanged});
  final String label;
  final List<String> options;
  final String? initial;
  final ValueChanged<String>? onChanged;

  @override
  State<ZDropdown> createState() => _ZDropdownState();
}

class _ZDropdownState extends State<ZDropdown> {
  late String value = widget.initial ?? widget.options.first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.label, style: ZT.label),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: ZC.field, borderRadius: BorderRadius.circular(8), border: Border.all(color: ZC.fieldBorder)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: ZC.surface,
              iconEnabledColor: ZC.gold,
              style: const TextStyle(color: ZC.text, fontSize: 12.5, fontFamily: 'DejaVuSans'),
              items: [for (final o in widget.options) DropdownMenuItem(value: o, child: Text(o))],
              onChanged: (v) {
                if (v == null) return;
                setState(() => value = v);
                widget.onChanged?.call(v);
              },
            ),
          ),
        ),
      ]),
    );
  }
}

/// Field that looks like an input but opens a picker / fake attachment flow.
class ZPickerField extends StatefulWidget {
  const ZPickerField(this.label, {super.key, required this.value, this.icon = Icons.attach_file_rounded, this.kind = PickerKind.attachment, this.attachedName});
  final String label;
  final String value;
  final IconData icon;
  final PickerKind kind;
  final String? attachedName;

  @override
  State<ZPickerField> createState() => _ZPickerFieldState();
}

enum PickerKind { attachment, date, time }

class _ZPickerFieldState extends State<ZPickerField> {
  late String value = widget.value;

  Future<void> _tap() async {
    switch (widget.kind) {
      case PickerKind.date:
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime(2026, 10, 20),
          firstDate: DateTime(2026, 1, 1),
          lastDate: DateTime(2027, 12, 31),
          builder: (c, child) => Theme(data: Theme.of(c), child: child!),
        );
        if (d != null) setState(() => value = '${d.day} ${_months[d.month - 1]} ${d.year}');
      case PickerKind.time:
        final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 7, minute: 2));
        if (t != null) setState(() => value = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
      case PickerKind.attachment:
        final pick = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: ZC.surface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (c) => SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: ZC.fieldBorder, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 8),
              for (final o in const [
                (Icons.photo_camera_outlined, 'Take photo'),
                (Icons.videocam_outlined, 'Record video'),
                (Icons.mic_none_rounded, 'Voice note'),
                (Icons.photo_library_outlined, 'Choose from library'),
              ])
                ListTile(
                  leading: Icon(o.$1, color: ZC.gold),
                  title: Text(o.$2, style: const TextStyle(color: ZC.text, fontSize: 14)),
                  onTap: () => Navigator.pop(c, o.$2),
                ),
              const SizedBox(height: 8),
            ]),
          ),
        );
        if (pick != null && mounted) {
          setState(() => value = widget.attachedName ?? 'IMG_${DateTime.now().millisecondsSinceEpoch % 10000}.jpg attached');
          toast(context, 'Demo: $pick captured with time & GPS stamp');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.label, style: ZT.label),
        const SizedBox(height: 7),
        InkWell(
          onTap: _tap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(color: ZC.field, borderRadius: BorderRadius.circular(8), border: Border.all(color: ZC.fieldBorder)),
            child: Row(children: [
              Expanded(child: Text(value, style: const TextStyle(color: ZC.text, fontSize: 12.5))),
              Icon(widget.kind == PickerKind.date ? Icons.event_rounded : widget.kind == PickerKind.time ? Icons.schedule_rounded : widget.icon, color: ZC.gold, size: 18),
            ]),
          ),
        ),
      ]),
    );
  }
}

const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

// ---------------------------------------------------------------------------
// Specialised cards
// ---------------------------------------------------------------------------

class KeyValueCard extends StatelessWidget {
  const KeyValueCard(this.rows, {super.key});
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return ZCard(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(children: [
        for (var i = 0; i < rows.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(rows[i].$1.toUpperCase(), style: ZT.caps),
                  const SizedBox(height: 6),
                  Text(rows[i].$2, style: const TextStyle(color: ZC.text, fontSize: 13, fontWeight: FontWeight.w700, height: 1.4)),
                ]),
              ),
            ]),
          ),
          if (i < rows.length - 1) const Divider(height: 1, color: ZC.divider),
        ],
      ]),
    );
  }
}

class ToggleItem {
  ToggleItem(this.title, this.subtitle, this.value);
  final String title;
  final String subtitle;
  bool value;
}

class ToggleListCard extends StatefulWidget {
  const ToggleListCard({super.key, required this.items, this.icons});
  final List<ToggleItem> items;
  final List<IconData>? icons;

  @override
  State<ToggleListCard> createState() => _ToggleListCardState();
}

class _ToggleListCardState extends State<ToggleListCard> {
  @override
  Widget build(BuildContext context) {
    return ZCard(
      padding: const EdgeInsets.fromLTRB(16, 4, 10, 4),
      child: Column(children: [
        for (var i = 0; i < widget.items.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              if (widget.icons != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: ZC.field, borderRadius: BorderRadius.circular(10), border: Border.all(color: ZC.fieldBorder)),
                  child: Icon(widget.icons![i], color: ZC.gold, size: 19),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.items[i].title, style: ZT.rowTitle),
                  const SizedBox(height: 4),
                  Text(widget.items[i].subtitle, style: ZT.rowSub),
                ]),
              ),
              Switch(
                value: widget.items[i].value,
                onChanged: (v) => setState(() => widget.items[i].value = v),
              ),
            ]),
          ),
          if (i < widget.items.length - 1) const Divider(height: 1, color: ZC.divider),
        ],
      ]),
    );
  }
}

class CheckItem {
  CheckItem(this.title, this.subtitle, this.checked);
  final String title;
  final String subtitle;
  bool checked;
}

class ChecklistCard extends StatefulWidget {
  const ChecklistCard({super.key, required this.items, this.onChanged});
  final List<CheckItem> items;
  final VoidCallback? onChanged;

  @override
  State<ChecklistCard> createState() => _ChecklistCardState();
}

class _ChecklistCardState extends State<ChecklistCard> {
  @override
  Widget build(BuildContext context) {
    return ZCard(
      padding: const EdgeInsets.fromLTRB(6, 4, 14, 4),
      child: Column(children: [
        for (var i = 0; i < widget.items.length; i++) ...[
          InkWell(
            onTap: () {
              setState(() => widget.items[i].checked = !widget.items[i].checked);
              widget.onChanged?.call();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Checkbox(
                  value: widget.items[i].checked,
                  onChanged: (v) {
                    setState(() => widget.items[i].checked = v ?? false);
                    widget.onChanged?.call();
                  },
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.items[i].title,
                        style: ZT.rowTitle.copyWith(
                          decoration: widget.items[i].checked ? TextDecoration.lineThrough : null,
                          decorationColor: ZC.muted,
                          color: widget.items[i].checked ? ZC.muted2 : ZC.text,
                        )),
                    const SizedBox(height: 4),
                    Text(widget.items[i].subtitle, style: ZT.rowSub),
                  ]),
                ),
              ]),
            ),
          ),
          if (i < widget.items.length - 1) const Divider(height: 1, color: ZC.divider, indent: 50),
        ],
      ]),
    );
  }
}

class SuccessPanel extends StatefulWidget {
  const SuccessPanel({super.key, required this.title, this.subtitle = 'Recorded in your secure work history', this.icon = Icons.check_rounded, this.color = ZC.gold});
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  State<SuccessPanel> createState() => _SuccessPanelState();
}

class _SuccessPanelState extends State<SuccessPanel> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZCard(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      child: Column(children: [
        ScaleTransition(
          scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color.withAlpha(30), border: Border.all(color: widget.color.withAlpha(140), width: 1.5)),
            child: Icon(widget.icon, color: widget.color, size: 36),
          ),
        ),
        const SizedBox(height: 16),
        Text(widget.title, textAlign: TextAlign.center, style: const TextStyle(color: ZC.text, fontSize: 20, fontWeight: FontWeight.w700, height: 1.3)),
        const SizedBox(height: 8),
        Text(widget.subtitle, textAlign: TextAlign.center, style: ZT.rowSub.copyWith(fontSize: 12)),
      ]),
    );
  }
}

class BigTimerCard extends StatelessWidget {
  const BigTimerCard({super.key, required this.label, required this.value, this.chip, this.caption, this.valueColor = ZC.goldLight});
  final String label;
  final String value;
  final Widget? chip;
  final String? caption;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return ZCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(children: [
        Text(label.toUpperCase(), style: ZT.caps),
        const SizedBox(height: 12),
        Text(value, style: TextStyle(color: valueColor, fontSize: 50, fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()])),
        if (chip != null) ...[const SizedBox(height: 10), chip!],
        if (caption != null) ...[const SizedBox(height: 12), Text(caption!, textAlign: TextAlign.center, style: ZT.rowSub.copyWith(fontSize: 12))],
      ]),
    );
  }
}

class TimelineCard extends StatelessWidget {
  const TimelineCard(this.steps, {super.key, this.doneCount});
  final List<(String, String)> steps;
  final int? doneCount;

  @override
  Widget build(BuildContext context) {
    final done = doneCount ?? steps.length;
    return ZCard(
      child: Column(children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: 26,
                child: Column(children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: i < done ? ZC.gold : ZC.field, border: Border.all(color: i < done ? ZC.gold : ZC.fieldBorder, width: 2)),
                    child: i < done ? const Icon(Icons.check, size: 11, color: ZC.navy) : null,
                  ),
                  if (i < steps.length - 1) Expanded(child: Container(width: 2, color: i < done - 1 ? ZC.gold : ZC.fieldBorder)),
                ]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 18 : 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(steps[i].$1, style: ZT.rowTitle.copyWith(color: i < done ? ZC.text : ZC.muted2)),
                    const SizedBox(height: 4),
                    Text(steps[i].$2, style: ZT.rowSub),
                  ]),
                ),
              ),
            ]),
          ),
      ]),
    );
  }
}

class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({super.key, required this.options, required this.selected, required this.onChanged});
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (var i = 0; i < options.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i == selected ? ZC.gold : ZC.field,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: i == selected ? ZC.gold : ZC.fieldBorder),
              ),
              child: Text(options[i], style: TextStyle(color: i == selected ? ZC.navy : ZC.textSoft, fontSize: 11.5, fontWeight: i == selected ? FontWeight.w700 : FontWeight.w400)),
            ),
          ),
        ),
      ],
    ]);
  }
}
