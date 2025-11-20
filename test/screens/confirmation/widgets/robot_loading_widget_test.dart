import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

void main() {
  Widget robotLoadingWidget({required int secondsLoading}) {
    return MaterialApp(
      home: Scaffold(
        body: RobotLoadingWidget(
          secondsLoading: secondsLoading,
        ),
      ),
    );
  }

  group('RobotLoadingWidget', () {
    group('when secondsLoading is less than provisioningStillWaitingSeconds', () {
      testWidgets('displays "Setting up device..." title', (WidgetTester tester) async {
        await tester.pumpWidget(robotLoadingWidget(secondsLoading: 0));

        expect(find.text('Setting up device...'), findsOneWidget);
      });

      testWidgets('does not display bodyString', (WidgetTester tester) async {
        await tester.pumpWidget(robotLoadingWidget(secondsLoading: 30));

        expect(find.text("Please keep this screen open. We'll keep trying to connect for a few more minutes."), findsNothing);
      });

      testWidgets('displays CircularProgressIndicator', (WidgetTester tester) async {
        await tester.pumpWidget(robotLoadingWidget(secondsLoading: 20));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('when secondsLoading is greater than or equal to provisioningStillWaitingSeconds', () {
      testWidgets('displays "Still trying..." title', (WidgetTester tester) async {
        await tester.pumpWidget(robotLoadingWidget(secondsLoading: 45));

        expect(find.text('Still trying...'), findsOneWidget);
      });

      testWidgets('displays bodyString', (WidgetTester tester) async {
        await tester.pumpWidget(robotLoadingWidget(secondsLoading: 50));

        expect(find.text("Please keep this screen open. We'll keep trying to connect for a few more minutes."), findsOneWidget);
      });

      testWidgets('displays CircularProgressIndicator', (WidgetTester tester) async {
        await tester.pumpWidget(robotLoadingWidget(secondsLoading: 60));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    testWidgets('uses NoContentWidget', (WidgetTester tester) async {
      await tester.pumpWidget(robotLoadingWidget(secondsLoading: 10));

      expect(find.byType(NoContentWidget), findsOneWidget);
    });
  });
}
