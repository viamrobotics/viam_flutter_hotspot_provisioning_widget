import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

void main() {
  Widget provisioningListItemWidget({
    required String textString,
    required Widget leading,
    required bool add,
    Widget? trailing,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ProvisioningListItem(
          textString: textString,
          leading: leading,
          add: add,
          trailing: trailing,
        ),
      ),
    );
  }

  group('ProvisioningListItem', () {
    testWidgets('displays textString', (WidgetTester tester) async {
      await tester.pumpWidget(
        provisioningListItemWidget(
          textString: 'Test Network',
          leading: const Icon(Icons.wifi),
          add: false,
        ),
      );

      expect(find.text('Test Network'), findsOneWidget);
    });

    testWidgets('displays leading widget when add is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        provisioningListItemWidget(
          textString: 'Test Network',
          leading: const Icon(Icons.wifi),
          add: false,
        ),
      );

      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('displays add icon when add is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        provisioningListItemWidget(
          textString: 'Test Network',
          leading: const Icon(Icons.wifi),
          add: true,
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsNothing);
    });

    testWidgets('displays trailing widget when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        provisioningListItemWidget(
          textString: 'Test Network',
          leading: const Icon(Icons.wifi),
          add: false,
          trailing: const Icon(Icons.lock),
        ),
      );

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('does not display trailing widget when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        provisioningListItemWidget(
          textString: 'Test Network',
          leading: const Icon(Icons.wifi),
          add: false,
        ),
      );

      expect(find.byIcon(Icons.lock), findsNothing);
    });
  });
}
