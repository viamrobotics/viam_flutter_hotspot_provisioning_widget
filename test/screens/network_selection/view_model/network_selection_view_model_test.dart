import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

import '../../../mocks/generate_mocks.mocks.dart';

void main() {
  late MockHotspotProvisioningRepository mockRepository;
  late NetworkSelectionViewModel viewModel;
  bool listenerCalled = false;

  setUp(() {
    mockRepository = MockHotspotProvisioningRepository();
    viewModel = NetworkSelectionViewModel(repository: mockRepository);
  });

  group('NetworkSelectionViewModel', () {
    group('Initial State', () {
      test('should initialize with correct default values', () {
        expect(viewModel.loadingNetworks, false);
        expect(viewModel.machineVisibleNetworks, isEmpty);
        expect(viewModel.repository, mockRepository);
      });
    });

    group('signalToIcon', () {
      test('should return wifi_1_bar for signal <= 40', () {
        expect(viewModel.signalToIcon(40), Icons.wifi_1_bar);
        expect(viewModel.signalToIcon(20), Icons.wifi_1_bar);
        expect(viewModel.signalToIcon(0), Icons.wifi_1_bar);
      });

      test('should return wifi_2_bar for signal between 40 and 70', () {
        expect(viewModel.signalToIcon(41), Icons.wifi_2_bar);
        expect(viewModel.signalToIcon(55), Icons.wifi_2_bar);
        expect(viewModel.signalToIcon(70), Icons.wifi_2_bar);
      });
      test('should return wifi for signal > 70', () {
        expect(viewModel.signalToIcon(71), Icons.wifi);
        expect(viewModel.signalToIcon(85), Icons.wifi);
        expect(viewModel.signalToIcon(100), Icons.wifi);
      });
      test('should handle negative signal values', () {
        expect(viewModel.signalToIcon(-10), Icons.wifi_1_bar);
      });
    });

    group('securityToIcon', () {
      test('should return lock_open for open networks', () {
        expect(viewModel.securityToIcon('-'), Icons.lock_open);
      });

      test('should return lock for secured networks', () {
        expect(viewModel.securityToIcon('WPA'), Icons.lock);
        expect(viewModel.securityToIcon('WEP'), Icons.lock);
        expect(viewModel.securityToIcon('WPA2'), Icons.lock);
        expect(viewModel.securityToIcon('WPA3'), Icons.lock);
      });
      test('should handle null security values', () {
        expect(viewModel.securityToIcon(null), Icons.lock);
      });
      test('should handle empty string security', () {
        expect(viewModel.securityToIcon(''), Icons.lock);
      });
    });

    group('setLoadingNetworks', () {
      test('should update loading state and notify listeners', () {
        listenerCalled = false;
        viewModel.addListener(() => listenerCalled = true);

        viewModel.setLoadingNetworks(true);

        expect(viewModel.loadingNetworks, true);
        expect(listenerCalled, true);
      });

      test('should set loading to false', () {
        viewModel.setLoadingNetworks(false);
        expect(viewModel.loadingNetworks, false);
      });
    });

    group('setMachineVisibleNetworks', () {
      test('should update networks list and notify listeners', () {
        listenerCalled = false;
        viewModel.addListener(() => listenerCalled = true);

        final networks = [
          NetworkInfo(ssid: 'Network1', signal: 80, security: 'WPA2'),
          NetworkInfo(ssid: 'Network2', signal: 60, security: 'WPA'),
        ];

        viewModel.setMachineVisibleNetworks(networks);

        expect(viewModel.machineVisibleNetworks, networks);
        expect(listenerCalled, true);
      });

      test('should handle empty networks list', () {
        viewModel.setMachineVisibleNetworks([]);
        expect(viewModel.machineVisibleNetworks, isEmpty);
      });
    });

    group('getNetworks', () {
      test('should successfully fetch and sort networks', () async {
        final mockNetworks = [
          NetworkInfo(ssid: 'Network1', signal: 60, security: 'WPA2'),
          NetworkInfo(ssid: 'Network2', signal: 80, security: 'WPA'),
          NetworkInfo(ssid: 'Network3', signal: 40, security: '-'),
        ];

        when(mockRepository.getNetworkList()).thenAnswer((_) async => mockNetworks);

        await viewModel.getNetworks();

        verify(mockRepository.getNetworkList()).called(1);
        expect(viewModel.loadingNetworks, false);
        expect(viewModel.machineVisibleNetworks.length, 3);

        // Verify networks are sorted by signal strength (highest first)
        expect(viewModel.machineVisibleNetworks[0].signal, 80);
        expect(viewModel.machineVisibleNetworks[1].signal, 60);
        expect(viewModel.machineVisibleNetworks[2].signal, 40);
      });

      test('should handle empty network list', () async {
        when(mockRepository.getNetworkList()).thenAnswer((_) async => <NetworkInfo>[]);

        await viewModel.getNetworks();

        expect(viewModel.loadingNetworks, false);
        expect(viewModel.machineVisibleNetworks, isEmpty);
      });

      test('should handle repository error gracefully', () async {
        when(mockRepository.getNetworkList()).thenThrow(Exception('Network error'));

        await viewModel.getNetworks();

        expect(viewModel.loadingNetworks, false);
        expect(viewModel.machineVisibleNetworks, isEmpty);
      });

      test('should add delay when refresh is true', () async {
        when(mockRepository.getNetworkList()).thenAnswer((_) async => <NetworkInfo>[]);

        final stopwatch = Stopwatch()..start();
        await viewModel.getNetworks(refresh: true);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(500));
        expect(viewModel.loadingNetworks, false);
      });

      test('should not add delay when refresh is false', () async {
        when(mockRepository.getNetworkList()).thenAnswer((_) async => <NetworkInfo>[]);

        final stopwatch = Stopwatch()..start();
        await viewModel.getNetworks(refresh: false);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        expect(viewModel.loadingNetworks, false);
      });

      test('should set loading to true at start and false at end', () async {
        when(mockRepository.getNetworkList()).thenAnswer((_) async => <NetworkInfo>[]);

        // Track loading state changes
        final loadingStates = <bool>[];
        viewModel.addListener(() {
          loadingStates.add(viewModel.loadingNetworks);
        });

        await viewModel.getNetworks();

        expect(loadingStates, contains(true)); // Should be true at some point
        expect(viewModel.loadingNetworks, false); // Should be false at the end
      });

      test('should handle network list with duplicate signals', () async {
        final mockNetworks = [
          NetworkInfo(ssid: 'Network1', signal: 60, security: 'WPA2'),
          NetworkInfo(ssid: 'Network2', signal: 60, security: 'WPA'),
          NetworkInfo(ssid: 'Network3', signal: 40, security: '-'),
        ];

        when(mockRepository.getNetworkList()).thenAnswer((_) async => mockNetworks);

        await viewModel.getNetworks();

        expect(viewModel.machineVisibleNetworks.length, 3);
        // Both networks with signal 60 should be at the top
        expect(viewModel.machineVisibleNetworks[0].signal, 60);
        expect(viewModel.machineVisibleNetworks[1].signal, 60);
        expect(viewModel.machineVisibleNetworks[2].signal, 40);
      });
    });
  });
}
