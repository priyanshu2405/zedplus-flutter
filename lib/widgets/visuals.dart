import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

// ---------------------------------------------------------------------------
// Illustrative map (geofence or route), animated
// ---------------------------------------------------------------------------

enum MapMode { geofence, route }

class MapIllustration extends StatefulWidget {
  const MapIllustration({super.key, this.mode = MapMode.geofence, this.inside = true, this.height = 210, this.progress = 0.5});
  final MapMode mode;
  final bool inside;
  final double height;

  /// Route mode: 0..1 position of the live vehicle along the route.
  final double progress;

  @override
  State<MapIllustration> createState() => _MapIllustrationState();
}

class _MapIllustrationState extends State<MapIllustration> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRoute = widget.mode == MapMode.route;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(border: Border.all(color: ZC.surfaceBorder), borderRadius: BorderRadius.circular(14)),
          child: Stack(children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => CustomPaint(
                  painter: _MapPainter(mode: widget.mode, inside: widget.inside, t: _pulse.value, progress: widget.progress),
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xE6172230), borderRadius: BorderRadius.circular(6), border: Border.all(color: ZC.infoBorder)),
                child: const Text('Illustrative map • sample data', style: TextStyle(color: ZC.infoText, fontSize: 9.5)),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        isRoute ? '●  Ordered stops    ━  Planned route    ━  Traffic delay' : '●  Your location    ◌  Site boundary',
        style: const TextStyle(color: ZC.muted2, fontSize: 10),
      ),
    ]);
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.mode, required this.inside, required this.t, required this.progress});
  final MapMode mode;
  final bool inside;
  final double t;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = ZC.mapBg);

    // City blocks
    final block = Paint()..color = ZC.mapBlock;
    final rnd = math.Random(7);
    const cols = [0.0, 0.31, 0.73, 1.0];
    const rows = [0.0, 0.36, 0.71, 1.0];
    for (var c = 0; c < 3; c++) {
      for (var r = 0; r < 3; r++) {
        final x0 = cols[c] * w + 12, x1 = cols[c + 1] * w - 12;
        final y0 = rows[r] * h + 10, y1 = rows[r + 1] * h - 10;
        final split = 0.35 + rnd.nextDouble() * 0.3;
        final xm = x0 + (x1 - x0) * split;
        canvas.drawRRect(RRect.fromLTRBR(x0, y0, xm - 4, y1, const Radius.circular(4)), block);
        canvas.drawRRect(RRect.fromLTRBR(xm + 4, y0, x1, y1, const Radius.circular(4)), block);
      }
    }

    // Roads
    final road = Paint()
      ..color = ZC.mapRoad
      ..strokeWidth = 9;
    final lane = Paint()
      ..color = const Color(0xFF6E89A3)
      ..strokeWidth = 1;
    for (final y in [0.36, 0.71]) {
      canvas.drawLine(Offset(0, y * h), Offset(w, y * h), road);
      _dashedLine(canvas, Offset(0, y * h), Offset(w, y * h), lane);
    }
    for (final x in [0.31, 0.73]) {
      canvas.drawLine(Offset(x * w, 0), Offset(x * w, h), road);
      _dashedLine(canvas, Offset(x * w, 0), Offset(x * w, h), lane);
    }
    _label(canvas, 'PORTAGE AVE', Offset(w * 0.78, h * 0.36 - 15));
    _label(canvas, 'SITE ACCESS ROAD', Offset(6, h * 0.71 - 15));

    if (mode == MapMode.geofence) {
      final center = Offset(w * 0.5, h * 0.43);
      final radius = math.min(w, h) * 0.3;
      canvas.drawCircle(center, radius, Paint()..color = const Color(0x22C8A951));
      _dashedCircle(canvas, center, radius, Paint()
        ..color = ZC.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6);
      // Building
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 46, height: 30), const Radius.circular(5)), Paint()..color = const Color(0xFF5A7896));
      final me = inside ? center + const Offset(24, 18) : center + Offset(radius + 34, -radius * 0.55);
      _pulseDot(canvas, me, inside ? const Color(0xFF6FB6FF) : ZC.dangerText);
    } else {
      // Snap to roads: build a path using right angles
      final path = Path()..moveTo(w * 0.1, h * 0.36);
      path.lineTo(w * 0.73, h * 0.36);
      final delay = Path()
        ..moveTo(w * 0.73, h * 0.36)
        ..lineTo(w * 0.73, h * 0.71);
      final rest = Path()
        ..moveTo(w * 0.73, h * 0.71)
        ..lineTo(w * 0.92, h * 0.71);
      final routePaint = Paint()
        ..color = ZC.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, routePaint);
      canvas.drawPath(delay, routePaint..color = const Color(0xFFE07B6F));
      canvas.drawPath(rest, routePaint..color = ZC.gold);

      final stops = [
        Offset(w * 0.1, h * 0.36),
        Offset(w * 0.45, h * 0.36),
        Offset(w * 0.73, h * 0.71),
        Offset(w * 0.92, h * 0.71),
      ];
      for (var i = 0; i < stops.length; i++) {
        canvas.drawCircle(stops[i], 11, Paint()..color = ZC.navy);
        canvas.drawCircle(stops[i], 9, Paint()..color = ZC.gold);
        final tp = TextPainter(
          text: TextSpan(text: '${i + 1}', style: const TextStyle(color: ZC.navy, fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'DejaVuSans')),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, stops[i] - Offset(tp.width / 2, tp.height / 2));
      }
      // Vehicle along the delay segment
      final p = progress.clamp(0.0, 1.0);
      final car = Offset(w * 0.73, h * 0.36 + (h * 0.35) * p);
      _pulseDot(canvas, car, const Color(0xFF6FB6FF));
    }
  }

  void _pulseDot(Canvas canvas, Offset c, Color color) {
    canvas.drawCircle(c, 6 + 16 * t, Paint()..color = color.withAlpha(((1 - t) * 90).round()));
    canvas.drawCircle(c, 8, Paint()..color = Colors.white);
    canvas.drawCircle(c, 6, Paint()..color = color);
  }

  void _label(Canvas canvas, String text, Offset at) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Color(0xFF9DB1C6), fontSize: 7.5, letterSpacing: 1, fontFamily: 'DejaVuSans')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint p) {
    final total = (b - a).distance;
    final dir = (b - a) / total;
    for (double d = 0; d < total; d += 12) {
      canvas.drawLine(a + dir * d, a + dir * math.min(d + 6, total), p);
    }
  }

  void _dashedCircle(Canvas canvas, Offset c, double r, Paint p) {
    const n = 36;
    for (var i = 0; i < n; i++) {
      final a0 = i * 2 * math.pi / n;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), a0, math.pi / n, false, p);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.t != t || old.inside != inside || old.progress != progress;
}

