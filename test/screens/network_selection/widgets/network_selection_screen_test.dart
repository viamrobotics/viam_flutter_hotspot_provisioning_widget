import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

import '../../../mocks/generate_mocks.mocks.dart';

void main() {
  late NetworkSelectionViewModel viewModel;
  late MockHotspotProvisioningRepository mockRepository;
  late Future<void> Function(NetworkInfo) mockOnSelectPublicNetwork;
  late void Function(NetworkInfo) mockOnSelectPrivateNetwork;
  late VoidCallback mockOnManualEntry;
  late VoidCallback mockOnBack;

  setUp(() {
    mockRepository = MockHotspotProvisioningRepository();
    when(mockRepository.getNetworkList()).thenAnswer((_) async => <NetworkInfo>[]);
    viewModel = NetworkSelectionViewModel(repository: mockRepository);
    mockOnSelectPublicNetwork = (NetworkInfo network) async {};
    mockOnSelectPrivateNetwork = (NetworkInfo network) {};
    mockOnManualEntry = () {};
    mockOnBack = () {};
  });

  tearDown(() {
    viewModel.dispose();
  });

  Widget networkSelectionScreenWidget() {
    return MaterialApp(
      home: NetworkSelectionScreen(
        viewModel: viewModel,
        onSelectPublicNetwork: mockOnSelectPublicNetwork,
        onSelectPrivateNetwork: mockOnSelectPrivateNetwork,
        onManualEntry: mockOnManualEntry,
        onBack: mockOnBack,
      ),
    );
  }

  group('NetworkSelectionScreen', () {
    testWidgets('displays correct title in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(networkSelectionScreenWidget());

      expect(find.text("Connect to your machine's Wi-Fi"), findsWidgets);
    });

    testWidgets('displays back button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(networkSelectionScreenWidget());

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('calls onBack when back button is pressed', (WidgetTester tester) async {
      bool onBackCalled = false;
      void testOnBack() {
        onBackCalled = true;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: NetworkSelectionScreen(
            viewModel: viewModel,
            onSelectPublicNetwork: mockOnSelectPublicNetwork,
            onSelectPrivateNetwork: mockOnSelectPrivateNetwork,
            onManualEntry: mockOnManualEntry,
            onBack: testOnBack,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(onBackCalled, isTrue);
    });

    testWidgets('calls getNetworks on initialization', (WidgetTester tester) async {
      when(mockRepository.getNetworkList()).thenAnswer((_) async => <NetworkInfo>[]);

      await tester.pumpWidget(networkSelectionScreenWidget());

      verify(mockRepository.getNetworkList()).called(1);
    });

    group('Loading State', () {
      testWidgets('displays "Scanning..." when loading', (WidgetTester tester) async {
        await tester.pumpWidget(networkSelectionScreenWidget());
        viewModel.setLoadingNetworks(true);
        await tester.pump();

        expect(find.text('Scanning...'), findsOneWidget);
        expect(find.text('Looking for visible networks...'), findsOneWidget);
        expect(find.byType(NoContentWidget), findsOneWidget);
      });

      testWidgets('does not display NetworkList when loading', (WidgetTester tester) async {
        await tester.pumpWidget(networkSelectionScreenWidget());
        viewModel.setLoadingNetworks(true);
        await tester.pump();

        expect(find.byType(NetworkList), findsNothing);
        expect(find.byType(NetworkEmptyState), findsNothing);
        expect(find.byType(ManualEntryButton), findsNothing);
      });
    });

    group('Empty State', () {
      testWidgets('displays NetworkEmptyState when no networks', (WidgetTester tester) async {
        await tester.pumpWidget(networkSelectionScreenWidget());
        // set state after initial load
        viewModel.setLoadingNetworks(false);
        viewModel.setMachineVisibleNetworks([]);
        await tester.pump();

        expect(find.byType(NetworkEmptyState), findsOneWidget);
        expect(find.byType(NetworkList), findsNothing);
        expect(find.byType(ManualEntryButton), findsNothing);
      });

      testWidgets('passes onManualEntry to NetworkEmptyState', (WidgetTester tester) async {
        bool onManualEntryCalled = false;
        void testOnManualEntry() {
          onManualEntryCalled = true;
        }

        await tester.pumpWidget(
          MaterialApp(
            home: NetworkSelectionScreen(
              viewModel: viewModel,
              onSelectPublicNetwork: mockOnSelectPublicNetwork,
              onSelectPrivateNetwork: mockOnSelectPrivateNetwork,
              onManualEntry: testOnManualEntry,
              onBack: mockOnBack,
            ),
          ),
        );
        viewModel.setLoadingNetworks(false);
        viewModel.setMachineVisibleNetworks([]);
        await tester.pump();

        await tester.tap(find.text("My network isn't showing up"));
        await tester.pump();

        expect(find.byType(TroubleshootingDialog), findsOneWidget);

        await tester.tap(find.text('Manually enter network info'));
        await tester.pump();

        expect(onManualEntryCalled, isTrue);
      });

      testWidgets('calls getNetworks when refresh button is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(networkSelectionScreenWidget());
        // set state to empty so NetworkEmptyState is displayed
        viewModel.setLoadingNetworks(false);
        viewModel.setMachineVisibleNetworks([]);
        await tester.pump();

        // reset mock to clear the initial getNetworks call from initState
        reset(mockRepository);
        when(mockRepository.getNetworkList()).thenAnswer((_) async => <NetworkInfo>[]);

        // tap the "try again" button from NetworkEmptyState
        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();

        verify(mockRepository.getNetworkList()).called(1);
      });
    });

    group('With Networks State', () {
      testWidgets('displays NetworkList when networks are available', (WidgetTester tester) async {
        final networks = [
          NetworkInfo(ssid: 'Network 1', security: 'WPA2', signal: 80),
          NetworkInfo(ssid: 'Network 2', security: 'WPA3', signal: 70),
        ];

        await tester.pumpWidget(networkSelectionScreenWidget());
        viewModel.setLoadingNetworks(false);
        viewModel.setMachineVisibleNetworks(networks);
        await tester.pump();

        expect(find.byType(NetworkList), findsOneWidget);
        expect(find.byType(NetworkEmptyState), findsNothing);
        expect(find.byType(NoContentWidget), findsNothing);
      });

      testWidgets('displays ManualEntryButton when networks are available', (WidgetTester tester) async {
        final networks = [
          NetworkInfo(ssid: 'Network 1', security: 'WPA2', signal: 80),
        ];

        await tester.pumpWidget(networkSelectionScreenWidget());
        viewModel.setLoadingNetworks(false);
        viewModel.setMachineVisibleNetworks(networks);
        await tester.pump();

        expect(find.byType(ManualEntryButton), findsOneWidget);
      });

      testWidgets('displays instruction text when networks are available', (WidgetTester tester) async {
        final networks = [
          NetworkInfo(ssid: 'Network 1', security: 'WPA2', signal: 80),
        ];

        await tester.pumpWidget(networkSelectionScreenWidget());
        viewModel.setLoadingNetworks(false);
        viewModel.setMachineVisibleNetworks(networks);
        await tester.pumpAndSettle();

        expect(find.text("Connect to your machine's Wi-Fi"), findsWidgets);
      });

      testWidgets('passes callbacks to NetworkList correctly', (WidgetTester tester) async {
        final publicNetwork = NetworkInfo(ssid: 'Public Network', security: '-', signal: 80);
        final privateNetwork = NetworkInfo(ssid: 'Private Network', security: 'WPA2', signal: 70);

        NetworkInfo? selectedPublicNetwork;
        NetworkInfo? selectedPrivateNetwork;

        Future<void> testOnSelectPublicNetwork(NetworkInfo network) async {
          selectedPublicNetwork = network;
        }

        void testOnSelectPrivateNetwork(NetworkInfo network) {
          selectedPrivateNetwork = network;
        }

        await tester.pumpWidget(
          MaterialApp(
            home: NetworkSelectionScreen(
              viewModel: viewModel,
              onSelectPublicNetwork: testOnSelectPublicNetwork,
              onSelectPrivateNetwork: testOnSelectPrivateNetwork,
              onManualEntry: mockOnManualEntry,
              onBack: mockOnBack,
            ),
          ),
        );
        viewModel.setLoadingNetworks(false);
        viewModel.setMachineVisibleNetworks([publicNetwork, privateNetwork]);
        await tester.pump();

        await tester.tap(find.text('Public Network'));
        await tester.pump();

        expect(selectedPublicNetwork, equals(publicNetwork));

        await tester.tap(find.text('Private Network'));
        await tester.pump();

        expect(selectedPrivateNetwork, equals(privateNetwork));
      });

      testWidgets('passes onManualEntry to ManualEntryButton', (WidgetTester tester) async {
        bool onManualEntryCalled = false;
        void testOnManualEntry() {
          onManualEntryCalled = true;
        }

        final networks = [
          NetworkInfo(ssid: 'Network 1', security: 'WPA2', signal: 80),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: NetworkSelectionScreen(
              viewModel: viewModel,
              onSelectPublicNetwork: mockOnSelectPublicNetwork,
              onSelectPrivateNetwork: mockOnSelectPrivateNetwork,
              onManualEntry: testOnManualEntry,
              onBack: mockOnBack,
            ),
          ),
        );
        viewModel.setLoadingNetworks(false);
        viewModel.setMachineVisibleNetworks(networks);
        await tester.pump();

        await tester.tap(find.text("My network isn't showing up"));
        await tester.pump();

        expect(find.byType(TroubleshootingDialog), findsOneWidget);

        await tester.tap(find.text('Manually enter network info'));
        await tester.pump();

        expect(onManualEntryCalled, isTrue);
      });
    });
  });
}
