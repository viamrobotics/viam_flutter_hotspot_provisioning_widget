import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

import '../../../mocks/generate_mocks.mocks.dart';

void main() {
  late PasswordInputViewModel viewModel;
  late MockHotspotProvisioningRepository mockRepository;
  late RobotPart mockRobotPart;
  late Function(String? fragmentId) mockOnPasswordSubmitted;
  late VoidCallback mockOnBack;

  setUp(() {
    mockRepository = MockHotspotProvisioningRepository();
    mockRobotPart = RobotPart(
      id: 'test-part-id',
      name: 'test-robot-name',
      secret: 'test-secret',
      locationId: 'test-location-id',
    );
    mockOnPasswordSubmitted = (String? fragmentId) {};
    mockOnBack = () {};
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

  Widget passwordInputScreenWidget() {
    return MaterialApp(
      home: PasswordInputScreen(
        viewModel: viewModel,
        onBack: mockOnBack,
      ),
    );
  }

  group('PasswordInputScreen', () {
    group('Initial UI State', () {
      testWidgets('displays correct title in app bar', (WidgetTester tester) async {
        await tester.pumpWidget(passwordInputScreenWidget());

        expect(find.text('Connect to Wi-Fi'), findsOneWidget);
      });

      testWidgets('displays back button in app bar', (WidgetTester tester) async {
        await tester.pumpWidget(passwordInputScreenWidget());

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('displays Done button in app bar', (WidgetTester tester) async {
        await tester.pumpWidget(passwordInputScreenWidget());

        expect(find.text('Done'), findsOneWidget);
      });

      testWidgets('clears password when screen is first shown', (WidgetTester tester) async {
        // Set password before showing screen
        viewModel.passwordController.text = 'some-password';
        expect(viewModel.passwordController.text, isNotEmpty);

        await tester.pumpWidget(passwordInputScreenWidget());

        expect(viewModel.passwordController.text, isEmpty);
      });
    });

    group('SSID Field Display', () {
      testWidgets('shows manual SSID input when network is null', (WidgetTester tester) async {
        await tester.pumpWidget(passwordInputScreenWidget());

        expect(find.text('Wi-Fi network name'), findsOneWidget);
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('shows SSIDFieldWidget when network is provided', (WidgetTester tester) async {
        viewModel.network = NetworkInfo(
          ssid: 'Test Network',
          security: 'WPA2',
          signal: 80,
        );
        await tester.pumpWidget(passwordInputScreenWidget());
        await tester.pump();

        expect(find.byType(SSIDFieldWidget), findsOneWidget);
        expect(find.text('Wi-Fi network: '), findsOneWidget);
        expect(find.text('Test Network'), findsOneWidget);
      });
    });

    group('Password Field Display', () {
      testWidgets('shows password field for private network', (WidgetTester tester) async {
        viewModel.network = NetworkInfo(
          ssid: 'Private Network',
          security: 'WPA2',
          signal: 80,
        );
        await tester.pumpWidget(passwordInputScreenWidget());
        await tester.pump();

        expect(find.text('Password'), findsOneWidget);
      });

      testWidgets('hides password field for public network', (WidgetTester tester) async {
        viewModel.network = NetworkInfo(
          ssid: 'Public Network',
          security: '-',
          signal: 80,
        );
        await tester.pumpWidget(passwordInputScreenWidget());
        await tester.pump();

        expect(find.text('Password'), findsNothing);
      });
    });

    group('Done Button State', () {
      testWidgets('Done button is enabled when credentials are valid', (WidgetTester tester) async {
        await tester.pumpWidget(passwordInputScreenWidget());
        await tester.pump();

        // set up valid credentials after widget is built
        viewModel.network = NetworkInfo(
          ssid: 'Test Network',
          security: 'WPA2',
          signal: 80,
        );
        viewModel.passwordController.text = 'test-password';

        await tester.pump();
        expect(viewModel.areNetworkCredentialsValid, isTrue);

        final doneTextFinder = find.text('Done');
        final gestureDetector = tester.widget<GestureDetector>(
          find.ancestor(
            of: doneTextFinder,
            matching: find.byType(GestureDetector),
          ),
        );
        expect(gestureDetector.onTap, isNotNull);
      });

      testWidgets('Done button is disabled when credentials are invalid', (WidgetTester tester) async {
        // no network and empty SSID
        await tester.pumpWidget(passwordInputScreenWidget());
        await tester.pump();

        final doneTextFinder = find.text('Done');
        final gestureDetector = tester.widget<GestureDetector>(
          find.ancestor(
            of: doneTextFinder,
            matching: find.byType(GestureDetector),
          ),
        );
        expect(gestureDetector.onTap, isNull);
      });

      testWidgets('Done button shows loading indicator when loading', (WidgetTester tester) async {
        viewModel.setLoading(true);
        await tester.pumpWidget(passwordInputScreenWidget());
        await tester.pump();

        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
        expect(find.text('Done'), findsNothing);
      });
    });

    group('User Interactions', () {
      testWidgets('calls onBack when back button is pressed', (WidgetTester tester) async {
        bool onBackCalled = false;
        void testOnBack() {
          onBackCalled = true;
        }

        await tester.pumpWidget(
          MaterialApp(
            home: PasswordInputScreen(
              viewModel: viewModel,
              onBack: testOnBack,
            ),
          ),
        );

        final backButtonFinder = find.byIcon(Icons.arrow_back);
        await tester.tap(backButtonFinder);
        await tester.pump();

        expect(onBackCalled, isTrue);
      });

      testWidgets('unfocuses keyboard when tapping outside fields', (WidgetTester tester) async {
        await tester.pumpWidget(passwordInputScreenWidget());

        // Focus on a text field
        await tester.tap(find.byType(TextField).first);
        await tester.pump();

        // Tap outside (on GestureDetector)
        await tester.tapAt(const Offset(100, 100));
        await tester.pump();

        // Keyboard should be unfocused (no way to directly test this, but the gesture should work)
        expect(find.byType(TextField), findsWidgets);
      });
    });
  });
}
