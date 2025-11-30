import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:iotiot/app.dart';
import 'package:iotiot/screens/home_screen.dart';
import 'package:iotiot/providers/device_provider.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ],
        child: App(child: const HomeScreen()),
      ),
    );

    // Verify that app loads
    expect(find.text('IoT Temperatur Dashboard'), findsOneWidget);
  });
}
