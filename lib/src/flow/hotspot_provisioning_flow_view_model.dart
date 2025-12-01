part of '../../viam_flutter_hotspot_provisioning_widget.dart';

class HotspotProvisioningFlowViewModel extends ChangeNotifier {
  final Robot robot;
  final Viam viam;
  final RobotPart mainPart;
  final String? configuredHotspotPrefix;
  final String? configuredHotspotPassword;
  final String? fragmentId;
  final PageController pageController;
  final PluginWifiConnectService pluginWifiConnectService;
  final PermissionService permissionService;
  final bool overrideFragment;
  final bool replaceHardware;
  final Map<String, dynamic>? robotConfig;

  late final HotspotCredentialsInputViewModel hotspotCredentialsInputViewModel;
  late final NetworkSelectionViewModel networkSelectionViewModel;
  late final PasswordInputViewModel passwordInputViewModel;
  late final ConfirmationViewModel confirmationViewModel;
  late final HotspotProvisioningRepository _repository;

  String? _determinedFragmentId;
  String? _userHotspotPrefix;
  String? _userHotspotPassword;

  HotspotProvisioningFlowViewModel({
    required this.robot,
    required this.viam,
    required this.mainPart,
    this.configuredHotspotPrefix,
    this.configuredHotspotPassword,
    this.fragmentId,
    required this.pageController,
    required this.pluginWifiConnectService,
    required this.permissionService,
    required this.overrideFragment,
    required this.replaceHardware,
    this.robotConfig,
    // Optional child view models for testing, this allows us to inject mocks
    // If not provided, they get created internally like normal
    HotspotCredentialsInputViewModel? hotspotCredentialsInputViewModel,
    NetworkSelectionViewModel? networkSelectionViewModel,
    PasswordInputViewModel? passwordInputViewModel,
    ConfirmationViewModel? confirmationViewModel,
  }) {
    _repository = HotspotProvisioningRepository(
      viam: viam,
      pluginWifiConnectService: pluginWifiConnectService,
      permissionService: permissionService,
    );
    this.hotspotCredentialsInputViewModel = hotspotCredentialsInputViewModel ??
        HotspotCredentialsInputViewModel(
          configuredHotspotPrefix: configuredHotspotPrefix,
          configuredHotspotPassword: configuredHotspotPassword,
          onCredentialsSubmitted: onCredentialsSubmitted,
        );
    this.networkSelectionViewModel = networkSelectionViewModel ?? NetworkSelectionViewModel(repository: _repository);
    this.passwordInputViewModel = passwordInputViewModel ??
        PasswordInputViewModel(
          repository: _repository,
          mainPart: mainPart,
          fragmentId: fragmentId,
          onPasswordSubmitted: onPasswordSubmitted,
        );
    this.confirmationViewModel = confirmationViewModel ??
        ConfirmationViewModel(
          repository: _repository,
          robot: robot,
          mainPart: mainPart,
          fragmentId: fragmentId,
          overrideFragment: overrideFragment,
          replaceHardware: replaceHardware,
          robotConfig: robotConfig,
        );
  }

  String? get determinedFragmentId => _determinedFragmentId;

  // Custom credentials take precedence over configured ones
  // If neither exist, returns empty string and ConnectHotspotPrefixScreen will validate and show error
  String get hotspotPrefix => _userHotspotPrefix ?? configuredHotspotPrefix ?? '';
  String get hotspotPassword => _userHotspotPassword ?? configuredHotspotPassword ?? '';

  void onCredentialsSubmitted(String prefix, String password) {
    _userHotspotPrefix = prefix;
    _userHotspotPassword = password;
    notifyListeners();
    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    hotspotCredentialsInputViewModel.isSubmitting = false;
  }

  void onPasswordSubmitted(String? fragmentId) {
    _determinedFragmentId = fragmentId;
    confirmationViewModel.updateFragmentId(_determinedFragmentId);
    notifyListeners();
    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void onNetworkSelected(NetworkInfo? network) {
    passwordInputViewModel.network = network;
    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> onPublicNetworkSelected(NetworkInfo? network) async {
    passwordInputViewModel.network = network;
    pageController.nextPage(duration: const Duration(microseconds: 1), curve: Curves.easeInOut);
    // Submit credentials automatically, onPasswordSubmitted callback will navigate to confirmation page
    await passwordInputViewModel.submitCredentials();
  }

  void navigateToNextPage() {
    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    hotspotCredentialsInputViewModel.dispose();
    networkSelectionViewModel.dispose();
    passwordInputViewModel.dispose();
    confirmationViewModel.dispose();
    super.dispose();
  }
}
