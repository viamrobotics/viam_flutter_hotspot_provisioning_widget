import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';
import 'package:viam_sdk/src/gen/google/protobuf/struct.pb.dart';

import '../../mocks/generate_mocks.mocks.dart';

void main() {
  late ConfirmationViewModel confirmationViewModel;
  late MockHotspotProvisioningRepository mockHotspotProvisioningRepository;

  final mockRobotPart = RobotPart(
    id: 'test-part-id',
    name: 'test-robot-name',
    locationId: 'test-location-id',
    robotConfig: Struct(fields: {
      'test-key': Value(stringValue: 'test-value'),
    }),
  );

  // final mockRobotConfig = {
  //   'test-key': 'test-value',
  // };

  final mockRobot = Robot(id: mockRobotPart.id, name: mockRobotPart.name, location: mockRobotPart.locationId);

  setUp(() {
    mockHotspotProvisioningRepository = MockHotspotProvisioningRepository();

    confirmationViewModel = ConfirmationViewModel(
      repository: mockHotspotProvisioningRepository,
      robot: mockRobot,
      mainPart: mockRobotPart,
      fragmentId: 'test-fragment-id',
      overrideFragment: true,
      replaceHardware: true,
    );
  });

  group('startCheckingOnline', () {
    test('should emit loading status immediately when called', () async {
      // Arrange
      when(mockHotspotProvisioningRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
      when(mockHotspotProvisioningRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);

      // Act & Assert
      expectLater(
        confirmationViewModel.machineStatusStream,
        emitsInOrder([MachineStatus.loading]),
      );

      confirmationViewModel.startCheckingOnline();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('should emit online status and close stream when robot comes online', () async {
      // Arrange
      when(mockHotspotProvisioningRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
      when(mockHotspotProvisioningRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.online);

      // Act & Assert
      expectLater(
        confirmationViewModel.machineStatusStream,
        emitsInOrder([
          MachineStatus.loading,
          MachineStatus.online,
        ]),
      );

      confirmationViewModel.startCheckingOnline();
      await Future.delayed(const Duration(seconds: 6));

      // Verify repository calls
      verify(mockHotspotProvisioningRepository.getRobot(mockRobot.id)).called(1);
      verify(mockHotspotProvisioningRepository.calculateMachineStatus(mockRobot)).called(1);
    });

    test('should emit loading status when repository throws error', () async {
      // Arrange
      when(mockHotspotProvisioningRepository.getRobot(any)).thenThrow(Exception('Network error'));

      // Act & Assert
      expectLater(
        confirmationViewModel.machineStatusStream,
        emitsInOrder([
          MachineStatus.loading,
          MachineStatus.loading, // After error
        ]),
      );

      confirmationViewModel.startCheckingOnline();
      await Future.delayed(const Duration(seconds: 6));

      // Verify repository was called
      verify(mockHotspotProvisioningRepository.getRobot(mockRobot.id)).called(1);
    });

    test('should emit loading then offline when timeout occurs', () async {
      // Arrange
      when(mockHotspotProvisioningRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
      when(mockHotspotProvisioningRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);

      // Act & Assert
      expectLater(
        confirmationViewModel.machineStatusStream,
        emitsInOrder([
          MachineStatus.loading,
          MachineStatus.offline,
        ]),
      );

      confirmationViewModel.startCheckingOnline();

      // Wait for timer to be set up and verify it exists
      await Future.delayed(const Duration(milliseconds: 100));
      expect(confirmationViewModel.timer, isNotNull);
      expect(confirmationViewModel.timer!.isActive, isTrue);
    });

    test('should create timer when function is called', () async {
      // Arrange
      confirmationViewModel.machineStatusStream.listen((_) {});

      // Act
      confirmationViewModel.startCheckingOnline();

      // Assert
      expect(confirmationViewModel.timer, isNotNull);
      expect(confirmationViewModel.timer!.isActive, isTrue);

      // Clean up
      confirmationViewModel.timer?.cancel();
    });
  });

  group('disconnectFromHotspot', () {
    test('', () {});
  });

  group('performFragmentOverride', () {
    test('', () {});
  });

  group('applyRobotConfig', () {
    test('', () {});
  });

  group('dispose', () {
    test('', () {});
  });

  group('_addMachineStatus', () {
    test('', () {});
  });

  group('_closeMachineStatusStream', () {
    test('', () {});
  });
}