// ---------------------------------------------------------------------------
// Signature pad
// ---------------------------------------------------------------------------

class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key, required this.signer, this.onChanged});
  final String signer;
  final ValueChanged<bool>? onChanged;

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final List<List<Offset>> _strokes = [];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('SIGN BELOW', style: ZT.caps.copyWith(color: ZC.gold)),
      const SizedBox(height: 8),
      Container(
        height: 170,
        decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onPanStart: (d) => setState(() {
              _strokes.add([d.localPosition]);
              widget.onChanged?.call(true);
            }),
            onPanUpdate: (d) => setState(() => _strokes.last.add(d.localPosition)),
            child: CustomPaint(
              painter: _SigPainter(_strokes),
              child: SizedBox.expand(
                child: _strokes.isEmpty
                    ? const Center(child: Text('Sign here with your finger', style: TextStyle(color: Color(0xFF8A96A8), fontSize: 13)))
                    : null,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: Text(widget.signer, style: const TextStyle(color: ZC.textSoft, fontSize: 12, fontWeight: FontWeight.w700))),
        TextButton.icon(
          onPressed: () => setState(() {
            _strokes.clear();
            widget.onChanged?.call(false);
          }),
          icon: const Icon(Icons.refresh_rounded, size: 16, color: ZC.goldLight),
          label: const Text('Clear', style: TextStyle(color: ZC.goldLight, fontSize: 12)),
        ),
      ]),
    ]);
  }
}

class _SigPainter extends CustomPainter {
  _SigPainter(this.strokes);
  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final guide = Paint()
      ..color = const Color(0xFFC6CFDA)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(20, size.height - 34), Offset(size.width - 20, size.height - 34), guide);
    final p = Paint()
      ..color = ZC.navy
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final s in strokes) {
      if (s.length < 2) {
        if (s.isNotEmpty) canvas.drawCircle(s.first, 1.4, p..style = PaintingStyle.fill);
        p.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(s.first.dx, s.first.dy);
      for (var i = 1; i < s.length; i++) {
        path.lineTo(s[i].dx, s[i].dy);
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _SigPainter oldDelegate) => true;
}

// ---------------------------------------------------------------------------
// Scanner (NFC / QR / GPS)
// ---------------------------------------------------------------------------

class ScannerView extends StatefulWidget {
  const ScannerView({super.key, required this.method});
  final int method; // 0 NFC, 1 QR, 2 GPS

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(color: ZC.field, borderRadius: BorderRadius.circular(16), border: Border.all(color: ZC.gold, width: 1.4)),
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          if (widget.method == 1) {
            return Stack(alignment: Alignment.center, children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(border: Border.all(color: ZC.goldLight, width: 6), borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.qr_code_2_rounded, color: Color(0x66EAD695), size: 96),
              ),
              Positioned(
                top: 45 + 130 * _c.value,
                child: Container(width: 150, height: 2, color: ZC.gold, child: const SizedBox()),
              ),
            ]);
          }
          if (widget.method == 2) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Transform.scale(scale: 1 + 0.1 * _c.value, child: const Icon(Icons.gps_fixed_rounded, color: ZC.gold, size: 74)),
                const SizedBox(height: 12),
                Text('Accuracy ${(12 - 5 * _c.value).toStringAsFixed(0)} m', style: const TextStyle(color: ZC.textSoft, fontSize: 12)),
              ]),
            );
          }
          return Stack(alignment: Alignment.center, children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: 70 + 50.0 * i + 20 * _c.value,
                height: 70 + 50.0 * i + 20 * _c.value,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ZC.gold.withAlpha(180 - i * 55), width: 1.4)),
              ),
            const Icon(Icons.nfc_rounded, color: ZC.goldLight, size: 52),
          ]);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Press-and-hold button (panic)
