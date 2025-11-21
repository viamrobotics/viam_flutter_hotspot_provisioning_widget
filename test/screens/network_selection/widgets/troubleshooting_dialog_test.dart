import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

void main() {
  Widget troubleshootingDialogWidget({required VoidCallback onManualEntry}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => TroubleshootingDialog(
                    onManualEntry: onManualEntry,
                  ),
                );
              },
              child: const Text('Show Dialog'),
            );
          },
        ),
      ),
    );
  }

  group('TroubleshootingDialog', () {
    testWidgets('displays "Troubleshooting" title', (WidgetTester tester) async {
      await tester.pumpWidget(troubleshootingDialogWidget(onManualEntry: () {}));
      await tester.tap(find.text('Show Dialog'));
      await tester.pump();

      expect(find.text('Troubleshooting'), findsOneWidget);
    });

    testWidgets('displays troubleshooting message text', (WidgetTester tester) async {
      await tester.pumpWidget(troubleshootingDialogWidget(onManualEntry: () {}));
      await tester.tap(find.text('Show Dialog'));
      await tester.pump();

      expect(
        find.text(
          "If your devices's Wi-Fi network isn't showing up in this list, turn your device off and back on again.\n\n"
          "If you've tried this and it still isn't appearing, you can connect by manually entering your network info.",
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays "Manually enter network info" button', (WidgetTester tester) async {
      await tester.pumpWidget(troubleshootingDialogWidget(onManualEntry: () {}));
      await tester.tap(find.text('Show Dialog'));
      await tester.pump();

      expect(find.text('Manually enter network info'), findsOneWidget);
    });

    testWidgets('displays "Close" button', (WidgetTester tester) async {
      await tester.pumpWidget(troubleshootingDialogWidget(onManualEntry: () {}));
      await tester.tap(find.text('Show Dialog'));
      await tester.pump();

      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('closes dialog when Close button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(troubleshootingDialogWidget(onManualEntry: () {}));
      await tester.tap(find.text('Show Dialog'));
      await tester.pump();

      expect(find.byType(TroubleshootingDialog), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pump();

      expect(find.byType(TroubleshootingDialog), findsNothing);
    });

    testWidgets('calls onManualEntry and closes dialog when "Manually enter network info" button is tapped', (WidgetTester tester) async {
      bool onManualEntryCalled = false;
      void testOnManualEntry() {
        onManualEntryCalled = true;
      }

      await tester.pumpWidget(troubleshootingDialogWidget(onManualEntry: testOnManualEntry));
      await tester.tap(find.text('Show Dialog'));
      await tester.pump();

      expect(find.byType(TroubleshootingDialog), findsOneWidget);

      await tester.tap(find.text('Manually enter network info'));
      await tester.pump();

      expect(onManualEntryCalled, isTrue);
      expect(find.byType(TroubleshootingDialog), findsNothing);
    });
  });
}
