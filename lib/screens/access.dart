import 'package:flutter/material.dart';

import '../core/demo_state.dart';
import '../core/theme.dart';
import '../widgets/visuals.dart';
import '../widgets/z_widgets.dart';

void _enterApp(BuildContext context) {
  final home = DemoScope.read(context).homeRoute;
  Navigator.of(context).pushNamedAndRemoveUntil(home, (r) => false);
}

// M01 Welcome
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Access',
      title: 'Welcome',
      crumb: null,
      showActions: false,
      showNav: false,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 34, 22, 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF14365C), Color(0xFF0E2340)]),
            border: Border.all(color: ZC.heroBorder),
          ),
          child: Column(children: [
            Container(
              width: 86,
              height: 86,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ZC.gold,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [BoxShadow(color: Color(0x55C8A951), blurRadius: 30)],
              ),
              child: const Text('Z+', style: TextStyle(color: ZC.navy, fontSize: 38, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 26),
            const Text('ZED PLUS • FIELD OPERATIONS', style: TextStyle(color: ZC.gold, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.8)),
            const SizedBox(height: 14),
            const Text.rich(
              TextSpan(children: [
                TextSpan(text: 'Every post.\nEvery patrol.\n'),
                TextSpan(text: 'Protected.', style: TextStyle(color: ZC.gold)),
              ]),
              textAlign: TextAlign.center,
              style: TextStyle(color: ZC.text, fontSize: 27, fontWeight: FontWeight.w700, height: 1.25),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your secure workspace for attendance, patrols, reports and the people who count on you.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ZC.textSoft, fontSize: 12.5, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text('Android & iPhone • role-based access', style: TextStyle(color: ZC.muted, fontSize: 10.5)),
          ]),
        ),
        const SizedBox(height: 4),
        ActionStack(
          primary: 'Sign in',
          onPrimary: () => go(context, '/m02'),
          links: [
            ('Join company', () => go(context, '/m03')),
            ('Browse all 91 screens (demo index)', () => go(context, '/directory')),
          ],
        ),
      ],
    );
  }
}

// M02 Sign in
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    final isGuard = state.role == Role.guard;
    return ZScaffold(
      eyebrow: 'Access',
      title: 'Sign in',
      crumb: null,
      showActions: false,
      showNav: false,
      children: [
        FormCard(
          title: 'Secure access',
          subtitle: 'Use your Zed Plus office account.',
          fields: [
            const SizedBox(height: 4),
            ZField('Email or employee ID', key: ValueKey(state.role), initial: isGuard ? 'alex.morgan@zedplus.example' : 'priya.shah@zedplus.example', keyboard: TextInputType.emailAddress),
            const ZField('Password', initial: 'demo-password', obscure: true),
          ],
        ),
        ZCard(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DEMO ROLE', style: ZT.caps.copyWith(color: ZC.gold)),
            const SizedBox(height: 10),
            SegmentedTabs(
              options: const ['Guard • Alex', 'Supervisor • Priya'],
              selected: isGuard ? 0 : 1,
              onChanged: (i) => DemoScope.read(context).setRole(i == 0 ? Role.guard : Role.supervisor),
            ),
            const SizedBox(height: 10),
            Text(isGuard ? 'Opens the guard journey: shift, clock-in, patrols, reports.' : 'Opens the supervisor journey: route, inspections, approvals.', style: ZT.rowSub),
          ]),
        ),
        ActionStack(
          primary: 'Sign in securely',
          icon: Icons.lock_outline_rounded,
          onPrimary: () => fakeSubmit(context, label: 'Verifying credentials…', then: () => _enterApp(context)),
          links: [
            ('Join company', () => go(context, '/m03')),
            ('Reset password', () => go(context, '/m04')),
            ('PIN & biometric unlock', () => go(context, '/m05')),
          ],
        ),
      ],
    );
  }
}

