part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class ConnectHotspotPrefixViewModel extends ChangeNotifier {
  ConnectHotspotPrefixViewModel({
    required this.viam,
    required this.context,
    required this.hotspotPrefix,
    required this.hotspotPassword,
    required this.onNavigateToNetworkSelection,
    required this.hotspotProvisioningRepository,
  });

  final Viam viam;
  final BuildContext context;
  final String hotspotPrefix;
  final String hotspotPassword;
  final VoidCallback onNavigateToNetworkSelection;
  final HotspotProvisioningRepository hotspotProvisioningRepository;

  bool _isAttemptingConnectionToHotspot = false;
  bool _isRetryingHotspot = false;
  Timer? _pollingTimer;
  bool _foundValidSmartMachineStatus = false;
  bool _pollingForMachine = false;
  bool _connectedToHotspot = false;

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

  // Android considers Wi-Fi information to be location information
  // If we don't have location permission any connected ssid will show as 'unown ssid'
  Future<void> getLocationPermission() async {
    final status = await ph.Permission.location.request();
    switch (status) {
      case ph.PermissionStatus.granted:
        break; // safe to continue!
      case ph.PermissionStatus.denied:
      case ph.PermissionStatus.permanentlyDenied:
      case ph.PermissionStatus.restricted:
        await _showLocationPermissionDialog();
      case ph.PermissionStatus.limited:
      case ph.PermissionStatus.provisional:
        assert(false, 'Statuses on iOS only');
    }
  }

  Future<void> _showLocationPermissionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Precise Location Permission Required'),
          content: const Text(
            'Please enable precise location permissions in your device settings to continue.\n\nWi-Fi information is considered location information on Android.',
          ),
          actions: <Widget>[
            OutlinedButton(
              child: const Text('Continue'),
              // TODO (APP-8749): If we are provisioning a new machine (not reconnecting) we need to delete the robot and take the user back to the home screen.
              // This is because we cannot proceed if they do not have location permissions on for Android.
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
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
            final response = await hotspotProvisioningRepository.getSmartMachineStatus();
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

    final connectedSSID = await hotspotProvisioningRepository.getCurrentSSID();
    // In case we are already connected to the hotspot, we can just go to the next step, finding the provisioned machine.
    if (connectedSSID != null && connectedSSID.replaceAll('"', '').startsWith(hotspotPrefix) && _connectedToHotspot) {
      debugPrint('Already connected to $hotspotPrefix hotspot');
      _findProvisionedMachine();
      return;
    }
    // If we are not connected to the hotspot, we need to connect to it.
    debugPrint('Connecting to $hotspotPrefix-#### hotspot');
    final connected = await hotspotProvisioningRepository.connectToSecureNetworkByPrefix(
      prefix: hotspotPrefix,
      password: hotspotPassword,
      isWep: false,
      isWpa3: false,
      saveNetwork: true, // flips joinOnce on iOS to false
    );
    if (connected) {
      final connectedSSID = await hotspotProvisioningRepository.getCurrentSSID();
      if (connectedSSID != null && connectedSSID != '<unknown ssid>' && connectedSSID.replaceAll('"', '').startsWith(hotspotPrefix)) {
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
