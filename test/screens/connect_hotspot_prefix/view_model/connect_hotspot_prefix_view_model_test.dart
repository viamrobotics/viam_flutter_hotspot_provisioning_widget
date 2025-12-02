import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

import '../../../mocks/generate_mocks.mocks.dart';

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
      expect(connectHotspotPrefixViewModel.failedToConnectToHotspot, isFalse);
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

      // 5s Delay + 3s polling interval
      await Future.delayed(const Duration(seconds: 9));

      expect(connectHotspotPrefixViewModel.foundValidSmartMachineStatus, isTrue);
      expect(connectHotspotPrefixViewModel.pollingForMachine, isFalse);
      expect(connectHotspotPrefixViewModel.isAttemptingConnectionToHotspot, isFalse);
    });

    test('should not start polling if already polling', () async {
      connectHotspotPrefixViewModel.setPollingForMachine(true);
      connectHotspotPrefixViewModel.setFoundValidSmartMachineStatus(false);

      // Try to start polling, should be ignored due to guard condition
      connectHotspotPrefixViewModel.findProvisionedMachine();

      // Should still be in polling state (guard condition prevented new polling)
      expect(connectHotspotPrefixViewModel.pollingForMachine, isTrue);
      expect(connectHotspotPrefixViewModel.foundValidSmartMachineStatus, isFalse);
    });

    test('should not start polling if machine already found', () async {
      connectHotspotPrefixViewModel.setPollingForMachine(false);
      connectHotspotPrefixViewModel.setFoundValidSmartMachineStatus(true);

      // Try to start polling, should be ignored due to guard condition
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

      // 5s Delay + 3s polling interval
      await Future.delayed(const Duration(seconds: 9));

      expect(navigationCallbackCalled, isTrue);
      expect(connectHotspotPrefixViewModel.foundValidSmartMachineStatus, isTrue);
      expect(connectHotspotPrefixViewModel.pollingForMachine, isFalse);
    });

    test('should handle errors during polling gracefully', () async {
      when(mockHotspotProvisioningRepository.getSmartMachineStatus()).thenThrow(Exception('Network error'));

      connectHotspotPrefixViewModel.findProvisionedMachine();

      // 5s Delay + 3s polling interval
      await Future.delayed(const Duration(seconds: 9));

      // Should still be polling despite the error
      expect(connectHotspotPrefixViewModel.pollingForMachine, isTrue);
      expect(connectHotspotPrefixViewModel.foundValidSmartMachineStatus, isFalse);
    });
  });
  group('test connectToHotspot', () {
    test('should set attempting connection to true when starting on iOS', () async {
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => 'other-network');
      when(mockHotspotProvisioningRepository.connectToSecureNetworkByPrefix(
        prefix: anyNamed('prefix'),
        password: anyNamed('password'),
        isWep: anyNamed('isWep'),
        isWpa3: anyNamed('isWpa3'),
        saveNetwork: anyNamed('saveNetwork'),
      )).thenAnswer((_) async => true);

      connectHotspotPrefixViewModel.connectToHotspot();

      // Only iOS sets attempting connection state
      if (Platform.isIOS) {
        expect(connectHotspotPrefixViewModel.isAttemptingConnectionToHotspot, isTrue);
      } else {
        expect(connectHotspotPrefixViewModel.isAttemptingConnectionToHotspot, isFalse);
      }
    });

    test('should call findProvisionedMachine if already connected to hotspot', () async {
      connectHotspotPrefixViewModel.setConnectedToHotspot(true);
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => 'test-prefix-1234');

      connectHotspotPrefixViewModel.connectToHotspot();

      // Verify that getCurrentSSID was called
      verify(mockHotspotProvisioningRepository.getCurrentSSID()).called(1);
      // Verify that connectToSecureNetworkByPrefix was NOT called since we're already connected
      verifyNever(mockHotspotProvisioningRepository.connectToSecureNetworkByPrefix(
        prefix: anyNamed('prefix'),
        password: anyNamed('password'),
        isWep: anyNamed('isWep'),
        isWpa3: anyNamed('isWpa3'),
        saveNetwork: anyNamed('saveNetwork'),
      ));
    });

    test('should not call findProvisionedMachine if not connected to hotspot prefix', () async {
      connectHotspotPrefixViewModel.setConnectedToHotspot(false);
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => 'test-network');
      when(mockHotspotProvisioningRepository.connectToSecureNetworkByPrefix(
        prefix: anyNamed('prefix'),
        password: anyNamed('password'),
        isWep: anyNamed('isWep'),
        isWpa3: anyNamed('isWpa3'),
        saveNetwork: anyNamed('saveNetwork'),
      )).thenAnswer((_) async => true);

      connectHotspotPrefixViewModel.connectToHotspot();

      // Wait for async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Should proceed to connection attempt
      verify(mockHotspotProvisioningRepository.connectToSecureNetworkByPrefix(
        prefix: 'test-prefix',
        password: 'test-password',
        isWep: false,
        isWpa3: false,
        saveNetwork: true,
      )).called(1);
    });

    test('should handle SSID with quotes correctly', () async {
      connectHotspotPrefixViewModel.setConnectedToHotspot(true);
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => '"test-prefix-5678"');

      connectHotspotPrefixViewModel.connectToHotspot();

      // Should recognize the SSID with quotes as matching the prefix
      verify(mockHotspotProvisioningRepository.getCurrentSSID()).called(1);
      verifyNever(mockHotspotProvisioningRepository.connectToSecureNetworkByPrefix(
        prefix: anyNamed('prefix'),
        password: anyNamed('password'),
        isWep: anyNamed('isWep'),
        isWpa3: anyNamed('isWpa3'),
        saveNetwork: anyNamed('saveNetwork'),
      ));
    });

    test('should call connectToSecureNetworkByPrefix with correct parameters', () async {
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => 'other-network');
      when(mockHotspotProvisioningRepository.connectToSecureNetworkByPrefix(
        prefix: anyNamed('prefix'),
        password: anyNamed('password'),
        isWep: anyNamed('isWep'),
        isWpa3: anyNamed('isWpa3'),
        saveNetwork: anyNamed('saveNetwork'),
      )).thenAnswer((_) async => true);
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => 'test-prefix-1234');

      connectHotspotPrefixViewModel.connectToHotspot();

      // Wait for async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));

      verify(mockHotspotProvisioningRepository.connectToSecureNetworkByPrefix(
        prefix: 'test-prefix',
        password: 'test-password',
        isWep: false,
        isWpa3: false,
        saveNetwork: true,
      )).called(1);
    });

    test('should set connected to hotspot and call findProvisionedMachine on successful connection', () async {
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => 'other-network');
      when(mockHotspotProvisioningRepository.connectToSecureNetworkByPrefix(
        prefix: anyNamed('prefix'),
        password: anyNamed('password'),
        isWep: anyNamed('isWep'),
        isWpa3: anyNamed('isWpa3'),
        saveNetwork: anyNamed('saveNetwork'),
      )).thenAnswer((_) async => true);
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => 'test-prefix-1234');

      connectHotspotPrefixViewModel.connectToHotspot();

      // Wait for async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(connectHotspotPrefixViewModel.connectedToHotspot, isTrue);
    });

    test('should handle connection failure and set retry state', () async {
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => 'other-network');
      when(mockHotspotProvisioningRepository.connectToSecureNetworkByPrefix(
        prefix: anyNamed('prefix'),
        password: anyNamed('password'),
        isWep: anyNamed('isWep'),
        isWpa3: anyNamed('isWpa3'),
        saveNetwork: anyNamed('saveNetwork'),
      )).thenAnswer((_) async => false);

      connectHotspotPrefixViewModel.connectToHotspot();

      // Wait for async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(connectHotspotPrefixViewModel.connectedToHotspot, isFalse);

      // iOS-specific behavior: shows error state
      if (Platform.isIOS) {
        expect(connectHotspotPrefixViewModel.isAttemptingConnectionToHotspot, isFalse);
        expect(connectHotspotPrefixViewModel.failedToConnectToHotspot, isTrue);
      } else {
        // Android uses native dialogs, doesn't set these flags
        expect(connectHotspotPrefixViewModel.failedToConnectToHotspot, isFalse);
      }
    });

    test('should handle successful connection but wrong SSID', () async {
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => 'other-network');
      when(mockHotspotProvisioningRepository.connectToSecureNetworkByPrefix(
        prefix: anyNamed('prefix'),
        password: anyNamed('password'),
        isWep: anyNamed('isWep'),
        isWpa3: anyNamed('isWpa3'),
        saveNetwork: anyNamed('saveNetwork'),
      )).thenAnswer((_) async => true);
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => 'wrong-network');

      connectHotspotPrefixViewModel.connectToHotspot();

      // Wait for async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(connectHotspotPrefixViewModel.connectedToHotspot, isFalse);
      expect(connectHotspotPrefixViewModel.isAttemptingConnectionToHotspot, isFalse);

      // iOS shows error dialog for wrong SSID, Android doesn't
      if (Platform.isIOS) {
        expect(connectHotspotPrefixViewModel.failedToConnectToHotspot, isTrue);
      } else {
        expect(connectHotspotPrefixViewModel.failedToConnectToHotspot, isFalse);
      }
    });

    test('should handle unknown SSID after connection', () async {
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => 'other-network');
      when(mockHotspotProvisioningRepository.connectToSecureNetworkByPrefix(
        prefix: anyNamed('prefix'),
        password: anyNamed('password'),
        isWep: anyNamed('isWep'),
        isWpa3: anyNamed('isWpa3'),
        saveNetwork: anyNamed('saveNetwork'),
      )).thenAnswer((_) async => true);
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => '<unknown ssid>');

      connectHotspotPrefixViewModel.connectToHotspot();

      // Wait for async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(connectHotspotPrefixViewModel.connectedToHotspot, isFalse);
      expect(connectHotspotPrefixViewModel.isAttemptingConnectionToHotspot, isFalse);

      // iOS shows error dialog for unknown SSID, Android doesn't
      if (Platform.isIOS) {
        expect(connectHotspotPrefixViewModel.failedToConnectToHotspot, isTrue);
      } else {
        expect(connectHotspotPrefixViewModel.failedToConnectToHotspot, isFalse);
      }
    });

    test('should handle null SSID after connection', () async {
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => 'other-network');
      when(mockHotspotProvisioningRepository.connectToSecureNetworkByPrefix(
        prefix: anyNamed('prefix'),
        password: anyNamed('password'),
        isWep: anyNamed('isWep'),
        isWpa3: anyNamed('isWpa3'),
        saveNetwork: anyNamed('saveNetwork'),
      )).thenAnswer((_) async => true);
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => null);

      connectHotspotPrefixViewModel.connectToHotspot();

      // Wait for async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(connectHotspotPrefixViewModel.connectedToHotspot, isFalse);
      expect(connectHotspotPrefixViewModel.isAttemptingConnectionToHotspot, isFalse);

      // iOS shows error dialog for null SSID, Android doesn't
      if (Platform.isIOS) {
        expect(connectHotspotPrefixViewModel.failedToConnectToHotspot, isTrue);
      } else {
        expect(connectHotspotPrefixViewModel.failedToConnectToHotspot, isFalse);
      }
    });

    test('should handle SSID with quotes after connection', () async {
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => 'other-network');
      when(mockHotspotProvisioningRepository.connectToSecureNetworkByPrefix(
        prefix: anyNamed('prefix'),
        password: anyNamed('password'),
        isWep: anyNamed('isWep'),
        isWpa3: anyNamed('isWpa3'),
        saveNetwork: anyNamed('saveNetwork'),
      )).thenAnswer((_) async => true);
      when(mockHotspotProvisioningRepository.getCurrentSSID()).thenAnswer((_) async => '"test-prefix-1234"');

      connectHotspotPrefixViewModel.connectToHotspot();

      // Wait for async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(connectHotspotPrefixViewModel.connectedToHotspot, isTrue);
    });
  });

  group('test resetConnectionState', () {
    test('should reset all connection state flags and call disconnect', () async {
      connectHotspotPrefixViewModel.setIsAttemptingConnectionToHotspot(true);
      connectHotspotPrefixViewModel.setFailedToConnectToHotspot(true);
      connectHotspotPrefixViewModel.setFoundValidSmartMachineStatus(true);
      connectHotspotPrefixViewModel.setPollingForMachine(true);
      connectHotspotPrefixViewModel.setConnectedToHotspot(true);

      when(mockHotspotProvisioningRepository.disconnect()).thenAnswer((_) async => true);

      connectHotspotPrefixViewModel.resetConnectionState();

      // wait for async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(connectHotspotPrefixViewModel.isAttemptingConnectionToHotspot, isFalse);
      expect(connectHotspotPrefixViewModel.failedToConnectToHotspot, isFalse);
      expect(connectHotspotPrefixViewModel.foundValidSmartMachineStatus, isFalse);
      expect(connectHotspotPrefixViewModel.pollingForMachine, isFalse);
      expect(connectHotspotPrefixViewModel.connectedToHotspot, isFalse);

      verify(mockHotspotProvisioningRepository.disconnect()).called(1);
    });

    test('should reset state even if disconnect fails', () async {
      connectHotspotPrefixViewModel.setIsAttemptingConnectionToHotspot(true);
      connectHotspotPrefixViewModel.setFailedToConnectToHotspot(true);
      connectHotspotPrefixViewModel.setFoundValidSmartMachineStatus(true);
      connectHotspotPrefixViewModel.setPollingForMachine(true);
      connectHotspotPrefixViewModel.setConnectedToHotspot(true);

      when(mockHotspotProvisioningRepository.disconnect()).thenAnswer((_) async => false);

      connectHotspotPrefixViewModel.resetConnectionState();

      // wait for async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(connectHotspotPrefixViewModel.isAttemptingConnectionToHotspot, isFalse);
      expect(connectHotspotPrefixViewModel.failedToConnectToHotspot, isFalse);
      expect(connectHotspotPrefixViewModel.foundValidSmartMachineStatus, isFalse);
      expect(connectHotspotPrefixViewModel.pollingForMachine, isFalse);
      expect(connectHotspotPrefixViewModel.connectedToHotspot, isFalse);

      verify(mockHotspotProvisioningRepository.disconnect()).called(1);
    });
  });
}
