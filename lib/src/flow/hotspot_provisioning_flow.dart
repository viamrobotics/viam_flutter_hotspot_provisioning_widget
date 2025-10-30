part of '../../viam_flutter_hotspot_provisioning_widget.dart';

class HotspotProvisioningFlow extends StatefulWidget {
  final Robot robot;
  final Viam viam;
  final RobotPart mainPart;
  final String? hotspotPrefix;
  final String? hotspotPassword;
  final String? fragmentId;
  final bool promptForCredentials;
  final bool overrideFragment;
  final bool replaceHardware;
  final Map<String, dynamic>? robotConfig;

  const HotspotProvisioningFlow({
    super.key,
    required this.robot,
    required this.viam,
    required this.mainPart,
    this.hotspotPrefix,
    this.hotspotPassword,
    this.fragmentId,
    this.promptForCredentials = false,
    required this.overrideFragment,
    required this.replaceHardware,
    this.robotConfig, // optional, for replacing hardware
  });

// Static method to push this flow and get a result
  static Future<HotspotProvisioningResult?> show(
    BuildContext context, {
    required Robot robot,
    required Viam viam,
    required RobotPart mainPart,
    String? hotspotPrefix,
    String? hotspotPassword,
    String? fragmentId,
    bool promptForCredentials = false,
    required bool overrideFragment,
    required bool replaceHardware,
    Map<String, dynamic>? robotConfig,
  }) {
    return Navigator.of(context).push<HotspotProvisioningResult?>(
      MaterialPageRoute(
        builder: (context) => HotspotProvisioningFlow(
          robot: robot,
          viam: viam,
          mainPart: mainPart,
          hotspotPrefix: hotspotPrefix,
          hotspotPassword: hotspotPassword,
          fragmentId: fragmentId,
          promptForCredentials: promptForCredentials,
          overrideFragment: overrideFragment,
          replaceHardware: replaceHardware,
          robotConfig: robotConfig,
        ),
      ),
    );
  }

  @override
  State<HotspotProvisioningFlow> createState() => _HotspotProvisioningFlowState();
}

class _HotspotProvisioningFlowState extends State<HotspotProvisioningFlow> {
  late final PageController _pageController;
  late final HotspotProvisioningFlowViewModel _viewModel;
  late final PluginWifiConnectService _pluginWifiConnectService;
  late final PermissionService _permissionService;
  late final ConfirmationViewModel _confirmationViewModel;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pluginWifiConnectService = PluginWifiConnectService();
    _permissionService = PermissionService();
    _viewModel = HotspotProvisioningFlowViewModel(
      robot: widget.robot,
      viam: widget.viam,
      mainPart: widget.mainPart,
      configuredHotspotPrefix: widget.hotspotPrefix,
      configuredHotspotPassword: widget.hotspotPassword,
      fragmentId: widget.fragmentId,
      pageController: _pageController,
      pluginWifiConnectService: _pluginWifiConnectService,
      permissionService: _permissionService,
      overrideFragment: widget.overrideFragment,
      replaceHardware: widget.replaceHardware,
      robotConfig: widget.robotConfig,
    );
    _confirmationViewModel = ConfirmationViewModel(
      repository: HotspotProvisioningRepository(
        viam: widget.viam,
        pluginWifiConnectService: _pluginWifiConnectService,
        permissionService: _permissionService,
      ),
      robot: widget.robot,
      mainPart: widget.mainPart,
      fragmentId: widget.fragmentId,
      overrideFragment: widget.overrideFragment,
      replaceHardware: widget.replaceHardware,
      robotConfig: widget.robotConfig,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _viewModel.dispose();
    _confirmationViewModel.dispose();
    super.dispose();
  }

  // when the confirmation screen determines the status, we want to pop this flow and return the result to the caller of HotspotProvisioningFlow.show()
  void _onConfirmationStatusDetermined(Robot robot, MachineStatus status) {
    if (mounted) {
      Navigator.of(context).pop(HotspotProvisioningResult(robot: robot, status: status));
    }
  }

  void _goToPreviousPage() {
    FocusScope.of(context).unfocus();
    if (_pageController.page == 0) {
      Navigator.of(context).pop();
    } else {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _viewModel),
        ChangeNotifierProvider.value(value: _viewModel.hotspotCredentialsInputViewModel),
        ChangeNotifierProvider.value(value: _viewModel.networkSelectionViewModel),
        ChangeNotifierProvider.value(value: _viewModel.passwordInputViewModel),
      ],
      child: Consumer<HotspotProvisioningFlowViewModel>(builder: (context, viewModel, _) {
        return PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            if (widget.promptForCredentials)
              HotspotCredentialsInputScreen(
                viewModel: viewModel.hotspotCredentialsInputViewModel,
                onBack: _goToPreviousPage,
              ),
            ConnectHotspotPrefixScreen(
              onBack: _goToPreviousPage,
              viewModel: ConnectHotspotPrefixViewModel(
                hotspotPrefix: viewModel.hotspotPrefix,
                hotspotPassword: viewModel.hotspotPassword,
                onNavigateToNetworkSelection: () {
                  viewModel.navigateToNextPage();
                },
                repository: HotspotProvisioningRepository(
                  viam: widget.viam,
                  pluginWifiConnectService: _pluginWifiConnectService,
                  permissionService: _permissionService,
                ),
              ),
            ),
            NetworkSelectionScreen(
              onBack: _goToPreviousPage,
              viewModel: viewModel.networkSelectionViewModel,
              onSelectNetwork: (network) {
                viewModel.onNetworkSelected(network);
              },
              onManualEntry: () {
                viewModel.onNetworkSelected(null);
              },
            ),
            PasswordInputScreen(viewModel: viewModel.passwordInputViewModel, onBack: _goToPreviousPage),
            ConfirmationScreen(viewModel: viewModel.confirmationViewModel, onStatusDetermined: _onConfirmationStatusDetermined),
          ],
        );
      }),
    );
  }
}
