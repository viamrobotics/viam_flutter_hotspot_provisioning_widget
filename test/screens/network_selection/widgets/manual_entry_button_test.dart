import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

void main() {
  Widget manualEntryButtonWidget({required VoidCallback onManualEntry}) {
    return MaterialApp(
      home: Scaffold(
        body: ManualEntryButton(
          onManualEntry: onManualEntry,
        ),
      ),
    );
  }

  group('ManualEntryButton', () {
    testWidgets('displays "My network isn\'t showing up" text', (WidgetTester tester) async {
      await tester.pumpWidget(manualEntryButtonWidget(onManualEntry: () {}));

      expect(find.text("My network isn't showing up"), findsOneWidget);
    });

    testWidgets('shows TroubleshootingDialog when button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(manualEntryButtonWidget(onManualEntry: () {}));

      expect(find.byType(TroubleshootingDialog), findsNothing);

      await tester.tap(find.text("My network isn't showing up"));
      await tester.pump();

      expect(find.byType(TroubleshootingDialog), findsOneWidget);
    });

    testWidgets('passes onManualEntry callback to TroubleshootingDialog', (WidgetTester tester) async {
      bool onManualEntryCalled = false;
      void testOnManualEntry() {
        onManualEntryCalled = true;
      }

      await tester.pumpWidget(manualEntryButtonWidget(onManualEntry: testOnManualEntry));

      await tester.tap(find.text("My network isn't showing up"));
      await tester.pump();

      expect(find.byType(TroubleshootingDialog), findsOneWidget);

      await tester.tap(find.text('Manually enter network info'));
      await tester.pump();

      expect(onManualEntryCalled, isTrue);
    });
  });
}
