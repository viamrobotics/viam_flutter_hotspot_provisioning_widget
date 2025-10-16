part of '../../viam_flutter_hotspot_provisioning_widget.dart';

class HotspotProvisioningFlowViewModel extends ChangeNotifier {
  final Viam viam;
  final RobotPart mainPart;
  final String? configuredHotspotPrefix;
  final String? configuredHotspotPassword;
  final String? fragmentId;
  final PageController pageController;

  late final HotspotCredentialsInputViewModel hotspotCredentialsInputViewModel;
  late final NetworkSelectionViewModel networkSelectionViewModel;
  late final PasswordInputViewModel passwordInputViewModel;

  String? _determinedFragmentId;
  String? _userHotspotPrefix;
  String? _userHotspotPassword;

  HotspotProvisioningFlowViewModel({
    required this.viam,
    required this.mainPart,
    this.configuredHotspotPrefix,
    this.configuredHotspotPassword,
    this.fragmentId,
    required this.pageController,
  }) {
    hotspotCredentialsInputViewModel = HotspotCredentialsInputViewModel(
      configuredHotspotPrefix: configuredHotspotPrefix,
      configuredHotspotPassword: configuredHotspotPassword,
      onCredentialsSubmitted: onCredentialsSubmitted,
    );
    networkSelectionViewModel = NetworkSelectionViewModel(viam: viam);
    passwordInputViewModel = PasswordInputViewModel(
      viam: viam,
      mainPart: mainPart,
      fragmentId: fragmentId,
      onPasswordSubmitted: onPasswordSubmitted,
      showErrorDialog: _showErrorDialog,
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
  }

  void onPasswordSubmitted(String? fragmentId) {
    _determinedFragmentId = fragmentId;
    notifyListeners();
    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void onNetworkSelected(NetworkInfo? network) {
    passwordInputViewModel.network = network;
    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void navigateToNextPage() {
    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _showErrorDialog(BuildContext context, {required String title, String? error}) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: error == null ? null : Text(error),
        actions: [
          PlatformDialogAction(
            onPressed: Navigator.of(context).pop,
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    hotspotCredentialsInputViewModel.dispose();
    networkSelectionViewModel.dispose();
    passwordInputViewModel.dispose();
    super.dispose();
  }
}