// ---------------------------------------------------------------------------

class HoldButton extends StatefulWidget {
  const HoldButton({super.key, required this.onComplete, this.label = 'SOS', this.sub = 'HOLD'});
  final VoidCallback onComplete;
  final String label;
  final String sub;

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        widget.onComplete();
        _c.reset();
      }
    });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        HapticFeedback.mediumImpact();
        _c.forward();
      },
      onPointerUp: (_) {
        if (_c.status != AnimationStatus.completed) _c.reverse();
      },
      onPointerCancel: (_) => _c.reverse(),
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => SizedBox(
          width: 190,
          height: 190,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(
              width: 190,
              height: 190,
              child: CircularProgressIndicator(value: _c.value, strokeWidth: 8, color: ZC.dangerText, backgroundColor: ZC.danger),
            ),
            Transform.scale(
              scale: 1 - 0.05 * _c.value,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFA03A48),
                  border: Border.all(color: const Color(0xFF86515D), width: 6),
                  boxShadow: [BoxShadow(color: const Color(0x66B0414F), blurRadius: 30 * (0.4 + _c.value))],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: 2)),
                  Text(_c.value > 0 ? '${(2 - 2 * _c.value).toStringAsFixed(1)}s' : widget.sub, style: const TextStyle(color: Color(0xFFFFD6D9), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 2)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Camera viewfinder mock
// ---------------------------------------------------------------------------

class CameraMock extends StatefulWidget {
  const CameraMock({super.key, required this.captured});
  final bool captured;

  @override
  State<CameraMock> createState() => _CameraMockState();
}

class _CameraMockState extends State<CameraMock> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.15,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1824),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: widget.captured ? ZC.successText : ZC.gold, width: 1.6),
        ),
        child: Stack(alignment: Alignment.center, children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) => Container(
              width: 120 + (widget.captured ? 0 : 6 * _c.value),
              height: 160 + (widget.captured ? 0 : 6 * _c.value),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.elliptical(70, 90)),
                border: Border.all(color: widget.captured ? ZC.successText : ZC.goldLight.withAlpha(160), width: 2),
                color: const Color(0xFF243B55),
              ),
              child: const Icon(Icons.person_rounded, size: 110, color: Color(0xFF8FA6C2)),
            ),
          ),
          if (widget.captured)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: ZC.success, borderRadius: BorderRadius.circular(6), border: Border.all(color: ZC.successBorder)),
                child: const Text('Face matched', style: TextStyle(color: ZC.successText, fontSize: 10.5)),
              ),
            ),
          const Positioned(
            bottom: 12,
            child: Text('Demo camera • no photo stored', style: TextStyle(color: ZC.muted, fontSize: 10)),
          ),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PIN dots + keypad
// ---------------------------------------------------------------------------

class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.length, this.total = 4, this.error = false});
  final int length;
  final int total;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      for (var i = 0; i < total; i++)
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 7),
          width: 46,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ZC.field,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: error ? ZC.dangerText : (i < length ? ZC.gold : ZC.fieldBorder), width: i < length ? 1.6 : 1),
          ),
          child: i < length ? const CircleAvatar(radius: 5, backgroundColor: ZC.text) : null,
        ),
    ]);
  }
}

class Keypad extends StatelessWidget {
  const Keypad({super.key, required this.onDigit, required this.onDelete, this.onBiometric});
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onBiometric;

  @override
  Widget build(BuildContext context) {
    Widget key(Widget child, VoidCallback? onTap) => Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Material(
              color: onTap == null ? Colors.transparent : ZC.field,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onTap == null
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        onTap();
                      },
                child: SizedBox(height: 54, child: Center(child: child)),
              ),
            ),
          ),
        );
    Widget digit(String d) => key(Text(d, style: const TextStyle(color: ZC.text, fontSize: 22, fontWeight: FontWeight.w700)), () => onDigit(d));
    return Column(children: [
      for (final row in const [
        ['1', '2', '3'],
        ['4', '5', '6'],
        ['7', '8', '9'],
      ])
        Row(children: [for (final d in row) digit(d)]),
      Row(children: [
        key(const Icon(Icons.face_retouching_natural_rounded, color: ZC.gold), onBiometric),
        digit('0'),
        key(const Icon(Icons.backspace_outlined, color: ZC.textSoft, size: 22), onDelete),
      ]),
    ]);
  }
}
