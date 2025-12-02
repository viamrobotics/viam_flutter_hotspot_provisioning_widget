import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';
import 'package:viam_sdk/src/gen/google/protobuf/struct.pb.dart';

import '../mocks/generate_mocks.mocks.dart';

void main() {
  late HotspotProvisioningFlowViewModel hotspotProvisioningFlowViewModel;
  late MockViam mockViam;
  late MockPageController mockPageController;
  late MockPluginWifiConnectService mockPluginWifiConnectService;
  late MockPermissionService mockPermissionService;
  late MockHotspotCredentialsInputViewModel mockHotspotCredentialsInputViewModel;
  late MockNetworkSelectionViewModel mockNetworkSelectionViewModel;
  late MockPasswordInputViewModel mockPasswordInputViewModel;
  late MockConfirmationViewModel mockConfirmationViewModel;

  final mockRobot = Robot(id: 'test-robot-id', name: 'test-robot-name', location: 'test-location-id');

  final mockRobotPart = RobotPart(
    id: 'test-part-id',
    name: 'test-robot-name',
    locationId: 'test-location-id',
    robotConfig: Struct(fields: {
      'test-key': Value(stringValue: 'test-value'),
    }),
  );

  setUp(() {
    mockViam = MockViam();
    mockPageController = MockPageController();
    mockPluginWifiConnectService = MockPluginWifiConnectService();
    mockPermissionService = MockPermissionService();
    mockHotspotCredentialsInputViewModel = MockHotspotCredentialsInputViewModel();
    mockNetworkSelectionViewModel = MockNetworkSelectionViewModel();
    mockPasswordInputViewModel = MockPasswordInputViewModel();
    mockConfirmationViewModel = MockConfirmationViewModel();

    hotspotProvisioningFlowViewModel = HotspotProvisioningFlowViewModel(
      robot: mockRobot,
      viam: mockViam,
      mainPart: mockRobotPart,
      configuredHotspotPrefix: 'test-prefix',
      configuredHotspotPassword: 'test-password',
      fragmentId: 'test-fragment-id',
      pageController: mockPageController,
      pluginWifiConnectService: mockPluginWifiConnectService,
      permissionService: mockPermissionService,
      hotspotCredentialsInputViewModel: mockHotspotCredentialsInputViewModel,
      networkSelectionViewModel: mockNetworkSelectionViewModel,
      passwordInputViewModel: mockPasswordInputViewModel,
      confirmationViewModel: mockConfirmationViewModel,
      overrideFragment: true,
      replaceHardware: true,
    );
  });
  group('test onCredentialsSubmitted', () {
    test('should prioritize user credentials over configured ones when user credentials are submitted by the user', () async {
      when(mockHotspotCredentialsInputViewModel.resetSubmitting()).thenAnswer((_) async {});
      hotspotProvisioningFlowViewModel.onCredentialsSubmitted('user-prefix', 'user-password');


      expect(hotspotProvisioningFlowViewModel.hotspotPrefix, equals('user-prefix'));
      expect(hotspotProvisioningFlowViewModel.hotspotPassword, equals('user-password'));
    });

    test('should use configured credentials when no user credentials are submitted by the user', () {
      expect(hotspotProvisioningFlowViewModel.hotspotPrefix, equals('test-prefix'));
      expect(hotspotProvisioningFlowViewModel.hotspotPassword, equals('test-password'));
    });
    test('should reset isSubmitting after onCredentialsSubmitted is called', () {
      when(mockHotspotCredentialsInputViewModel.resetSubmitting()).thenAnswer((_) async {});
      hotspotProvisioningFlowViewModel.onCredentialsSubmitted('user-prefix', 'user-password');

      verify(mockHotspotCredentialsInputViewModel.resetSubmitting()).called(1);
    });
  });

  group('test onPasswordSubmitted', () {
    test('should update the determined fragment id', () async {
      when(mockConfirmationViewModel.updateFragmentId('test-fragment-id-1')).thenAnswer((_) async {});

      hotspotProvisioningFlowViewModel.onPasswordSubmitted('test-fragment-id-1');

      expect(hotspotProvisioningFlowViewModel.determinedFragmentId, equals('test-fragment-id-1'));
      verify(mockConfirmationViewModel.updateFragmentId('test-fragment-id-1')).called(1);
      verify(mockPageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut));
    });

    test('should handle null fragmentId in onPasswordSubmitted', () {
      when(mockConfirmationViewModel.updateFragmentId(null)).thenAnswer((_) async {});

      hotspotProvisioningFlowViewModel.onPasswordSubmitted(null);

      expect(hotspotProvisioningFlowViewModel.determinedFragmentId, isNull);
      verify(mockConfirmationViewModel.updateFragmentId(null)).called(1);
      verify(mockPageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut));
    });
  });

  group('test onNetworkSelected', () {
    test('should update the network', () async {
      final testNetwork = NetworkInfo(ssid: 'test-ssid', security: 'test-security');

      hotspotProvisioningFlowViewModel.onNetworkSelected(testNetwork);

      verify(mockPasswordInputViewModel.network = testNetwork).called(1);
      verify(mockPageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut));
    });

    test('should handle null network in onNetworkSelected', () {
      hotspotProvisioningFlowViewModel.onNetworkSelected(null);

      verify(mockPasswordInputViewModel.network = null).called(1);
      verify(mockPageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut));
    });
  });
  group('test navigateToNextPage', () {
    test('should navigate to the next page', () async {
      hotspotProvisioningFlowViewModel.navigateToNextPage();

      verify(mockPageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut));
    });
  });
  group('test resetConnectionState', () {
    test('should call resetConnectionState on connectHotspotPrefixViewModel when it exists', () async {
      final mockRepository = MockHotspotProvisioningRepository();
      when(mockRepository.disconnect()).thenAnswer((_) async => true);
      
      final connectHotspotPrefixViewModel = ConnectHotspotPrefixViewModel(
        hotspotPrefix: 'test-prefix',
        hotspotPassword: 'test-password',
        onNavigateToNetworkSelection: () {},
        repository: mockRepository,
      );
      
      connectHotspotPrefixViewModel.setConnectedToHotspot(true);
      hotspotProvisioningFlowViewModel.connectHotspotPrefixViewModel = connectHotspotPrefixViewModel;

      await hotspotProvisioningFlowViewModel.resetConnectionState();

      expect(connectHotspotPrefixViewModel.connectedToHotspot, isFalse);
      verify(mockRepository.disconnect()).called(1);
    });

    test('should not throw when connectHotspotPrefixViewModel is null', () async {
      hotspotProvisioningFlowViewModel.connectHotspotPrefixViewModel = null;

      await hotspotProvisioningFlowViewModel.resetConnectionState();

      // should complete without throwing
      expect(hotspotProvisioningFlowViewModel.connectHotspotPrefixViewModel, isNull);
    });
  });
  group('test dispose', () {
    test('should dispose the view model', () async {
      hotspotProvisioningFlowViewModel.dispose();

      verify(mockHotspotCredentialsInputViewModel.dispose()).called(1);
      verify(mockNetworkSelectionViewModel.dispose()).called(1);
      verify(mockPasswordInputViewModel.dispose()).called(1);
    });
  });
}
