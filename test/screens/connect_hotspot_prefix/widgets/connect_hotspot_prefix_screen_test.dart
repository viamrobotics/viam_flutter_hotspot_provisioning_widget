import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

import '../../../mocks/generate_mocks.mocks.dart';

void main() {
  late ConnectHotspotPrefixViewModel viewModel;
  late MockHotspotProvisioningRepository mockRepository;
  late VoidCallback mockOnBack;

  setUp(() {
    mockRepository = MockHotspotProvisioningRepository();
    mockOnBack = () {};
    viewModel = ConnectHotspotPrefixViewModel(
      hotspotPrefix: 'test-prefix',
      hotspotPassword: 'test-password',
      onNavigateToNetworkSelection: () {},
      repository: mockRepository,
    );
    when(mockRepository.disconnect()).thenAnswer((_) async => true);
  });

  Widget connectHotspotPrefixScreenWidget() {
    return MaterialApp(
      home: ConnectHotspotPrefixScreen(
        viewModel: viewModel,
        onBack: mockOnBack,
      ),
    );
  }

  group('Initial UI State', () {
    testWidgets('displays correct title and instructions', (WidgetTester tester) async {
      await tester.pumpWidget(connectHotspotPrefixScreenWidget());
      // app bar title
      expect(find.text('Connect to Device Hotspot'), findsAtLeast(1));
      // main heading
      expect(find.text('Steps to connect to your device:'), findsOneWidget);
      // instruction steps
      expect(find.text('1. Turn on the device you are trying to connect to.'), findsOneWidget);
      expect(find.text('2. Make sure you are nearby the device.'), findsOneWidget);
      expect(find.text('3. Press the button below to connect to the device\'s hotspot.'), findsOneWidget);
    });

    testWidgets('displays connect button with correct text', (WidgetTester tester) async {
      await tester.pumpWidget(connectHotspotPrefixScreenWidget());
      final buttonFinder = find.byType(PrimaryButton);

      expect(buttonFinder, findsOneWidget);
      expect(find.text('Connect to Device Hotspot'), findsNWidgets(2)); // Once in app bar, once in button
      // Verify button is enabled and not in loading state
      final button = tester.widget<PrimaryButton>(buttonFinder);
      expect(button.isLoading, isFalse);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('displays back button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(connectHotspotPrefixScreenWidget());

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('does not show connected indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(connectHotspotPrefixScreenWidget());

      expect(find.text('You are connected to the device\'s hotspot.'), findsNothing);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });
  });

  group('UI Updates from State Changes', () {
    testWidgets('shows connected indicator when connectedToHotspot is true', (WidgetTester tester) async {
      await tester.pumpWidget(connectHotspotPrefixScreenWidget());
      // Initially not shown
      expect(find.text('You are connected to the device\'s hotspot.'), findsNothing);

      viewModel.setConnectedToHotspot(true);
      await tester.pump();

      expect(find.text('You are connected to the device\'s hotspot.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('hides connected indicator when connectedToHotspot is false', (WidgetTester tester) async {
      // Start with connected state
      viewModel.setConnectedToHotspot(true);
      await tester.pumpWidget(connectHotspotPrefixScreenWidget());
      expect(find.text('You are connected to the device\'s hotspot.'), findsOneWidget);

      viewModel.setConnectedToHotspot(false);
      await tester.pump();

      expect(find.text('You are connected to the device\'s hotspot.'), findsNothing);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('disables button when isAttemptingConnectionToHotspot is true', (WidgetTester tester) async {
      await tester.pumpWidget(connectHotspotPrefixScreenWidget());
      final buttonFinder = find.byType(PrimaryButton);
      var button = tester.widget<PrimaryButton>(buttonFinder);
      // Button is initially enabled
      expect(button.onPressed, isNotNull);
      expect(button.isLoading, isFalse);

      viewModel.setIsAttemptingConnectionToHotspot(true);
      await tester.pump();

      button = tester.widget<PrimaryButton>(buttonFinder);
      expect(button.onPressed, isNull);
      expect(button.isLoading, isTrue);
    });

    testWidgets('shows loading state on button when pollingForMachine is true', (WidgetTester tester) async {
      await tester.pumpWidget(connectHotspotPrefixScreenWidget());
      final buttonFinder = find.byType(PrimaryButton);
      var button = tester.widget<PrimaryButton>(buttonFinder);
      // Button is initially not loading
      expect(button.isLoading, isFalse);
      expect(button.onPressed, isNotNull);

      viewModel.setPollingForMachine(true);
      await tester.pump();

      button = tester.widget<PrimaryButton>(buttonFinder);
      expect(button.isLoading, isTrue);
      expect(button.onPressed, isNull);
    });

    testWidgets('disables button when both isAttemptingConnectionToHotspot and pollingForMachine are true', (WidgetTester tester) async {
      await tester.pumpWidget(connectHotspotPrefixScreenWidget());
      final buttonFinder = find.byType(PrimaryButton);

      viewModel.setIsAttemptingConnectionToHotspot(true);
      viewModel.setPollingForMachine(true);
      await tester.pump();

      final button = tester.widget<PrimaryButton>(buttonFinder);
      expect(button.onPressed, isNull);
      expect(button.isLoading, isTrue);
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
          home: ConnectHotspotPrefixScreen(
            viewModel: viewModel,
            onBack: testOnBack,
          ),
        ),
      );

      // Find and tap the back button
      final backButtonFinder = find.byIcon(Icons.arrow_back);
      expect(backButtonFinder, findsOneWidget);

      await tester.tap(backButtonFinder);
      await tester.pump();

      expect(onBackCalled, isTrue);
    });

    testWidgets('calls connectToHotspot when button pressed with valid credentials', (WidgetTester tester) async {
      when(mockRepository.getCurrentSSID()).thenAnswer((_) async => 'other-network');
      when(mockRepository.connectToSecureNetworkByPrefix(
        prefix: anyNamed('prefix'),
        password: anyNamed('password'),
        isWep: anyNamed('isWep'),
        isWpa3: anyNamed('isWpa3'),
        saveNetwork: anyNamed('saveNetwork'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(connectHotspotPrefixScreenWidget());

      final buttonFinder = find.byType(PrimaryButton);
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pump();

      // Verify repository methods were called, indicating connectToHotspot was called
      verify(mockRepository.getCurrentSSID()).called(greaterThanOrEqualTo(1));
      verify(mockRepository.connectToSecureNetworkByPrefix(
        prefix: 'test-prefix',
        password: 'test-password',
        isWep: false,
        isWpa3: false,
        saveNetwork: true,
      )).called(1);
    });
  });

  group('Error Dialogs', () {
    testWidgets('shows credential error dialog when button pressed without credentials', (WidgetTester tester) async {
      final emptyViewModel = ConnectHotspotPrefixViewModel(
        hotspotPrefix: '',
        hotspotPassword: '',
        onNavigateToNetworkSelection: () {},
        repository: mockRepository,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ConnectHotspotPrefixScreen(
            viewModel: emptyViewModel,
            onBack: mockOnBack,
          ),
        ),
      );

      final buttonFinder = find.byType(PrimaryButton);
      await tester.tap(buttonFinder);
      await tester.pump();

      // Verify credential error dialog is shown
      expect(find.text('Missing Credentials'), findsOneWidget);
      expect(
        find.text(
          'Hotspot credentials are required but were not provided. '
          'Please ensure hotspotPrefix and hotspotPassword are set when calling this flow with promptForCredentials set to false.',
        ),
        findsOneWidget,
      );
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('shows credential error dialog when button pressed with empty prefix', (WidgetTester tester) async {
      final emptyPrefixViewModel = ConnectHotspotPrefixViewModel(
        hotspotPrefix: '',
        hotspotPassword: 'test-password',
        onNavigateToNetworkSelection: () {},
        repository: mockRepository,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ConnectHotspotPrefixScreen(
            viewModel: emptyPrefixViewModel,
            onBack: mockOnBack,
          ),
        ),
      );

      final buttonFinder = find.byType(PrimaryButton);
      await tester.tap(buttonFinder);
      await tester.pump();

      // Verify credential error dialog is shown
      expect(find.text('Missing Credentials'), findsOneWidget);
    });

    testWidgets('shows credential error dialog when button pressed with empty password', (WidgetTester tester) async {
      final emptyPasswordViewModel = ConnectHotspotPrefixViewModel(
        hotspotPrefix: 'test-prefix',
        hotspotPassword: '',
        onNavigateToNetworkSelection: () {},
        repository: mockRepository,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ConnectHotspotPrefixScreen(
            viewModel: emptyPasswordViewModel,
            onBack: mockOnBack,
          ),
        ),
      );

      final buttonFinder = find.byType(PrimaryButton);
      await tester.tap(buttonFinder);
      await tester.pump();

      // Verify credential error dialog is shown
      expect(find.text('Missing Credentials'), findsOneWidget);
    });

    testWidgets('shows connection error dialog when failedToConnectToHotspot is true', (WidgetTester tester) async {
      await tester.pumpWidget(connectHotspotPrefixScreenWidget());
      viewModel.setFailedToConnectToHotspot(true);
      await tester.pumpAndSettle();

      expect(find.text('Connection Failed'), findsOneWidget);
      expect(find.text('Failed to connect to the device hotspot. Please try again.'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('shows location permission dialog on Android when permission is denied', (WidgetTester tester) async {
      when(mockRepository.getLocationPermission()).thenAnswer((_) async => false);
      await tester.pumpWidget(connectHotspotPrefixScreenWidget());
      // Permission check only runs on Android
      if (Platform.isAndroid) {
        verify(mockRepository.getLocationPermission()).called(greaterThanOrEqualTo(1));
        expect(find.text('Precise Location Permission Required'), findsOneWidget);
        expect(
          find.text(
            'Please enable precise location permissions in your device settings to continue.\n\nWi-Fi information is considered location information on Android.',
          ),
          findsOneWidget,
        );
        expect(find.text('Continue'), findsOneWidget);
      } else {
        verifyNever(mockRepository.getLocationPermission());
      }
    });
  });

  group('resetConnectionState', () {
    testWidgets('calls resetConnectionState when screen initializes', (WidgetTester tester) async {
      await tester.pumpWidget(connectHotspotPrefixScreenWidget());
      // verify disconnect was called, indicating resetConnectionState was called
      verify(mockRepository.disconnect()).called(1);
    });

    testWidgets('calls resetConnectionState when back button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(connectHotspotPrefixScreenWidget());
      // reset the repository so that it does not have the first disconnect call from initState in its history
      reset(mockRepository);
      when(mockRepository.disconnect()).thenAnswer((_) async => true);

      final backButtonFinder = find.byIcon(Icons.arrow_back);
      expect(backButtonFinder, findsOneWidget);

      await tester.tap(backButtonFinder);
      await tester.pump();

      // verify disconnect was called, indicating resetConnectionState was called
      verify(mockRepository.disconnect()).called(1);
    });
  });
}
