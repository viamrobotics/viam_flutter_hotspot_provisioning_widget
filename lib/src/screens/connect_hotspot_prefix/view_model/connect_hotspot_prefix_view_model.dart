part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class ConnectHotspotPrefixViewModel extends ChangeNotifier {
  final String hotspotPrefix;
  final String hotspotPassword;
  final VoidCallback onNavigateToNetworkSelection;
  final HotspotProvisioningRepository repository;
  bool _isAttemptingConnectionToHotspot = false;
  bool _failedToConnectToHotspot = false;
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
  bool get failedToConnectToHotspot => _failedToConnectToHotspot;
  bool get foundValidSmartMachineStatus => _foundValidSmartMachineStatus;
  bool get pollingForMachine => _pollingForMachine;
  bool get connectedToHotspot => _connectedToHotspot;

  void setIsAttemptingConnectionToHotspot(bool value) {
    _isAttemptingConnectionToHotspot = value;
    notifyListeners();
  }

  void setFailedToConnectToHotspot(bool value) {
    _failedToConnectToHotspot = value;
    notifyListeners();
  }

  void setFoundValidSmartMachineStatus(bool value) {
    _foundValidSmartMachineStatus = value;
    notifyListeners();
  }

  void setPollingForMachine(bool value) {
    _pollingForMachine = value;
    notifyListeners();
  }

  void setConnectedToHotspot(bool value) {
    _connectedToHotspot = value;
    notifyListeners();
  }

  Future<bool> getLocationPermission() async {
    return await repository.getLocationPermission();
  }

  void resetConnectionState() async {
    await repository.disconnect();
    _pollingTimer?.cancel();
    setIsAttemptingConnectionToHotspot(false);
    setFailedToConnectToHotspot(false);
    setFoundValidSmartMachineStatus(false);
    setPollingForMachine(false);
    setConnectedToHotspot(false);
  }

// This function should only ever be called after we are connected to the hotspot
  void findProvisionedMachine() {
    if (_pollingForMachine || _foundValidSmartMachineStatus) return;

    setPollingForMachine(true);
    setIsAttemptingConnectionToHotspot(false);

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
            setFoundValidSmartMachineStatus(true);
            setPollingForMachine(false);
            onNavigateToNetworkSelection();
          } catch (e) {
            debugPrint('Error during smart machine status check, continuing polling. Error: $e');
          }
        });
      }
    });
  }

  /// Attempts to connect to the device hotspot.
  ///
  /// We only show loading and failure states on iOS because Android displays
  /// its own native dialogs for connection status and errors.
  void connectToHotspot() async {
    if (Platform.isIOS) {
      setIsAttemptingConnectionToHotspot(true);
    }

    final connectedSSID = await repository.getCurrentSSID();
    // In case we are already connected to the hotspot, we can just go to the next step, finding the provisioned machine.
    if (connectedSSID != null && connectedSSID.replaceAll(RegExp(r'^"|"$'), '').startsWith(hotspotPrefix) && _connectedToHotspot) {
      debugPrint('Already connected to $hotspotPrefix hotspot');
      findProvisionedMachine();
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
        setConnectedToHotspot(true);
        findProvisionedMachine();
      } else {
        setConnectedToHotspot(false);
        if (Platform.isIOS) {
          setIsAttemptingConnectionToHotspot(false);
          setFailedToConnectToHotspot(true);
        }
      }
    } else {
      setConnectedToHotspot(false);
      if (Platform.isIOS) {
        setIsAttemptingConnectionToHotspot(false);
        setFailedToConnectToHotspot(true);
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
