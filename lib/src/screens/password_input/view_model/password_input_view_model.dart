part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class PasswordInputViewModel extends ChangeNotifier {
  final Viam _viam;
  final RobotPart _mainPart;
  final String? _fragmentId;
  final Function(String? fragmentId) _onPasswordSubmitted;
  final Function(BuildContext, {required String title, String? error}) _showErrorDialog;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ssidController = TextEditingController();
  bool _obscureText = false;
  bool _loading = false;
  NetworkInfo? _network;

  PasswordInputViewModel({
    required Viam viam,
    required RobotPart mainPart,
    required String? fragmentId,
    required Function(String? fragmentId) onPasswordSubmitted,
    required Function(BuildContext, {required String title, String? error}) showErrorDialog,
  })  : _viam = viam,
        _mainPart = mainPart,
        _fragmentId = fragmentId,
        _onPasswordSubmitted = onPasswordSubmitted,
        _showErrorDialog = showErrorDialog {
    _passwordController.addListener(notifyListeners);
    _ssidController.addListener(notifyListeners);
  }

  TextEditingController get passwordController => _passwordController;
  TextEditingController get ssidController => _ssidController;
  bool get obscureText => _obscureText;
  bool get loading => _loading;
  NetworkInfo? get network => _network;

  set network(NetworkInfo? value) {
    _network = value;
    notifyListeners();
  }

  bool get areNetworkCredentialsValid {
    if (_network != null) {
      // For public networks, credentials are entered even with empty password
      // For private networks, password must be non-empty
      return isPublicNetwork(_network!) || _passwordController.text.isNotEmpty;
    }
    return _ssidController.text.isNotEmpty;
  }

  void toggleObscureText() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  void clearPassword() {
    _passwordController.clear();
  }

  bool isPublicNetwork(NetworkInfo network) {
    return network.security == '-';
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _passwordController.removeListener(notifyListeners);
    _ssidController.removeListener(notifyListeners);
    _passwordController.dispose();
    _ssidController.dispose();
    super.dispose();
  }

  Future<void> submitPassword(BuildContext context) async {
    Version? agentVersion;
    FocusScope.of(context).unfocus();
    _setLoading(true);

    try {
      // For v.0.16.0 of viam-agent, we expect machineCreds to be sent first, and then networkCreds.
      // This is why we are NOT sending them at the same time.
      final response = await getSmartMachineStatus();
      if (!response.hasSmartMachineCredentials) {
        await _setSmartMachineCredentials();
      }
      // For public networks, submit empty string as password
      final String password = _network != null && isPublicNetwork(_network!) ? '' : _passwordController.text.trim();
      // Get the fragmentId that was passed in to this hotspot provisioning flow or get it from agent.
      final fragmentIdToWrite = _fragmentId ?? response.provisioningInfo.fragmentId;
      // Check if agent version is greater than or equal to 0.20.0
      // If it is, we can call exitProvisioning after setting network credentials, otherwise just set network credentials and move on.
      if (response.agentVersion.isNotEmpty) {
        agentVersion = Version.parse(response.agentVersion);
      }
      if (agentVersion != null && agentVersion >= Version(0, 20, 0)) {
        await _setNetworkCredentials(_network?.ssid.trim() ?? _ssidController.text.trim(), password);
        await _viam.provisioningClient.exitProvisioning();
      } else {
        _setNetworkCredentials(_network?.ssid.trim() ?? _ssidController.text.trim(), password);
      }
      _onPasswordSubmitted(fragmentIdToWrite);
    } catch (e) {
      if (!context.mounted) return;
      _showErrorDialog(
        context,
        title: 'Failed to connect to Wi-Fi',
        error: 'Please try again.',
      );
    }

    _setLoading(false);
  }

  Future<GetSmartMachineStatusResponse> getSmartMachineStatus() async {
    return await _viam.provisioningClient.getSmartMachineStatus();
  }

  Future<void> _setSmartMachineCredentials() async {
    await _viam.provisioningClient.setSmartMachineCredentials(
      id: _mainPart.id,
      secret: _mainPart.secret,
    );
  }

  Future<void> _setNetworkCredentials(String ssid, String psk) async {
    await _viam.provisioningClient.setNetworkCredentials(
      type: NetworkType.wifi,
      ssid: ssid,
      psk: psk,
    );
  }
}
