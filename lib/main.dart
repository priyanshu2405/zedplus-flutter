import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/demo_state.dart';
import 'core/theme.dart';
import 'routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: ZC.navy,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(ZedPlusApp(state: DemoState()));
}

class ZedPlusApp extends StatelessWidget {
  const ZedPlusApp({super.key, required this.state});
  final DemoState state;

  @override
  Widget build(BuildContext context) {
    return DemoScope(
      state: state,
      child: MaterialApp(
        title: 'Zed Plus',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        routes: buildRoutes(),
        builder: (context, child) {
          // Respect device text size, but cap it so layouts stay demo-friendly.
          final mq = MediaQuery.of(context);
          final scale = mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);
          return MediaQuery(data: mq.copyWith(textScaler: scale), child: child!);
        },
      ),
    );
  }
}
