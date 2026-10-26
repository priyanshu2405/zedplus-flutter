import 'package:flutter_test/flutter_test.dart';
import 'package:zed_plus_app/core/demo_state.dart';
import 'package:zed_plus_app/main.dart';

void main() {
  testWidgets('Welcome screen renders', (tester) async {
    await tester.pumpWidget(ZedPlusApp(state: DemoState()));
    await tester.pump();
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Sign in'), findsWidgets);
  });

  test('Patrol state advances', () {
    final s = DemoState();
    expect(s.checkpointsDone, 2);
    s.completeNextCheckpoint('NFC');
    expect(s.checkpointsDone, 3);
  });
}
