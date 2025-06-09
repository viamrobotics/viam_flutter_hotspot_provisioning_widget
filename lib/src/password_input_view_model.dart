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

  Future<void> submitPassword(BuildContext context) async {
    _loading = true;
    notifyListeners();
    try {
      final response = await getSmartMachineStatus();
      if (!response.hasSmartMachineCredentials) {
        await _setSmartMachineCredentials();
      }
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
  }

  @override
  void dispose() {
    passwordController.dispose();
    ssidController.dispose();
    super.dispose();
  }
}
