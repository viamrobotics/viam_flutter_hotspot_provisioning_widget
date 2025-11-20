import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';
import 'package:viam_sdk/src/gen/google/protobuf/struct.pb.dart';

import '../../../mocks/generate_mocks.mocks.dart';

void main() {
  late ConfirmationViewModel viewModel;
  late MockHotspotProvisioningRepository mockRepository;
  late RobotPart mockRobotPart;
  late Robot mockRobot;
  late Function(Robot robot, MachineStatus status) mockOnStatusDetermined;

  setUp(() {
    mockRepository = MockHotspotProvisioningRepository();
    mockRobotPart = RobotPart(
      id: 'test-part-id',
      name: 'test-robot-name',
      secret: 'test-secret',
      locationId: 'test-location-id',
      robotConfig: Struct(fields: {
        'test-key': Value(stringValue: 'test-value'),
      }),
    );
    mockRobot = Robot(id: mockRobotPart.id, name: mockRobotPart.name, location: mockRobotPart.locationId);
    mockOnStatusDetermined = (Robot robot, MachineStatus status) {};
    viewModel = ConfirmationViewModel(
      repository: mockRepository,
      robot: mockRobot,
      mainPart: mockRobotPart,
      fragmentId: 'test-fragment-id',
      overrideFragment: false,
      replaceHardware: false,
      robotConfig: null,
    );

    when(mockRepository.disconnect()).thenAnswer((_) async => true);
    when(mockRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
    when(mockRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);
  });

  tearDown(() {
    viewModel.dispose();
  });

  Widget confirmationScreenWidget({
    required ConfirmationViewModel viewModel,
    Function(Robot robot, MachineStatus status)? onStatusDetermined,
  }) {
    return MaterialApp(
      home: ConfirmationScreen(
        viewModel: viewModel,
        onStatusDetermined: onStatusDetermined ?? mockOnStatusDetermined,
      ),
    );
  }

  Future<void> cleanup(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 6));
  }

  group('ConfirmationScreen', () {
    testWidgets('calls startCheckingOnline in initState', (WidgetTester tester) async {
      await tester.pumpWidget(confirmationScreenWidget(viewModel: viewModel));

      expect(viewModel.timer, isNotNull);
      expect(viewModel.timer!.isActive, isTrue);

      await cleanup(tester);
    });

    testWidgets('disposes viewModel when widget is disposed', (WidgetTester tester) async {
      bool streamClosed = false;
      viewModel.machineStatusStream.listen(
        (status) {},
        onDone: () => streamClosed = true,
      );

      await tester.pumpWidget(confirmationScreenWidget(viewModel: viewModel));
      await tester.pumpWidget(Container());

      expect(streamClosed, isTrue);
      await cleanup(tester);
    });

    group('when status is loading', () {
      testWidgets('displays RobotLoadingWidget when snapshot has no data', (WidgetTester tester) async {
        await tester.pumpWidget(confirmationScreenWidget(viewModel: viewModel));

        expect(find.byType(RobotLoadingWidget), findsOneWidget);

        await cleanup(tester);
      });

      testWidgets('displays RobotLoadingWidget when status is loading', (WidgetTester tester) async {
        viewModel.addMachineStatus(MachineStatus.loading);
        await tester.pumpWidget(confirmationScreenWidget(viewModel: viewModel));

        expect(find.byType(RobotLoadingWidget), findsOneWidget);

        await cleanup(tester);
      });
    });

    group('when status is online', () {
      testWidgets('calls onStatusDetermined', (WidgetTester tester) async {
        bool onStatusDeterminedCalled = false;
        Robot? receivedRobot;
        MachineStatus? receivedStatus;

        void testOnStatusDetermined(Robot robot, MachineStatus status) {
          onStatusDeterminedCalled = true;
          receivedRobot = robot;
          receivedStatus = status;
        }

        await tester.pumpWidget(confirmationScreenWidget(
          viewModel: viewModel,
          onStatusDetermined: testOnStatusDetermined,
        ));

        viewModel.addMachineStatus(MachineStatus.online);
        await tester.pump();

        expect(onStatusDeterminedCalled, isTrue);
        expect(receivedRobot, equals(mockRobot));
        expect(receivedStatus, equals(MachineStatus.online));

        await cleanup(tester);
      });

      testWidgets('displays SizedBox.shrink after callback', (WidgetTester tester) async {
        await tester.pumpWidget(confirmationScreenWidget(viewModel: viewModel));

        viewModel.addMachineStatus(MachineStatus.online);
        await tester.pump();

        expect(find.byType(SizedBox), findsWidgets);

        await cleanup(tester);
      });

      testWidgets('calls performFragmentOverride when overrideFragment is true', (WidgetTester tester) async {
        when(mockRepository.updateRobotPart(
          partId: anyNamed('partId'),
          robotName: anyNamed('robotName'),
          config: anyNamed('config'),
        )).thenAnswer((_) async {});

        final viewModelWithOverride = ConfirmationViewModel(
          repository: mockRepository,
          robot: mockRobot,
          mainPart: mockRobotPart,
          fragmentId: 'test-fragment-id',
          overrideFragment: true,
          replaceHardware: false,
          robotConfig: null,
        );

        await tester.pumpWidget(confirmationScreenWidget(viewModel: viewModelWithOverride));

        viewModelWithOverride.addMachineStatus(MachineStatus.online);
        await tester.pump();

        verify(mockRepository.updateRobotPart(
          partId: mockRobotPart.id,
          robotName: mockRobot.name,
          config: {
            'fragments': ['test-fragment-id']
          },
        )).called(1);

        viewModelWithOverride.dispose();
        await cleanup(tester);
      });

      testWidgets('calls applyRobotConfig when replaceHardware is true', (WidgetTester tester) async {
        when(mockRepository.updateRobotPart(
          partId: anyNamed('partId'),
          robotName: anyNamed('robotName'),
          config: anyNamed('config'),
        )).thenAnswer((_) async {});

        final mockRobotConfig = {'test-key': 'test-value'};
        final viewModelWithReplace = ConfirmationViewModel(
          repository: mockRepository,
          robot: mockRobot,
          mainPart: mockRobotPart,
          fragmentId: 'test-fragment-id',
          overrideFragment: false,
          replaceHardware: true,
          robotConfig: mockRobotConfig,
        );

        await tester.pumpWidget(confirmationScreenWidget(viewModel: viewModelWithReplace));

        viewModelWithReplace.addMachineStatus(MachineStatus.online);
        await tester.pump();

        verify(mockRepository.updateRobotPart(
          partId: mockRobotPart.id,
          robotName: mockRobotPart.name,
          config: mockRobotConfig,
        )).called(1);

        viewModelWithReplace.dispose();
        await cleanup(tester);
      });
    });

    group('when status is offline', () {
      testWidgets('calls onStatusDetermined', (WidgetTester tester) async {
        bool onStatusDeterminedCalled = false;
        Robot? receivedRobot;
        MachineStatus? receivedStatus;

        void testOnStatusDetermined(Robot robot, MachineStatus status) {
          onStatusDeterminedCalled = true;
          receivedRobot = robot;
          receivedStatus = status;
        }

        await tester.pumpWidget(confirmationScreenWidget(
          viewModel: viewModel,
          onStatusDetermined: testOnStatusDetermined,
        ));

        viewModel.addMachineStatus(MachineStatus.offline);
        await tester.pump();

        expect(onStatusDeterminedCalled, isTrue);
        expect(receivedRobot, equals(mockRobot));
        expect(receivedStatus, equals(MachineStatus.offline));

        await cleanup(tester);
      });

      testWidgets('displays SizedBox.shrink after callback', (WidgetTester tester) async {
        await tester.pumpWidget(confirmationScreenWidget(viewModel: viewModel));

        viewModel.addMachineStatus(MachineStatus.offline);
        await tester.pump();

        expect(find.byType(SizedBox), findsWidgets);

        await cleanup(tester);
      });
    });
  });
}
