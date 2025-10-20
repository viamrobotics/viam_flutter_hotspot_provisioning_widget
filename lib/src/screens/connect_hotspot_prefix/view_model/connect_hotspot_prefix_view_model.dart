part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class ConnectHotspotPrefixViewModel extends ChangeNotifier {
  final String hotspotPrefix;
  final String hotspotPassword;
  final VoidCallback onNavigateToNetworkSelection;
  final HotspotProvisioningRepository repository;

  bool _isAttemptingConnectionToHotspot = false;
  bool _isRetryingHotspot = false;
  Timer? _pollingTimer;
  bool _foundValidSmartMachineStatus = false;
  bool _pollingForMachine = false;
  bool _connectedToHotspot = false;
  ConnectHotspotPrefixViewModel({
    required this.hotspotPrefix,
    required this.hotspotPassword,
    required this.onNavigateToNetworkSelection,
    required this.repository,
  });

  bool get isAttemptingConnectionToHotspot => _isAttemptingConnectionToHotspot;
  bool get isRetryingHotspot => _isRetryingHotspot;
  bool get foundValidSmartMachineStatus => _foundValidSmartMachineStatus;
  bool get pollingForMachine => _pollingForMachine;
  bool get connectedToHotspot => _connectedToHotspot;

  void _setIsAttemptingConnectionToHotspot(bool value) {
    _isAttemptingConnectionToHotspot = value;
    notifyListeners();
  }

  void _setIsRetryingHotspot(bool value) {
    _isRetryingHotspot = value;
    notifyListeners();
  }

  void _setFoundValidSmartMachineStatus(bool value) {
    _foundValidSmartMachineStatus = value;
    notifyListeners();
  }

  void _setPollingForMachine(bool value) {
    _pollingForMachine = value;
    notifyListeners();
  }

  void _setConnectedToHotspot(bool value) {
    _connectedToHotspot = value;
    notifyListeners();
  }

  Future<bool> getLocationPermission() async {
    return await repository.getLocationPermission();
  }

// This function should only ever be called after we are connected to the hotspot
  void _findProvisionedMachine() {
    if (_pollingForMachine || _foundValidSmartMachineStatus) return;

    _setPollingForMachine(true);
    _setIsAttemptingConnectionToHotspot(false);

    // Add a delay to allow the robot's provisioning service to start up
    Future.delayed(const Duration(seconds: 5), () {
      // Ensure we don't start multiple timers
      if (!_foundValidSmartMachineStatus && (_pollingTimer == null || !_pollingTimer!.isActive)) {
        debugPrint('Starting periodic check every 3 seconds');
        _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
          try {
            debugPrint('checking smart machine status');
            final response = await repository.getSmartMachineStatus();
            debugPrint('provisioningInfo: ${response.provisioningInfo}');
            _pollingTimer?.cancel();
            _setFoundValidSmartMachineStatus(true);
            _setPollingForMachine(false);
            onNavigateToNetworkSelection();
          } catch (e) {
            debugPrint('Error during smart machine status check, continuing polling. Error: $e');
          }
        });
      }
    });
  }

 
  void connectToHotspot() async {
    _setIsAttemptingConnectionToHotspot(true);

    final connectedSSID = await repository.getCurrentSSID();
    // In case we are already connected to the hotspot, we can just go to the next step, finding the provisioned machine.
    if (connectedSSID != null && connectedSSID.replaceAll(RegExp(r'^"|"$'), '').startsWith(hotspotPrefix) && _connectedToHotspot) {
      debugPrint('Already connected to $hotspotPrefix hotspot');
      _findProvisionedMachine();
      return;
    }
    // If we are not connected to the hotspot, we need to connect to it.
    debugPrint('Connecting to $hotspotPrefix-#### hotspot');
    final connected = await repository.connectToSecureNetworkByPrefix(
      prefix: hotspotPrefix,
      password: hotspotPassword,
      isWep: false,
      isWpa3: false,
      saveNetwork: true, // flips joinOnce on iOS to false
    );
    if (connected) {
      final connectedSSID = await repository.getCurrentSSID();
      if (connectedSSID != null &&
          connectedSSID != '<unknown ssid>' &&
          connectedSSID.replaceAll(RegExp(r'^"|"$'), '').startsWith(hotspotPrefix)) {
        _setConnectedToHotspot(true);
        _findProvisionedMachine();
      } else {
        _setConnectedToHotspot(false);
        _setIsAttemptingConnectionToHotspot(false);
        _setIsRetryingHotspot(true);
      }
    } else {
      _setConnectedToHotspot(false);
      _setIsAttemptingConnectionToHotspot(false);
      _setIsRetryingHotspot(true);
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
