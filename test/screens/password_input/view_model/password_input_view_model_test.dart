import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

import '../../../mocks/generate_mocks.mocks.dart';

void main() {
  late MockHotspotProvisioningRepository mockRepository;
  late RobotPart mockRobotPart;
  late PasswordInputViewModel viewModel;
  late Function(String? fragmentId) mockOnPasswordSubmitted;
  bool listenerCalled = false;
  late GetSmartMachineStatusResponse mockGetSmartMachineStatusResponse;
  late NetworkInfo mockNetwork;

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

    listenerCalled = false;
    viewModel.addListener(() {
      listenerCalled = true;
    });

    mockGetSmartMachineStatusResponse = GetSmartMachineStatusResponse(
      hasSmartMachineCredentials: true,
      agentVersion: '0.20.0',
      provisioningInfo: ProvisioningInfo(
        fragmentId: 'agent-fragment-id',
      ),
    );
  });
  mockNetwork = NetworkInfo(
    ssid: 'test-network',
    security: 'WPA2',
    signal: 80,
  );

  tearDown(() {
    viewModel.dispose();
  });

  group('Initialization', () {
    test('should initialize with correct default values', () {
      expect(viewModel.passwordController.text, isEmpty);
      expect(viewModel.ssidController.text, isEmpty);
      expect(viewModel.obscureText, false);
      expect(viewModel.loading, false);
      expect(viewModel.network, isNull);
      expect(viewModel.areNetworkCredentialsValid, false);
    });

    test('should initialize with provided parameters', () {
      expect(viewModel.repository, mockRepository);
      expect(viewModel.mainPart, mockRobotPart);
      expect(viewModel.fragmentId, 'test-fragment-id');
      expect(viewModel.onPasswordSubmitted, mockOnPasswordSubmitted);
    });
  });

  group('passwordController and ssidController', () {
    test('should return correct password controller', () {
      expect(viewModel.passwordController, isA<TextEditingController>());
    });

    test('should return correct ssid controller', () {
      expect(viewModel.ssidController, isA<TextEditingController>());
    });

    test('should notify listeners when password controller changes', () {
      listenerCalled = false;
      viewModel.passwordController.text = 'test-password';
      expect(listenerCalled, true);
    });

    test('should notify listeners when ssid controller changes', () {
      listenerCalled = false;
      viewModel.ssidController.text = 'test-ssid';
      expect(listenerCalled, true);
    });
  });

  group('toggleObscureText', () {
    test('should initialize with false', () {
      expect(viewModel.obscureText, false);
    });

    test('should toggle from false to true', () {
      listenerCalled = false;
      viewModel.toggleObscureText();

      expect(viewModel.obscureText, true);
      expect(listenerCalled, true);
    });

    test('should toggle from true to false', () {
      viewModel.toggleObscureText(); // Set to true first
      expect(viewModel.obscureText, true);

      listenerCalled = false;
      viewModel.toggleObscureText();

      expect(viewModel.obscureText, false);
      expect(listenerCalled, true);
    });
  });

  group('setLoading', () {
    test('should initialize with false', () {
      expect(viewModel.loading, false);
    });

    test('should set loading to true', () {
      listenerCalled = false;
      viewModel.setLoading(true);

      expect(viewModel.loading, true);
      expect(listenerCalled, true);
    });

    test('should set loading to false', () {
      viewModel.setLoading(true); // Set to true first
      listenerCalled = false;
      viewModel.setLoading(false);

      expect(viewModel.loading, false);
      expect(listenerCalled, true);
    });

    test('should notify listeners when loading changes', () {
      listenerCalled = false;
      viewModel.setLoading(true);
      expect(listenerCalled, true);

      listenerCalled = false;
      viewModel.setLoading(false);
      expect(listenerCalled, true);
    });

    test('should be true during password submission', () async {
      when(mockRepository.getSmartMachineStatus()).thenAnswer((_) async => mockGetSmartMachineStatusResponse);
      when(mockRepository.setNetworkCredentials(
        type: anyNamed('type'),
        ssid: anyNamed('ssid'),
        psk: anyNamed('psk'),
      )).thenAnswer((_) async {});
      when(mockRepository.exitProvisioning()).thenAnswer((_) async {});

      viewModel.passwordController.text = 'test-password';
      final future = viewModel.submitCredentials();

      // Check that loading is true during submission
      expect(viewModel.loading, true);
      await future;
      // Check that loading is false after completion
      expect(viewModel.loading, false);
    });
  });

  group('network', () {
    test('should initialize with null network', () {
      expect(viewModel.network, isNull);
    });

    test('should set and get network correctly', () {
      listenerCalled = false;
      viewModel.network = mockNetwork;

      expect(viewModel.network, mockNetwork);
      expect(listenerCalled, true);
    });

    test('should clear network when set to null', () {
      viewModel.network = mockNetwork;
      expect(viewModel.network, mockNetwork);

      listenerCalled = false;
      viewModel.network = null;

      expect(viewModel.network, isNull);
      expect(listenerCalled, true);
    });
  });

  group('areNetworkCredentialsValid', () {
    test('should return false when network is null and ssid is empty', () {
      viewModel.network = null;
      viewModel.ssidController.text = '';
      viewModel.passwordController.text = '';

      expect(viewModel.areNetworkCredentialsValid, false);
    });

    test('should return true when network is null and ssid is not empty but password is empty', () {
      viewModel.network = null;
      viewModel.ssidController.text = 'test-ssid';
      viewModel.passwordController.text = '';

      expect(viewModel.areNetworkCredentialsValid, true);
    });

    test('should return true when network is null and both ssid and password are not empty', () {
      viewModel.network = null;
      viewModel.ssidController.text = 'test-ssid';
      viewModel.passwordController.text = 'test-password';

      expect(viewModel.areNetworkCredentialsValid, true);
    });

    test('should return true for public network with empty password', () {
      final publicNetwork = NetworkInfo(
        ssid: 'public-network',
        security: '-',
        signal: 80,
      );

      viewModel.network = publicNetwork;
      viewModel.passwordController.text = '';

      expect(viewModel.areNetworkCredentialsValid, true);
    });

    test('should return true for public network with non-empty password', () {
      // Note: This test validates that the validation logic allows passwords for public networks,
      // but the actual submission will ignore the password due to safeguards in submitPassword()
      final publicNetwork = NetworkInfo(
        ssid: 'public-network',
        security: '-',
        signal: 80,
      );

      viewModel.network = publicNetwork;
      viewModel.passwordController.text = 'some-password';

      expect(viewModel.areNetworkCredentialsValid, true);
    });

    test('should return false for private network with empty password', () {
      final privateNetwork = NetworkInfo(
        ssid: 'private-network',
        security: 'WPA2',
        signal: 80,
      );

      viewModel.network = privateNetwork;
      viewModel.passwordController.text = '';

      expect(viewModel.areNetworkCredentialsValid, false);
    });

    test('should return true for private network with non-empty password', () {
      final privateNetwork = NetworkInfo(
        ssid: 'private-network',
        security: 'WPA2',
        signal: 80,
      );

      viewModel.network = privateNetwork;
      viewModel.passwordController.text = 'test-password';

      expect(viewModel.areNetworkCredentialsValid, true);
    });
  });

  group('clearPassword', () {
    test('should clear password text', () {
      viewModel.passwordController.text = 'test-password';
      expect(viewModel.passwordController.text, 'test-password');

      viewModel.clearPassword();
      expect(viewModel.passwordController.text, isEmpty);
    });
  });

  group('isPublicNetwork', () {
    test('should return true for public network (security is "-")', () {
      final publicNetwork = NetworkInfo(
        ssid: 'public-network',
        security: '-',
        signal: 80,
      );

      expect(viewModel.isPublicNetwork(publicNetwork), true);
    });

    test('should return false for private network (security is not "-")', () {
      final privateNetwork = NetworkInfo(
        ssid: 'private-network',
        security: 'WPA2',
        signal: 80,
      );

      expect(viewModel.isPublicNetwork(privateNetwork), false);
    });

    test('should return false for WEP network', () {
      final wepNetwork = NetworkInfo(
        ssid: 'wep-network',
        security: 'WEP',
        signal: 60,
      );

      expect(viewModel.isPublicNetwork(wepNetwork), false);
    });

    test('should return false for WPA3 network', () {
      final wpa3Network = NetworkInfo(
        ssid: 'wpa3-network',
        security: 'WPA3',
        signal: 90,
      );

      expect(viewModel.isPublicNetwork(wpa3Network), false);
    });
  });

  group('submitPassword', () {
    test('should submit password successfully with network and agent version >= 0.20.0', () async {
      when(mockRepository.getSmartMachineStatus()).thenAnswer((_) async => mockGetSmartMachineStatusResponse);
      when(mockRepository.setNetworkCredentials(
        type: anyNamed('type'),
        ssid: anyNamed('ssid'),
        psk: anyNamed('psk'),
      )).thenAnswer((_) async {});
      when(mockRepository.exitProvisioning()).thenAnswer((_) async {});

      viewModel.network = mockNetwork;
      viewModel.passwordController.text = 'test-password';

      await viewModel.submitCredentials();

      verify(mockRepository.getSmartMachineStatus()).called(1);
      verify(mockRepository.setNetworkCredentials(
        type: NetworkType.wifi,
        ssid: mockNetwork.ssid,
        psk: 'test-password',
      )).called(1);
      verify(mockRepository.exitProvisioning()).called(1);
    });

    test('should submit password successfully with network and agent version < 0.20.0', () async {
      mockGetSmartMachineStatusResponse.agentVersion = '0.19.0';

      when(mockRepository.getSmartMachineStatus()).thenAnswer((_) async => mockGetSmartMachineStatusResponse);
      when(mockRepository.setNetworkCredentialsOnOldAgent(
        type: NetworkType.wifi,
        ssid: mockNetwork.ssid,
        psk: 'test-password',
      )).thenAnswer((_) async {});

      viewModel.network = mockNetwork;
      viewModel.passwordController.text = 'test-password';

      await viewModel.submitCredentials();

      verify(mockRepository.getSmartMachineStatus()).called(1);
      verify(mockRepository.setNetworkCredentialsOnOldAgent(
        type: anyNamed('type'),
        ssid: anyNamed('ssid'),
        psk: anyNamed('psk'),
      )).called(1);
      verifyNever(mockRepository.exitProvisioning());
    });

    test('should submit password successfully with SSID controller when network is null', () async {
      when(mockRepository.getSmartMachineStatus()).thenAnswer((_) async => mockGetSmartMachineStatusResponse);
      when(mockRepository.setNetworkCredentials(
        type: anyNamed('type'),
        ssid: anyNamed('ssid'),
        psk: anyNamed('psk'),
      )).thenAnswer((_) async {});
      when(mockRepository.exitProvisioning()).thenAnswer((_) async {});

      viewModel.network = null;
      viewModel.ssidController.text = mockNetwork.ssid;
      viewModel.passwordController.text = 'test-password';

      await viewModel.submitCredentials();

      verify(mockRepository.setNetworkCredentials(
        type: NetworkType.wifi,
        ssid: mockNetwork.ssid,
        psk: 'test-password',
      )).called(1);
    });

    test('should submit empty password for public network', () async {
      when(mockRepository.getSmartMachineStatus()).thenAnswer((_) async => mockGetSmartMachineStatusResponse);
      when(mockRepository.setNetworkCredentials(
        type: anyNamed('type'),
        ssid: anyNamed('ssid'),
        psk: anyNamed('psk'),
      )).thenAnswer((_) async {});
      when(mockRepository.exitProvisioning()).thenAnswer((_) async {});

      final publicNetwork = NetworkInfo(
        ssid: 'public-network',
        security: '-',
        signal: 80,
      );

      viewModel.network = publicNetwork;
      viewModel.passwordController.text = 'some-password'; // This should be ignored

      await viewModel.submitCredentials();

      verify(mockRepository.setNetworkCredentials(
        type: NetworkType.wifi,
        ssid: 'public-network',
        psk: '',
      )).called(1);
    });

    test('should set smart machine credentials when not already set', () async {
      mockGetSmartMachineStatusResponse.hasSmartMachineCredentials = false;

      when(mockRepository.getSmartMachineStatus()).thenAnswer((_) async => mockGetSmartMachineStatusResponse);
      when(mockRepository.setSmartMachineCredentials(
        id: anyNamed('id'),
        secret: anyNamed('secret'),
      )).thenAnswer((_) async {});
      when(mockRepository.setNetworkCredentials(
        type: anyNamed('type'),
        ssid: anyNamed('ssid'),
        psk: anyNamed('psk'),
      )).thenAnswer((_) async {});
      when(mockRepository.exitProvisioning()).thenAnswer((_) async {});

      viewModel.passwordController.text = 'test-password';

      await viewModel.submitCredentials();

      verify(mockRepository.setSmartMachineCredentials(
        id: 'test-part-id',
        secret: 'test-secret',
      )).called(1);
    });

    test('should use provided fragmentId when available', () async {
      when(mockRepository.getSmartMachineStatus()).thenAnswer((_) async => mockGetSmartMachineStatusResponse);
      when(mockRepository.setNetworkCredentials(
        type: anyNamed('type'),
        ssid: anyNamed('ssid'),
        psk: anyNamed('psk'),
      )).thenAnswer((_) async {});
      when(mockRepository.exitProvisioning()).thenAnswer((_) async {});

      viewModel.passwordController.text = 'test-password';

      await viewModel.submitCredentials();

      expect(viewModel.fragmentIdToWrite, 'test-fragment-id');
      verify(mockRepository.getSmartMachineStatus()).called(1);
    });

    test('should use agent fragmentId when provided fragmentId is null', () async {
      // Create a new view model with null fragmentId
      final viewModelWithNullFragment = PasswordInputViewModel(
        repository: mockRepository,
        mainPart: mockRobotPart,
        fragmentId: null,
        onPasswordSubmitted: mockOnPasswordSubmitted,
      );

      when(mockRepository.getSmartMachineStatus()).thenAnswer((_) async => mockGetSmartMachineStatusResponse);
      when(mockRepository.setNetworkCredentials(
        type: anyNamed('type'),
        ssid: anyNamed('ssid'),
        psk: anyNamed('psk'),
      )).thenAnswer((_) async {});
      when(mockRepository.exitProvisioning()).thenAnswer((_) async {});

      viewModelWithNullFragment.passwordController.text = 'test-password';

      await viewModelWithNullFragment.submitCredentials();

      expect(viewModelWithNullFragment.fragmentIdToWrite, 'agent-fragment-id');
      verify(mockRepository.getSmartMachineStatus()).called(1);

      viewModelWithNullFragment.dispose();
    });
    test('should trim password and SSID values', () async {
      when(mockRepository.getSmartMachineStatus()).thenAnswer((_) async => mockGetSmartMachineStatusResponse);
      when(mockRepository.setNetworkCredentials(
        type: anyNamed('type'),
        ssid: anyNamed('ssid'),
        psk: anyNamed('psk'),
      )).thenAnswer((_) async {});
      when(mockRepository.exitProvisioning()).thenAnswer((_) async {});

      viewModel.network = null;
      viewModel.ssidController.text = '  test-ssid  ';
      viewModel.passwordController.text = '  test-password  ';

      await viewModel.submitCredentials();

      verify(mockRepository.setNetworkCredentials(
        type: NetworkType.wifi,
        ssid: 'test-ssid',
        psk: 'test-password',
      )).called(1);
    });

    test('should handle repository errors and rethrow', () async {
      when(mockRepository.getSmartMachineStatus()).thenThrow(Exception('Network error'));

      viewModel.passwordController.text = 'test-password';

      try {
        await viewModel.submitCredentials();
        fail('Expected exception to be thrown');
      } catch (e) {
        expect(e, isA<Exception>());
      }

      // Ensure loading is reset even after error
      expect(viewModel.loading, false);
    });

    test('should handle setNetworkCredentials errors and rethrow', () async {
      when(mockRepository.getSmartMachineStatus()).thenAnswer((_) async => mockGetSmartMachineStatusResponse);
      when(mockRepository.setNetworkCredentials(
        type: anyNamed('type'),
        ssid: anyNamed('ssid'),
        psk: anyNamed('psk'),
      )).thenThrow(Exception('Network credentials error'));

      viewModel.passwordController.text = 'test-password';

      try {
        await viewModel.submitCredentials();
        fail('Expected exception to be thrown');
      } catch (e) {
        expect(e, isA<Exception>());
      }

      // Ensure loading is reset even after error
      expect(viewModel.loading, false);
    });

    test('should handle exitProvisioning errors and rethrow', () async {
      when(mockRepository.getSmartMachineStatus()).thenAnswer((_) async => mockGetSmartMachineStatusResponse);
      when(mockRepository.setNetworkCredentials(
        type: anyNamed('type'),
        ssid: anyNamed('ssid'),
        psk: anyNamed('psk'),
      )).thenAnswer((_) async {});
      when(mockRepository.exitProvisioning()).thenThrow(Exception('Exit provisioning error'));

      viewModel.passwordController.text = 'test-password';

      try {
        await viewModel.submitCredentials();
        fail('Expected exception to be thrown');
      } catch (e) {
        expect(e, isA<Exception>());
      }

      // Ensure loading is reset even after error
      expect(viewModel.loading, false);
    });
  });
}