// M03 Join company
class JoinCompanyScreen extends StatelessWidget {
  const JoinCompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Access',
      title: 'Join company',
      crumb: null,
      showActions: false,
      showNav: false,
      children: [
        const FormCard(fields: [
          ZField('Company code', initial: 'ZED-MB-2026'),
          ZField('Employee email', initial: 'alex.morgan@zedplus.example', keyboard: TextInputType.emailAddress),
          ZField('Create password', hint: 'Choose a secure password', obscure: true),
        ]),
        const Notice('Your office invitation links this account to Zed Plus.'),
        PrimaryButton('Accept invitation', onPressed: () => fakeSubmit(context, label: 'Linking your account…', then: () => go(context, '/m06'))),
      ],
    );
  }
}

// M06 Location & permissions
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Access',
      title: 'Location & permissions',
      crumb: null,
      showActions: false,
      showNav: false,
      children: [
        ToggleListCard(
          icons: const [Icons.my_location_rounded, Icons.photo_camera_outlined, Icons.notifications_none_rounded, Icons.nfc_rounded],
          items: [
            ToggleItem('On-shift location', 'Required for GPS attendance', true),
            ToggleItem('Camera', 'For scans and report evidence', true),
            ToggleItem('Notifications', 'Shift changes and dispatch', true),
            ToggleItem('NFC access', 'For tagged checkpoints', false),
          ],
        ),
        const Notice('Location is collected only while clocked in or on an assigned route. Your consent is recorded.'),
        PrimaryButton('Accept & continue', onPressed: () => fakeSubmit(context, label: 'Recording consent…', then: () => _enterApp(context))),
      ],
    );
  }
}

// M05 PIN & biometric unlock
class PinUnlockScreen extends StatefulWidget {
  const PinUnlockScreen({super.key});

  @override
  State<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends State<PinUnlockScreen> {
  String pin = '';

  void _digit(String d) {
    if (pin.length >= 4) return;
    setState(() => pin += d);
    if (pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) fakeSubmit(context, label: 'Unlocking…', ms: 600, then: () => _enterApp(context));
      });
    }
  }

  Future<void> _biometric() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        Future.delayed(const Duration(milliseconds: 1300), () {
          if (c.mounted) Navigator.pop(c);
        });
        return AlertDialog(
          backgroundColor: ZC.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: const Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(height: 8),
            Icon(Icons.face_retouching_natural_rounded, color: ZC.gold, size: 64),
            SizedBox(height: 14),
            Text('Face ID', style: TextStyle(color: ZC.text, fontSize: 16, fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text('Demo biometric check', style: TextStyle(color: ZC.muted, fontSize: 12)),
          ]),
        );
      },
    ).then((_) {
      if (mounted) _enterApp(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = DemoScope.of(context);
    return ZScaffold(
      eyebrow: 'Access',
      title: 'PIN & biometric unlock',
      crumb: null,
      showActions: false,
      showNav: false,
      children: [
        ZCard(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
          child: Column(children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: ZC.avatar,
              child: Text(state.initials, style: const TextStyle(color: ZC.goldLight, fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            const SizedBox(height: 14),
            const Text('Enter your secure PIN', style: ZT.cardTitle),
            const SizedBox(height: 16),
            PinDots(length: pin.length),
            const SizedBox(height: 14),
            const Text('Any 4 digits work in this demo', style: ZT.rowSub),
          ]),
        ),
        Keypad(
          onDigit: _digit,
          onDelete: () => setState(() => pin = pin.isEmpty ? pin : pin.substring(0, pin.length - 1)),
          onBiometric: _biometric,
        ),
        PrimaryButton('Unlock with Face ID', icon: Icons.face_retouching_natural_rounded, onPressed: _biometric),
      ],
    );
  }
}

// M04 Reset password
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      eyebrow: 'Access',
      title: 'Reset password',
      crumb: null,
      showActions: false,
      showNav: false,
      children: [
        const FormCard(fields: [ZField('Email or phone', initial: 'alex.morgan@zedplus.example')]),
        const Notice('We will send a secure reset link to your registered contact.'),
        PrimaryButton('Send reset link', onPressed: () {
          fakeSubmit(context, label: 'Sending link…', then: () {
            toast(context, 'Reset link sent to a•••@zedplus.example');
            Navigator.of(context).maybePop();
          });
        }),
      ],
    );
  }
}
