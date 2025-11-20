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
  });

  tearDown(() {
    viewModel.dispose();
  });

  Widget confirmationScreenWidget({
    ConfirmationViewModel? customViewModel,
    Function(Robot robot, MachineStatus status)? onStatusDetermined,
  }) {
    return MaterialApp(
      home: ConfirmationScreen(
        viewModel: customViewModel ?? viewModel,
        onStatusDetermined: onStatusDetermined ?? mockOnStatusDetermined,
      ),
    );
  }

  group('ConfirmationScreen', () {
    testWidgets('displays AppBar with no leading', (WidgetTester tester) async {
      when(mockRepository.disconnect()).thenAnswer((_) async => true);
      when(mockRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
      when(mockRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);

      await tester.pumpWidget(confirmationScreenWidget());
      await tester.pump();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.automaticallyImplyLeading, isFalse);

      // Clean up: dispose widget to cancel timers
      await tester.pumpWidget(Container());
      await tester.pump();
      // Wait for any pending timers (like disconnectFromHotspot's 5-second timer)
      await tester.pumpAndSettle(const Duration(seconds: 6));
    });

    testWidgets('has PopScope with canPop set to false', (WidgetTester tester) async {
      when(mockRepository.disconnect()).thenAnswer((_) async => true);
      when(mockRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
      when(mockRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);

      await tester.pumpWidget(confirmationScreenWidget());
      await tester.pump();

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);

      // Clean up: dispose widget to cancel timers
      await tester.pumpWidget(Container());
      await tester.pump();
      // Wait for any pending timers (like disconnectFromHotspot's 5-second timer)
      await tester.pumpAndSettle(const Duration(seconds: 6));
    });

    testWidgets('displays RobotLoadingWidget when snapshot has no data', (WidgetTester tester) async {
      when(mockRepository.disconnect()).thenAnswer((_) async => true);
      when(mockRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
      when(mockRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);

      await tester.pumpWidget(confirmationScreenWidget());
      await tester.pump();

      expect(find.byType(RobotLoadingWidget), findsOneWidget);

      // Clean up: dispose widget to cancel timers
      await tester.pumpWidget(Container());
      await tester.pump();
      // Wait for any pending timers (like disconnectFromHotspot's 5-second timer)
      await tester.pumpAndSettle(const Duration(seconds: 6));
    });

    testWidgets('displays RobotLoadingWidget when status is loading', (WidgetTester tester) async {
      when(mockRepository.disconnect()).thenAnswer((_) async => true);
      when(mockRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
      when(mockRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);

      viewModel.addMachineStatus(MachineStatus.loading);
      await tester.pumpWidget(confirmationScreenWidget());
      await tester.pump();

      expect(find.byType(RobotLoadingWidget), findsOneWidget);

      // Clean up: dispose widget to cancel timers
      await tester.pumpWidget(Container());
      await tester.pump();
      // Wait for any pending timers (like disconnectFromHotspot's 5-second timer)
      await tester.pumpAndSettle(const Duration(seconds: 6));
    });

    testWidgets('calls onStatusDetermined when status is online', (WidgetTester tester) async {
      when(mockRepository.disconnect()).thenAnswer((_) async => true);
      when(mockRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
      when(mockRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);

      bool onStatusDeterminedCalled = false;
      Robot? receivedRobot;
      MachineStatus? receivedStatus;

      void testOnStatusDetermined(Robot robot, MachineStatus status) {
        onStatusDeterminedCalled = true;
        receivedRobot = robot;
        receivedStatus = status;
      }

      await tester.pumpWidget(confirmationScreenWidget(onStatusDetermined: testOnStatusDetermined));
      await tester.pump();

      viewModel.addMachineStatus(MachineStatus.online);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100)); // Wait for post frame callback

      expect(onStatusDeterminedCalled, isTrue);
      expect(receivedRobot, equals(mockRobot));
      expect(receivedStatus, equals(MachineStatus.online));

      // Clean up: dispose widget to cancel timers
      await tester.pumpWidget(Container());
      await tester.pump();
      // Wait for any pending timers (like disconnectFromHotspot's 5-second timer)
      await tester.pumpAndSettle(const Duration(seconds: 6));
    });

    testWidgets('calls onStatusDetermined when status is offline', (WidgetTester tester) async {
      when(mockRepository.disconnect()).thenAnswer((_) async => true);
      when(mockRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
      when(mockRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);

      bool onStatusDeterminedCalled = false;
      Robot? receivedRobot;
      MachineStatus? receivedStatus;

      void testOnStatusDetermined(Robot robot, MachineStatus status) {
        onStatusDeterminedCalled = true;
        receivedRobot = robot;
        receivedStatus = status;
      }

      await tester.pumpWidget(confirmationScreenWidget(onStatusDetermined: testOnStatusDetermined));
      await tester.pump();

      viewModel.addMachineStatus(MachineStatus.offline);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100)); // Wait for post frame callback

      expect(onStatusDeterminedCalled, isTrue);
      expect(receivedRobot, equals(mockRobot));
      expect(receivedStatus, equals(MachineStatus.offline));

      // Clean up: dispose widget to cancel timers
      await tester.pumpWidget(Container());
      await tester.pump();
      // Wait for any pending timers (like disconnectFromHotspot's 5-second timer)
      await tester.pumpAndSettle(const Duration(seconds: 6));
    });

    // Note: disconnectFromHotspot is called in initState but not awaited,
    // so it's difficult to test directly. The method is tested in the view model tests.

    testWidgets('calls startCheckingOnline in initState', (WidgetTester tester) async {
      when(mockRepository.disconnect()).thenAnswer((_) async => true);
      when(mockRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
      when(mockRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);

      await tester.pumpWidget(confirmationScreenWidget());
      await tester.pump();

      expect(viewModel.timer, isNotNull);
      expect(viewModel.timer!.isActive, isTrue);

      // Clean up: dispose widget to cancel timers
      await tester.pumpWidget(Container());
      await tester.pump();
      // Wait for any pending timers (like disconnectFromHotspot's 5-second timer)
      await tester.pumpAndSettle(const Duration(seconds: 6));
    });

    testWidgets('disposes viewModel when widget is disposed', (WidgetTester tester) async {
      when(mockRepository.disconnect()).thenAnswer((_) async => true);
      when(mockRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
      when(mockRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);

      bool streamClosed = false;
      viewModel.machineStatusStream.listen(
        (status) {},
        onDone: () => streamClosed = true,
      );

      await tester.pumpWidget(confirmationScreenWidget());
      await tester.pump();
      await tester.pumpWidget(Container()); // Remove widget to trigger dispose

      await tester.pump(const Duration(milliseconds: 100));
      expect(streamClosed, isTrue);

      // Wait for any pending timers (like disconnectFromHotspot's 5-second timer)
        await tester.pumpAndSettle(const Duration(seconds: 6));
    });

    group('when overrideFragment is true and status is online', () {
      testWidgets('calls performFragmentOverride', (WidgetTester tester) async {
        when(mockRepository.disconnect()).thenAnswer((_) async => true);
        when(mockRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
        when(mockRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);
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

        await tester.pumpWidget(confirmationScreenWidget(customViewModel: viewModelWithOverride));
        await tester.pump();

        viewModelWithOverride.addMachineStatus(MachineStatus.online);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100)); // Wait for async operations and post frame callback

        verify(mockRepository.updateRobotPart(
          partId: mockRobotPart.id,
          robotName: mockRobot.name,
          config: {
            'fragments': ['test-fragment-id']
          },
        )).called(1);

        // Clean up: dispose widget to cancel timers
        await tester.pumpWidget(Container());
        await tester.pump();
        viewModelWithOverride.dispose();
        // Wait for any pending timers (like disconnectFromHotspot's 5-second timer)
        await tester.pumpAndSettle(const Duration(seconds: 6));
      });
    });

    group('when replaceHardware is true and status is online', () {
      testWidgets('calls applyRobotConfig', (WidgetTester tester) async {
        final mockRobotConfig = {
          'test-key': 'test-value',
        };

        when(mockRepository.disconnect()).thenAnswer((_) async => true);
        when(mockRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
        when(mockRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);
        when(mockRepository.updateRobotPart(
          partId: anyNamed('partId'),
          robotName: anyNamed('robotName'),
          config: anyNamed('config'),
        )).thenAnswer((_) async {});

        final viewModelWithReplace = ConfirmationViewModel(
          repository: mockRepository,
          robot: mockRobot,
          mainPart: mockRobotPart,
          fragmentId: 'test-fragment-id',
          overrideFragment: false,
          replaceHardware: true,
          robotConfig: mockRobotConfig,
        );

        await tester.pumpWidget(confirmationScreenWidget(customViewModel: viewModelWithReplace));
        await tester.pump();

        viewModelWithReplace.addMachineStatus(MachineStatus.online);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100)); // Wait for async operations and post frame callback

        verify(mockRepository.updateRobotPart(
          partId: mockRobotPart.id,
          robotName: mockRobotPart.name,
          config: mockRobotConfig,
        )).called(1);

        // Clean up: dispose widget to cancel timers
        await tester.pumpWidget(Container());
        await tester.pump();
        viewModelWithReplace.dispose();
        // Wait for any pending timers (like disconnectFromHotspot's 5-second timer)
        await tester.pumpAndSettle(const Duration(seconds: 6));
      });
    });

    testWidgets('displays SizedBox.shrink when status is online or offline after callback', (WidgetTester tester) async {
      when(mockRepository.disconnect()).thenAnswer((_) async => true);
      when(mockRepository.getRobot(any)).thenAnswer((_) async => mockRobot);
      when(mockRepository.calculateMachineStatus(any)).thenAnswer((_) async => MachineStatus.loading);

      await tester.pumpWidget(confirmationScreenWidget());
      await tester.pump();

      viewModel.addMachineStatus(MachineStatus.online);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100)); // Wait for post frame callback

      // After the callback, the widget should show SizedBox.shrink
      expect(find.byType(SizedBox), findsWidgets);

      // Clean up: dispose widget to cancel timers
      await tester.pumpWidget(Container());
      await tester.pump();
      // Wait for any pending timers (like disconnectFromHotspot's 5-second timer)
      await tester.pumpAndSettle(const Duration(seconds: 6));
    });
  });
}
