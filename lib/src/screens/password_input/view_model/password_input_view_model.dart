part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class PasswordInputViewModel extends ChangeNotifier {
  final HotspotProvisioningRepository _repository;
  final RobotPart _mainPart;
  final String? _fragmentId;
  final Function(String? fragmentId) _onPasswordSubmitted;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ssidController = TextEditingController();
  bool _obscureText = false;
  bool _loading = false;
  NetworkInfo? _network;
  String? _fragmentIdToWrite;

  PasswordInputViewModel({
    required HotspotProvisioningRepository repository,
    required RobotPart mainPart,
    required String? fragmentId,
    required Function(String? fragmentId) onPasswordSubmitted,
  })  : _repository = repository,
        _mainPart = mainPart,
        _fragmentId = fragmentId,
        _onPasswordSubmitted = onPasswordSubmitted {
    // Set up text field listeners
    _passwordController.addListener(notifyListeners);
    _ssidController.addListener(notifyListeners);
  }

  TextEditingController get passwordController => _passwordController;
  TextEditingController get ssidController => _ssidController;
  bool get obscureText => _obscureText;
  bool get loading => _loading;
  NetworkInfo? get network => _network;
  RobotPart get mainPart => _mainPart;
  String? get fragmentId => _fragmentId;
  Function(String? fragmentId) get onPasswordSubmitted => _onPasswordSubmitted;
  HotspotProvisioningRepository get repository => _repository;

  String? get fragmentIdToWrite => _fragmentIdToWrite;

  set network(NetworkInfo? value) {
    _network = value;
    notifyListeners();
  }

  bool get areNetworkCredentialsValid {
    if (_network != null) {
      // Network credentials are valid if: it is a public network (no password needed) OR it is a private network with password provided
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

  void setLoading(bool value) {
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

  // This function submits the smart machine credentials and network credentials to the agent.
  // If the network is public, we submit an empty string as the password.
  Future<void> submitCredentials() async {
    Version? agentVersion;
    setLoading(true);

    try {
      // For v.0.16.0 of viam-agent, we expect machineCreds to be sent first, and then networkCreds.
      // This is why we are NOT sending them at the same time.
      final response = await repository.getSmartMachineStatus();
      if (!response.hasSmartMachineCredentials) {
        await repository.setSmartMachineCredentials(
          id: _mainPart.id,
          secret: _mainPart.secret,
        );
      }
      // For public networks, submit empty string as password
      final String password = _network != null && isPublicNetwork(_network!) ? '' : _passwordController.text.trim();
      // Get the fragmentId that was passed in to this hotspot provisioning flow or get it from agent.
      _fragmentIdToWrite = _fragmentId ?? response.provisioningInfo.fragmentId;
      // Check if agent version is greater than or equal to 0.20.0
      // If it is, we can call exitProvisioning after setting network credentials, otherwise just set network credentials and move on.
      if (response.agentVersion.isNotEmpty) {
        agentVersion = Version.parse(response.agentVersion);
      }
      
      if (agentVersion != null && agentVersion >= Version(0, 20, 0)) {
        await repository.setNetworkCredentials(
          type: NetworkType.wifi,
          ssid: _network?.ssid.trim() ?? _ssidController.text.trim(),
          psk: password,
        );
        await repository.exitProvisioning();
      } else {
        repository.setNetworkCredentials(
          type: NetworkType.wifi,
          ssid: _network?.ssid.trim() ?? _ssidController.text.trim(),
          psk: password,
        );
      }
      _onPasswordSubmitted(_fragmentIdToWrite);
    } catch (e) {
      rethrow; // Let the view handle the error
    } finally {
      setLoading(false);
    }
  }
}
