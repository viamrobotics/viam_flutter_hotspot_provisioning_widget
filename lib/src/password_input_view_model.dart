part of '../../viam_flutter_hotspot_provisioning_widget.dart';

class PasswordInputViewModel extends ChangeNotifier {
  final Viam _viam;
  final RobotPart _mainPart;
  VoidCallback onPasswordSubmitted;
  final Function(BuildContext, {required String title, String? error}) _showErrorDialog;

  PasswordInputViewModel(this._viam, this._mainPart, this.onPasswordSubmitted, this._showErrorDialog);

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ssidController = TextEditingController();

  bool _obscureText = true;
  bool get obscureText => _obscureText;

  bool _loading = false;
  bool get loading => _loading;

  NetworkInfo? _network;
  NetworkInfo? get network => _network;

  set network(NetworkInfo? network) {
    _network = network;
    notifyListeners();
  }

  void toggleObscureText() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  @override
  void dispose() {
    passwordController.dispose();
    ssidController.dispose();
    super.dispose();
  }

  Future<void> submitPassword(BuildContext context) async {
    _loading = true;
    notifyListeners();
    try {
      // For v.0.16.0 of viam-agent, we expect machineCreds to be sent first, and then networkCreds.
      // This is why we are NOT sending them at the same time.
      final response = await getSmartMachineStatus();
      if (!response.hasSmartMachineCredentials) {
        await _setSmartMachineCredentials();
      }
      // We are not awaiting setNetworkCredentials because it takes a unknown, but long amount of time to complete, or times out.
      // If the user has gotten this far, we've validated that this is their machine, so we can just set the network credentials.
      _setNetworkCredentials(network?.ssid.trim() ?? ssidController.text.trim(), passwordController.text.trim());
      onPasswordSubmitted();
    } catch (e) {
      if (!context.mounted) return;
      _showErrorDialog(
        context,
        title: 'Failed to connect to Wi-Fi',
        error: 'Please try again.',
      );
    }
    _loading = false;
    notifyListeners();
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
    // TOOD: include provisioning attempts like we have in gost??
  }
}
