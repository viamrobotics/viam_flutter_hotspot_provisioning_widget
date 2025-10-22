import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

import '../../mocks/generate_mocks.mocks.dart';

void main() {
  late ConnectHotspotPrefixViewModel connectHotspotPrefixViewModel;
  late MockHotspotProvisioningRepository mockHotspotProvisioningRepository;

  setUp(() {
    mockHotspotProvisioningRepository = MockHotspotProvisioningRepository();
    connectHotspotPrefixViewModel = ConnectHotspotPrefixViewModel(
      hotspotPrefix: 'test-prefix',
      hotspotPassword: 'test-password',
      onNavigateToNetworkSelection: () {},
      repository: mockHotspotProvisioningRepository,
    );
  });

  group('initial state', () {
    test('should have correct initial state', () {
      expect(connectHotspotPrefixViewModel.isAttemptingConnectionToHotspot, isFalse);
      expect(connectHotspotPrefixViewModel.isRetryingHotspot, isFalse);
      expect(connectHotspotPrefixViewModel.foundValidSmartMachineStatus, isFalse);
      expect(connectHotspotPrefixViewModel.pollingForMachine, isFalse);
      expect(connectHotspotPrefixViewModel.connectedToHotspot, isFalse);
    });
  });

  group('test getLocationPermission', () {
    test('should return true if location permission is granted', () async {
      when(mockHotspotProvisioningRepository.getLocationPermission()).thenAnswer((_) async => true);
      expect(await connectHotspotPrefixViewModel.getLocationPermission(), isTrue);
    });

    test('should return false if location permission is not granted', () async {
      when(mockHotspotProvisioningRepository.getLocationPermission()).thenAnswer((_) async => false);
      expect(await connectHotspotPrefixViewModel.getLocationPermission(), isFalse);
    });
  });
  group('test findProvisionedMachine', () {
    test('should find provisioned machine and stop polling after success', () async {
      when(mockHotspotProvisioningRepository.getSmartMachineStatus()).thenAnswer((_) async => GetSmartMachineStatusResponse());

      connectHotspotPrefixViewModel.findProvisionedMachine();

      // Wait for the polling to complete
      await Future.delayed(const Duration(seconds: 9));

      expect(connectHotspotPrefixViewModel.foundValidSmartMachineStatus, isTrue);
      expect(connectHotspotPrefixViewModel.pollingForMachine, isFalse);
      expect(connectHotspotPrefixViewModel.isAttemptingConnectionToHotspot, isFalse);
    });

    test('should not start polling if already polling', () async {
      // Directly set the state to simulate already polling
      connectHotspotPrefixViewModel.setPollingForMachine(true);
      connectHotspotPrefixViewModel.setFoundValidSmartMachineStatus(false);

      // Try to start polling - should be ignored due to guard condition
      connectHotspotPrefixViewModel.findProvisionedMachine();

      // Should still be in polling state (guard condition prevented new polling)
      expect(connectHotspotPrefixViewModel.pollingForMachine, isTrue);
      expect(connectHotspotPrefixViewModel.foundValidSmartMachineStatus, isFalse);
    });

    test('should not start polling if machine already found', () async {
      // Directly set the state to simulate machine already found
      connectHotspotPrefixViewModel.setPollingForMachine(false);
      connectHotspotPrefixViewModel.setFoundValidSmartMachineStatus(true);

      // Try to start polling - should be ignored due to guard condition
      connectHotspotPrefixViewModel.findProvisionedMachine();

      // Should still be in found state (guard condition prevented new polling)
      expect(connectHotspotPrefixViewModel.foundValidSmartMachineStatus, isTrue);
      expect(connectHotspotPrefixViewModel.pollingForMachine, isFalse);
    });

    test('should call navigation callback when machine is found', () async {
      bool navigationCallbackCalled = false;

      connectHotspotPrefixViewModel = ConnectHotspotPrefixViewModel(
        hotspotPrefix: 'test-prefix',
        hotspotPassword: 'test-password',
        onNavigateToNetworkSelection: () {
          navigationCallbackCalled = true;
        },
        repository: mockHotspotProvisioningRepository,
      );

      when(mockHotspotProvisioningRepository.getSmartMachineStatus()).thenAnswer((_) async => GetSmartMachineStatusResponse());

      connectHotspotPrefixViewModel.findProvisionedMachine();

      // Wait for the polling to complete
      await Future.delayed(const Duration(seconds: 9));

      expect(navigationCallbackCalled, isTrue);
      expect(connectHotspotPrefixViewModel.foundValidSmartMachineStatus, isTrue);
      expect(connectHotspotPrefixViewModel.pollingForMachine, isFalse);
    });

    test('should handle errors during polling gracefully', () async {
      when(mockHotspotProvisioningRepository.getSmartMachineStatus()).thenThrow(Exception('Network error'));

      connectHotspotPrefixViewModel.findProvisionedMachine();

      // Wait for polling to start and encounter error
      await Future.delayed(const Duration(seconds: 9));

      // Should still be polling despite the error
      expect(connectHotspotPrefixViewModel.pollingForMachine, isTrue);
      expect(connectHotspotPrefixViewModel.foundValidSmartMachineStatus, isFalse);
    });
  });
  group('test connectToHotspot', () {
    test('', () async {});
  });
}
