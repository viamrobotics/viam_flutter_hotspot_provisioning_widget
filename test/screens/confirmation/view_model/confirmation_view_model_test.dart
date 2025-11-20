import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';
import 'package:viam_sdk/src/gen/google/protobuf/struct.pb.dart';

import '../../../mocks/generate_mocks.mocks.dart';

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

  final mockRobotConfig = {
    'test-key': 'test-value',
  };

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
      robotConfig: null,
    );
  });

  group('startCheckingOnline', () {
    test('should emit loading status immediately when called', () async {
      when(mockHotspotProvisioningRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
      when(mockHotspotProvisioningRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);

      expectLater(
        confirmationViewModel.machineStatusStream,
        emitsInOrder([MachineStatus.loading]),
      );

      confirmationViewModel.startCheckingOnline();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('should emit online status and close stream when robot comes online', () async {
      when(mockHotspotProvisioningRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
      when(mockHotspotProvisioningRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.online);

      expectLater(
        confirmationViewModel.machineStatusStream,
        emitsInOrder([
          MachineStatus.loading,
          MachineStatus.online,
        ]),
      );

      confirmationViewModel.startCheckingOnline();
      await Future.delayed(const Duration(seconds: 6));

      verify(mockHotspotProvisioningRepository.getRobot(mockRobot.id)).called(1);
      verify(mockHotspotProvisioningRepository.calculateMachineStatus(mockRobot)).called(1);
    });

    test('should emit loading status when repository throws error', () async {
      when(mockHotspotProvisioningRepository.getRobot(any)).thenThrow(Exception('Network error'));

      expectLater(
        confirmationViewModel.machineStatusStream,
        emitsInOrder([
          MachineStatus.loading,
          MachineStatus.loading,
        ]),
      );

      confirmationViewModel.startCheckingOnline();
      await Future.delayed(const Duration(seconds: 6));

      verify(mockHotspotProvisioningRepository.getRobot(mockRobot.id)).called(1);
    });

    test('should emit loading then offline when timeout occurs', () async {
      // Mock a shorter timeout for testing
      ConfirmationViewModel.provisioningTimeoutSeconds = 5;

      when(mockHotspotProvisioningRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
      when(mockHotspotProvisioningRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);

      expectLater(
        confirmationViewModel.machineStatusStream,
        emitsInOrder([
          MachineStatus.loading,
          MachineStatus.offline,
        ]),
      );

      confirmationViewModel.startCheckingOnline();
      await Future.delayed(const Duration(seconds: 6));
    });

    test('should create timer when function is called', () async {
      confirmationViewModel.machineStatusStream.listen((_) {});

      confirmationViewModel.startCheckingOnline();

      expect(confirmationViewModel.timer, isNotNull);
      expect(confirmationViewModel.timer!.isActive, isTrue);

      confirmationViewModel.timer?.cancel();
    });
  });

  group('disconnectFromHotspot', () {
    test('should wait 5 seconds and call repository disconnect', () async {
      when(mockHotspotProvisioningRepository.disconnect()).thenAnswer((_) async => true);

      final result = await confirmationViewModel.disconnectFromHotspot();

      expect(result, isTrue);
      verify(mockHotspotProvisioningRepository.disconnect()).called(1);
    });

    test('should return false when repository disconnect fails', () async {
      when(mockHotspotProvisioningRepository.disconnect()).thenAnswer((_) async => false);

      final result = await confirmationViewModel.disconnectFromHotspot();

      expect(result, isFalse);
      verify(mockHotspotProvisioningRepository.disconnect()).called(1);
    });
  });

  group('performFragmentOverride', () {
    test('should update robot part with fragment when fragmentId is provided', () async {
      // The confirmationViewModel is initialized with a fragmentId in setUp() above
      when(mockHotspotProvisioningRepository.updateRobotPart(
        partId: anyNamed('partId'),
        robotName: anyNamed('robotName'),
        config: anyNamed('config'),
      )).thenAnswer((_) async {});

      await confirmationViewModel.performFragmentOverride();

      verify(mockHotspotProvisioningRepository.updateRobotPart(
        partId: mockRobotPart.id,
        robotName: mockRobot.name,
        config: {
          'fragments': ['test-fragment-id']
        },
      )).called(1);
    });

    test('should not update robot part when fragmentId is null', () async {
      final viewModelWithNullFragment = ConfirmationViewModel(
        repository: mockHotspotProvisioningRepository,
        robot: mockRobot,
        mainPart: mockRobotPart,
        fragmentId: null,
        overrideFragment: true,
        replaceHardware: true,
      );

      await viewModelWithNullFragment.performFragmentOverride();

      verifyNever(mockHotspotProvisioningRepository.updateRobotPart(
        partId: anyNamed('partId'),
        robotName: anyNamed('robotName'),
        config: anyNamed('config'),
      ));
    });

    test('should not update robot part when fragmentId is empty', () async {
      final viewModelWithEmptyFragment = ConfirmationViewModel(
        repository: mockHotspotProvisioningRepository,
        robot: mockRobot,
        mainPart: mockRobotPart,
        fragmentId: '',
        overrideFragment: true,
        replaceHardware: true,
      );

      await viewModelWithEmptyFragment.performFragmentOverride();

      verifyNever(mockHotspotProvisioningRepository.updateRobotPart(
        partId: anyNamed('partId'),
        robotName: anyNamed('robotName'),
        config: anyNamed('config'),
      ));
    });
  });

  group('applyRobotConfig', () {
    test('should update robot part with robot config when config is provided', () async {
      final viewModelWithConfig = ConfirmationViewModel(
        repository: mockHotspotProvisioningRepository,
        robot: mockRobot,
        mainPart: mockRobotPart,
        fragmentId: 'test-fragment-id',
        overrideFragment: true,
        replaceHardware: true,
        robotConfig: mockRobotConfig,
      );

      when(mockHotspotProvisioningRepository.updateRobotPart(
        partId: anyNamed('partId'),
        robotName: anyNamed('robotName'),
        config: anyNamed('config'),
      )).thenAnswer((_) async {});

      await viewModelWithConfig.applyRobotConfig();

      verify(mockHotspotProvisioningRepository.updateRobotPart(
        partId: mockRobotPart.id,
        robotName: mockRobotPart.name,
        config: mockRobotConfig,
      )).called(1);
    });

    test('should not update robot part when robotConfig is null', () async {
      // The confirmationViewModel is initialized with robotConfig: null in setUp()
      await confirmationViewModel.applyRobotConfig();

      verifyNever(mockHotspotProvisioningRepository.updateRobotPart(
        partId: anyNamed('partId'),
        robotName: anyNamed('robotName'),
        config: anyNamed('config'),
      ));
    });

    test('should handle repository errors gracefully', () async {
      final viewModelWithConfig = ConfirmationViewModel(
        repository: mockHotspotProvisioningRepository,
        robot: mockRobot,
        mainPart: mockRobotPart,
        fragmentId: 'test-fragment-id',
        overrideFragment: true,
        replaceHardware: true,
        robotConfig: mockRobotConfig,
      );

      when(mockHotspotProvisioningRepository.updateRobotPart(
        partId: anyNamed('partId'),
        robotName: anyNamed('robotName'),
        config: anyNamed('config'),
      )).thenThrow(Exception('Update failed'));

      // Should not throw exception
      await viewModelWithConfig.applyRobotConfig();

      verify(mockHotspotProvisioningRepository.updateRobotPart(
        partId: mockRobotPart.id,
        robotName: mockRobotPart.name,
        config: mockRobotConfig,
      )).called(1);
    });
  });

  group('dispose', () {
    test('should close machine status stream', () async {
      bool streamClosed = false;
      confirmationViewModel.machineStatusStream.listen(
        (status) {},
        onDone: () => streamClosed = true,
      );

      confirmationViewModel.dispose();

      // Wait for the stream to close
      await Future.delayed(const Duration(milliseconds: 100));
      expect(streamClosed, isTrue);
    });
  });

  group('addMachineStatus', () {
    test('should emit status to stream', () async {
      expectLater(
        confirmationViewModel.machineStatusStream,
        emits(MachineStatus.online),
      );

      confirmationViewModel.addMachineStatus(MachineStatus.online);
    });
  });

  group('closeMachineStatusStream', () {
    test('should cancel timer and close stream', () async {
      confirmationViewModel.startCheckingOnline();

      bool streamClosed = false;
      confirmationViewModel.machineStatusStream.listen(
        (status) {},
        onDone: () => streamClosed = true,
      );

      confirmationViewModel.closeMachineStatusStream();
      // Wait a bit for the stream to close
      await Future.delayed(const Duration(milliseconds: 100));
      expect(streamClosed, isTrue);
      expect(confirmationViewModel.timer?.isActive, isFalse);
    });
  });
}
