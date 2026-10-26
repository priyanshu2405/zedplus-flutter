import 'package:flutter/material.dart';

/// Design tokens extracted from the Zed Plus SVG designs.
class ZC {
  ZC._();

  // Brand
  static const navy = Color(0xFF0B1F3A);
  static const gold = Color(0xFFC8A951);
  static const goldLight = Color(0xFFEAD695);

  // Surfaces
  static const bg = Color(0xFF131C28);
  static const surface = Color(0xFF242B35);
  static const surfaceBorder = Color(0xFF37404E);
  static const field = Color(0xFF172230);
  static const fieldBorder = Color(0xFF425065);
  static const notice = Color(0xFF1B2736);
  static const heroTop = Color(0xFF16325A);
  static const heroBottom = Color(0xFF1B3A5E);
  static const heroBorder = Color(0xFF2C4C73);
  static const avatar = Color(0xFF243B55);
  static const divider = Color(0xFF3C4552);

  // Text
  static const text = Color(0xFFF2F3F5);
  static const textSoft = Color(0xFFD3DCE8);
  static const muted = Color(0xFF97A6BC);
  static const muted2 = Color(0xFFAAB6C7);

  // Status
  static const danger = Color(0xFF422932);
  static const dangerBorder = Color(0xFF86515D);
  static const dangerText = Color(0xFFFFB3B7);
  static const dangerSolid = Color(0xFFB0414F);
  static const success = Color(0xFF16372B);
  static const successBorder = Color(0xFF2F6B4F);
  static const successText = Color(0xFF9BE3B9);
  static const info = Color(0xFF1E3A4B);
  static const infoBorder = Color(0xFF385466);
  static const infoText = Color(0xFFB1D7EE);
  static const warn = Color(0xFF3D3420);
  static const warnBorder = Color(0xFF7A6630);

  // Map
  static const mapBg = Color(0xFF1C2838);
  static const mapBlock = Color(0xFF26364A);
  static const mapRoad = Color(0xFF456079);
}

ThemeData buildTheme() {
  const scheme = ColorScheme.dark(
    primary: ZC.gold,
    onPrimary: ZC.navy,
    secondary: ZC.goldLight,
    surface: ZC.surface,
    onSurface: ZC.text,
    error: ZC.dangerText,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    fontFamily: 'DejaVuSans',
    scaffoldBackgroundColor: ZC.bg,
    splashFactory: InkRipple.splashFactory,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: ZC.text, displayColor: ZC.text),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: ZC.surface,
      contentTextStyle: TextStyle(color: ZC.text, fontFamily: 'DejaVuSans', fontSize: 13),
      behavior: SnackBarBehavior.floating,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? ZC.navy : ZC.muted),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? ZC.gold : ZC.field),
      trackOutlineColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? ZC.gold : ZC.fieldBorder),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? ZC.gold : Colors.transparent),
      checkColor: WidgetStateProperty.all(ZC.navy),
      side: const BorderSide(color: ZC.fieldBorder, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: ZC.gold, selectionColor: Color(0x55C8A951), selectionHandleColor: ZC.gold),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
  );
}

class ZT {
  ZT._();
  static const eyebrow = TextStyle(color: ZC.gold, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2.2);
  static const title = TextStyle(color: ZC.text, fontSize: 24, fontWeight: FontWeight.w700, height: 1.2);
  static const subtitle = TextStyle(color: ZC.muted2, fontSize: 13);
  static const cardTitle = TextStyle(color: ZC.text, fontSize: 15, fontWeight: FontWeight.w700);
  static const rowTitle = TextStyle(color: ZC.text, fontSize: 13.5, fontWeight: FontWeight.w700);
  static const rowSub = TextStyle(color: ZC.muted, fontSize: 11.5);
  static const label = TextStyle(color: ZC.textSoft, fontSize: 11.5);
  static const caps = TextStyle(color: ZC.muted, fontSize: 10.5, letterSpacing: 1.4);
  static const body = TextStyle(color: ZC.textSoft, fontSize: 12.5, height: 1.5);
  static const statValue = TextStyle(color: ZC.text, fontSize: 21, fontWeight: FontWeight.w700);
  static const bigTime = TextStyle(color: ZC.goldLight, fontSize: 30, fontWeight: FontWeight.w400, letterSpacing: 0.5);
}
