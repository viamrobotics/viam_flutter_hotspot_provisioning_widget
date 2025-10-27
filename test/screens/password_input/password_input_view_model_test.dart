import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';
import 'package:viam_sdk/viam_sdk.dart';
import 'package:viam_sdk/protos/app/app.dart';

import '../../mocks/generate_mocks.mocks.dart';

void main() {
  late MockHotspotProvisioningRepository mockRepository;
  late RobotPart mockRobotPart;
  late PasswordInputViewModel viewModel;
  late Function(String? fragmentId) mockOnPasswordSubmitted;
  bool listenerCalled = false;

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

    final mockResponse = GetSmartMachineStatusResponse();
    mockResponse.hasSmartMachineCredentials = true;
    mockResponse.agentVersion = '0.20.0';
    mockResponse.provisioningInfo = ProvisioningInfo();
    mockResponse.provisioningInfo.fragmentId = 'agent-fragment-id';

    // when(mockRepository.getSmartMachineStatus()).thenAnswer((_) async => mockResponse);
    // when(mockRepository.setSmartMachineCredentials(
    //   id: anyNamed('id'),
    //   secret: anyNamed('secret'),
    // )).thenAnswer((_) async {});
    // when(mockRepository.setNetworkCredentials(
    //   type: anyNamed('type'),
    //   ssid: anyNamed('ssid'),
    //   psk: anyNamed('psk'),
    // )).thenAnswer((_) async {});
    // when(mockRepository.exitProvisioning()).thenAnswer((_) async {});
  });

// spend more time thinking thru this
  // tearDown(() {
  //   viewModel.dispose();
  // });

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
      viewModel.passwordController.text = 'test-password';

      final future = viewModel.submitPassword();

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
      final testNetwork = NetworkInfo(
        ssid: 'test-network',
        security: 'WPA2',
        signal: 80,
      );

      listenerCalled = false;
      viewModel.network = testNetwork;

      expect(viewModel.network, testNetwork);
      expect(listenerCalled, true);
    });

    test('should clear network when set to null', () {
      final testNetwork = NetworkInfo(
        ssid: 'test-network',
        security: 'WPA2',
        signal: 80,
      );

      viewModel.network = testNetwork;
      expect(viewModel.network, testNetwork);

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

  // need to test submit password and think thru edge cases
}
