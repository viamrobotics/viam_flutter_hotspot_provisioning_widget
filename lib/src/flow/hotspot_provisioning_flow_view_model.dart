part of '../../viam_flutter_hotspot_provisioning_widget.dart';
class HotspotProvisioningFlowViewModel extends ChangeNotifier {
  final Viam viam;
  final RobotPart mainPart;
  final String? configuredHotspotPrefix;
  final String? configuredHotspotPassword;
  final String? fragmentId;
  final PageController pageController;

  late final NetworkSelectionViewModel networkSelectionViewModel;
  late final PasswordInputViewModel passwordInputViewModel;

  String? _determinedFragmentId;
  String? _userProvidedHotspotPrefix;
  String? _userProvidedHotspotPassword;

  HotspotProvisioningFlowViewModel({
    required this.viam,
    required this.mainPart,
    this.configuredHotspotPrefix,
    this.configuredHotspotPassword,
    this.fragmentId,
    required this.pageController,
  }) {
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

  String get finalHotspotPrefix => _userProvidedHotspotPrefix ?? configuredHotspotPrefix ?? '';
  String get finalHotspotPassword => _userProvidedHotspotPassword ?? configuredHotspotPassword ?? '';

  bool get hasUserProvidedCredentials => _userProvidedHotspotPrefix != null && _userProvidedHotspotPassword != null;

  void onCredentialsSubmitted(String prefix, String password) {
    _userProvidedHotspotPrefix = prefix;
    _userProvidedHotspotPassword = password;
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
    networkSelectionViewModel.dispose();
    passwordInputViewModel.dispose();
    super.dispose();
  }
}
