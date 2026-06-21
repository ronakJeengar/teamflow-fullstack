import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamflow_mobile/features/auth/presentation/pages/splash_page.dart';

void main() {
  testWidgets('SplashPage widget renders successfully', (WidgetTester tester) async {
    // Build the SplashPage widget in isolation.
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashPage(),
      ),
    );

    // Verify that the TeamFlow logo text is rendered on screen.
    expect(find.text('TeamFlow'), findsOneWidget);

    // Pump the animation frames by 100ms to clear the internal 50ms Future.delayed timer.
    await tester.pump(const Duration(milliseconds: 100));
  });
}
