import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';
import 'package:viam_sdk/src/gen/google/protobuf/struct.pb.dart';
import 'package:viam_sdk/src/gen/google/protobuf/timestamp.pb.dart';

import '../../mocks/generate_mocks.mocks.dart';

void main() {
  late HotspotProvisioningRepository hotspotProvisioningRepository;
  late MockViam mockViam;
  late MockProvisioningClient mockProvisioningClient;
  late MockAppClient mockAppClient;
  late MockPluginWifiConnectService mockPluginWifiConnectService;
  late MockPermissionService mockPermissionService;

  final mockRobotPart = RobotPart(
    id: 'test-part-id',
    name: 'test-robot-name',
    locationId: 'test-location-id',
    robotConfig: Struct(fields: {
      'test-key': Value(stringValue: 'test-value'),
    }),
  );

  final mockRobotPartConfig = {
    'test-key': 'test-value',
  };

  final mockRobot = Robot(id: mockRobotPart.id, name: mockRobotPart.name, location: mockRobotPart.locationId);

  setUp(() {
    mockViam = MockViam();
    mockProvisioningClient = MockProvisioningClient();
    mockAppClient = MockAppClient();
    mockPluginWifiConnectService = MockPluginWifiConnectService();
    mockPermissionService = MockPermissionService();
    hotspotProvisioningRepository =
        HotspotProvisioningRepository(viam: mockViam, pluginWifiConnectService: mockPluginWifiConnectService, permissionService: mockPermissionService);

    when(mockViam.provisioningClient).thenReturn(mockProvisioningClient);
    when(mockViam.appClient).thenReturn(mockAppClient);
  });

  group('getSmartMachineStatus', () {
    test('getSmartMachineStatus returns a GetSmartMachineStatusResponse', () async {
      when(mockProvisioningClient.getSmartMachineStatus()).thenAnswer((_) async => GetSmartMachineStatusResponse());
      final response = await hotspotProvisioningRepository.getSmartMachineStatus();
      expect(response, isA<GetSmartMachineStatusResponse>());
    });

    test('throws an exception if the getSmartMachineStatus call fails', () async {
      when(mockProvisioningClient.getSmartMachineStatus()).thenAnswer((_) async => throw Exception('Failed to get smart machine status'));
      expect(() => hotspotProvisioningRepository.getSmartMachineStatus(), throwsA(isA<Exception>()));
    });
  });

  group('setSmartMachineCredentials', () {
    test('setSmartMachineCredentials calls the setSmartMachineCredentials method on the provisioning client', () async {
      when(mockProvisioningClient.setSmartMachineCredentials(
        id: anyNamed('id'),
        secret: anyNamed('secret'),
      )).thenAnswer((_) async {});

      await hotspotProvisioningRepository.setSmartMachineCredentials(
        id: 'test-id',
        secret: 'test-secret',
      );

      verify(mockProvisioningClient.setSmartMachineCredentials(
        id: 'test-id',
        secret: 'test-secret',
      )).called(1);
    });

    test('throws an exception if the setSmartMachineCredentials call fails', () async {
      when(mockProvisioningClient.setSmartMachineCredentials(
        id: anyNamed('id'),
        secret: anyNamed('secret'),
      )).thenAnswer((_) async => throw Exception('Failed to set credentials'));

      expect(
        () => hotspotProvisioningRepository.setSmartMachineCredentials(
          id: 'test-id',
          secret: 'test-secret',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('setNetworkCredentials', () {
    test('setNetworkCredentials calls the setNetworkCredentials method on the provisioning client', () async {
      when(mockProvisioningClient.setNetworkCredentials(
        type: anyNamed('type'),
        ssid: anyNamed('ssid'),
        psk: anyNamed('psk'),
      )).thenAnswer((_) async {});

      await hotspotProvisioningRepository.setNetworkCredentials(
        type: NetworkType.wifi,
        ssid: 'test-ssid',
        psk: 'test-psk',
      );

      verify(mockProvisioningClient.setNetworkCredentials(
        type: NetworkType.wifi,
        ssid: 'test-ssid',
        psk: 'test-psk',
      )).called(1);
    });

    test('throws an exception if the setNetworkCredentials call fails', () async {
      when(mockProvisioningClient.setNetworkCredentials(
        type: anyNamed('type'),
        ssid: anyNamed('ssid'),
        psk: anyNamed('psk'),
      )).thenAnswer((_) async => throw Exception('Failed to set network credentials'));

      expect(
        () => hotspotProvisioningRepository.setNetworkCredentials(
          type: NetworkType.wifi,
          ssid: 'test-ssid',
          psk: 'test-psk',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
  group('exitProvisioning', () {
    test('exitProvisioning calls the exitProvisioning method on the provisioning client', () async {
      when(mockProvisioningClient.exitProvisioning()).thenAnswer((_) async {});

      await hotspotProvisioningRepository.exitProvisioning();

      verify(mockProvisioningClient.exitProvisioning()).called(1);
    });

    test('throws an exception if the exitProvisioning call fails', () async {
      when(mockProvisioningClient.exitProvisioning()).thenAnswer((_) async => throw Exception('Failed to exit provisioning'));

      expect(
        () => hotspotProvisioningRepository.exitProvisioning(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getNetworkList', () {
    test('getNetworkList calls the getNetworkList method on the provisioning client', () async {
      final fakeNetworkList = [
        NetworkInfo(ssid: 'test-ssid-11', signal: 100, security: 'test-security'),
        NetworkInfo(ssid: 'test-ssid-2', signal: 90, security: 'test-security-2'),
        NetworkInfo(ssid: 'test-ssid-3', signal: 80, security: 'test-security-3'),
      ];

      when(mockProvisioningClient.getNetworkList()).thenAnswer((_) async => fakeNetworkList);

      final response = await hotspotProvisioningRepository.getNetworkList();
      expect(response, isA<List<NetworkInfo>>());
    });

    test('throws an exception if the getNetworkList call fails', () async {
      when(mockProvisioningClient.getNetworkList()).thenAnswer((_) async => throw Exception('Failed to get network list'));

      expect(() => hotspotProvisioningRepository.getNetworkList(), throwsA(isA<Exception>()));
    });
  });

  group('getCurrentSSID', () {
    // TODO: Add tests for functions that rely on PluginWifiConnect
  });

  group('connectToSecureNetworkByPrefix', () {
    // TODO: Add tests for functions that rely on PluginWifiConnect
  });

  group('disconnect', () {
    // TODO: Add tests for functions that rely on PluginWifiConnect
  });

  group('requestLocationPermission', () {
    // TODO: Add tests for functions that rely on permission_handler
  });
  group('getLocationPermission', () {
    // TODO: Add tests for functions that rely on permission_handler
  });

  group('updateRobotPart', () {
    test('updateRobotPart calls the updateRobotPart method on the app client', () async {
      when(mockAppClient.updateRobotPart(mockRobotPart.id, mockRobotPart.name, mockRobotPartConfig)).thenAnswer((_) async => mockRobotPart);

      await hotspotProvisioningRepository.updateRobotPart(
          partId: mockRobotPart.id, robotName: mockRobotPart.name, config: mockRobotPartConfig);

      verify(mockAppClient.updateRobotPart(mockRobotPart.id, mockRobotPart.name, mockRobotPartConfig)).called(1);
    });
    test('throws an exception if the updateRobotPart call fails', () async {
      when(mockAppClient.updateRobotPart(mockRobotPart.id, mockRobotPart.name, mockRobotPartConfig))
          .thenAnswer((_) async => throw Exception('Failed to update robot part'));

      expect(
          () => hotspotProvisioningRepository.updateRobotPart(
                partId: 'test-part-id',
                robotName: 'test-robot-name',
                config: {'test-key': 'test-value'},
              ),
          throwsA(isA<Exception>()));
    });
  });

  group('getRobot', () {
    test('getRobot calls the getRobot method on the app client', () async {
      when(mockAppClient.getRobot(mockRobot.id)).thenAnswer((_) async => mockRobot);

      final response = await hotspotProvisioningRepository.getRobot(mockRobot.id);
      expect(response, isA<Robot>());
      expect(response.id, mockRobot.id);
      expect(response.name, mockRobot.name);
      expect(response.location, mockRobot.location);
    });
    test('throws an exception if the getRobot call fails', () async {
      when(mockAppClient.getRobot(mockRobot.id)).thenAnswer((_) async => throw Exception('Failed to get robot'));

      expect(() => hotspotProvisioningRepository.getRobot(mockRobot.id), throwsA(isA<Exception>()));
    });
  });

  group('calculateMachineStatus', () {
    test('calculateMachineStatus returns a MachineStatus.online if the robot was accessed in the last 10 seconds', () async {
      mockRobot.lastAccess = Timestamp.fromDateTime(DateTime.now().subtract(Duration(seconds: 5)));
      final response = await hotspotProvisioningRepository.calculateMachineStatus(mockRobot);
      expect(response, MachineStatus.online);
    });
    test('calculateMachineStatus returns a MachineStatus.loading if the robot was not accessed in the last 10 seconds', () async {
      mockRobot.lastAccess = Timestamp.fromDateTime(DateTime.now().subtract(Duration(seconds: 11)));
      final response = await hotspotProvisioningRepository.calculateMachineStatus(mockRobot);
      expect(response, MachineStatus.loading);
    });
  });
}
