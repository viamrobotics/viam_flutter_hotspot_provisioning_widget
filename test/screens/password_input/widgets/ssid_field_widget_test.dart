import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

import '../../../mocks/generate_mocks.mocks.dart';

void main() {
  late PasswordInputViewModel viewModel;
  late MockHotspotProvisioningRepository mockRepository;
  late RobotPart mockRobotPart;
  late Function(String? fragmentId) mockOnPasswordSubmitted;

  setUp(() {
    mockRepository = MockHotspotProvisioningRepository();
    mockRobotPart = RobotPart(
      id: 'test-part-id',
      name: 'test-robot-name',
      secret: 'test-secret',
      locationId: 'test-location-id',
    );
    mockOnPasswordSubmitted = (String? fragmentId) {};
    viewModel = PasswordInputViewModel(
      repository: mockRepository,
      mainPart: mockRobotPart,
      fragmentId: 'test-fragment-id',
      onPasswordSubmitted: mockOnPasswordSubmitted,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  Widget ssidFieldWidget({NetworkInfo? network}) {
    return MaterialApp(
      home: Scaffold(
        body: SSIDFieldWidget(
          viewModel: viewModel,
          network: network,
        ),
      ),
    );
  }

  group('SSIDFieldWidget', () {
    group('when network is provided', () {
      testWidgets('displays network SSID', (WidgetTester tester) async {
        final network = NetworkInfo(
          ssid: 'Test Network',
          security: 'WPA2',
          signal: 80,
        );

        await tester.pumpWidget(ssidFieldWidget(network: network));

        expect(find.text('Wi-Fi network:'), findsOneWidget);
        expect(find.text('Test Network'), findsOneWidget);
      });

      testWidgets('displays network SSID with correct styling', (WidgetTester tester) async {
        final network = NetworkInfo(
          ssid: 'My Network',
          security: 'WPA2',
          signal: 80,
        );

        await tester.pumpWidget(ssidFieldWidget(network: network));

        final ssidText = tester.widget<Text>(find.text('My Network'));
        expect(ssidText.style?.fontWeight, equals(FontWeight.bold));
        expect(ssidText.style?.fontSize, equals(15.0));
      });

      testWidgets('does not show manual input field when network is provided', (WidgetTester tester) async {
        final network = NetworkInfo(
          ssid: 'Test Network',
          security: 'WPA2',
          signal: 80,
        );

        await tester.pumpWidget(ssidFieldWidget(network: network));

        expect(find.text('Wi-Fi network name'), findsNothing);
        expect(find.byType(TextField), findsNothing);
      });
    });

    group('when network is not provided', () {
      testWidgets('displays manual input field label', (WidgetTester tester) async {
        await tester.pumpWidget(ssidFieldWidget());

        expect(find.text('Wi-Fi network name'), findsOneWidget);
      });

      testWidgets('displays TextField for manual SSID input', (WidgetTester tester) async {
        await tester.pumpWidget(ssidFieldWidget());

        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('uses viewModel ssidController', (WidgetTester tester) async {
        await tester.pumpWidget(ssidFieldWidget());

        await tester.enterText(find.byType(TextField), 'Manual Network');
        await tester.pump();

        expect(viewModel.ssidController.text, equals('Manual Network'));
      });

      testWidgets('does not show network display when network is null', (WidgetTester tester) async {
        await tester.pumpWidget(ssidFieldWidget());

        expect(find.text('Wi-Fi network:'), findsNothing);
      });

      testWidgets('has autocorrect disabled', (WidgetTester tester) async {
        await tester.pumpWidget(ssidFieldWidget());

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.autocorrect, isFalse);
      });
    });
  });
}
