part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class ConnectHotspotPrefixViewModel extends ChangeNotifier {
  ConnectHotspotPrefixViewModel({
    required Viam viam,
    required BuildContext context,
    required String hotspotPrefix,
    required String hotspotPassword,
    required VoidCallback onNavigateToNetworkSelection,
  })  : _viam = viam,
        _context = context,
        _hotspotPrefix = hotspotPrefix,
        _hotspotPassword = hotspotPassword,
        _onNavigateToNetworkSelection = onNavigateToNetworkSelection;

  final Viam _viam;
  final BuildContext _context;
  final String _hotspotPrefix;
  final String _hotspotPassword;
  final VoidCallback _onNavigateToNetworkSelection;

  bool _isAttemptingConnectionToHotspot = false;
  bool _isRetryingHotspot = false;
  Timer? _pollingTimer;
  bool _foundValidSmartMachineStatus = false;
  bool _pollingForMachine = false;
  bool _connectedToHotspot = false;
  int _retryCount = 0;

  bool get isAttemptingConnectionToHotspot => _isAttemptingConnectionToHotspot;
  bool get isRetryingHotspot => _isRetryingHotspot;
  bool get foundValidSmartMachineStatus => _foundValidSmartMachineStatus;
  bool get pollingForMachine => _pollingForMachine;
  bool get connectedToHotspot => _connectedToHotspot;
  int get retryCount => _retryCount;

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

  void _setRetryCount(int value) {
    _retryCount = value;
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
      context: _context,
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
              // TODO: we need to do some clean up with the robot here if we were provisioning a new machine, if we care about that.
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<GetSmartMachineStatusResponse> getSmartMachineStatus() async {
    return await _viam.provisioningClient.getSmartMachineStatus();
  }

  void _findProvisionedMachine() {
    if (_pollingForMachine || _foundValidSmartMachineStatus) return;

    _setPollingForMachine(true);
    _setConnectedToHotspot(true);
    _setIsAttemptingConnectionToHotspot(false);
    _setRetryCount(0);

    // Ensure we don't start multiple timers
    if (!_foundValidSmartMachineStatus && (_pollingTimer == null || !_pollingTimer!.isActive)) {
      debugPrint('Starting periodic check every 3 seconds');
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
        try {
          debugPrint('checking smart machine status');
          final response = await getSmartMachineStatus();
          debugPrint('provisioningInfo: ${response.provisioningInfo}');
          _pollingTimer?.cancel();
          _setFoundValidSmartMachineStatus(true);
          _setPollingForMachine(false);
          // TODO: continue with a found machine for machine already exists flow
          _onNavigateToNetworkSelection();
        } catch (e) {
          debugPrint('Error during smart machine status check, continuing polling. Error: $e');
        }
      });
    }
  }

  void connectToHotspot() async {
    try {
      debugPrint('connectToHotspot called and retryCount is $_retryCount');
      _setIsAttemptingConnectionToHotspot(true);
      _setIsRetryingHotspot(false);

      final connectedSSID = await PluginWifiConnect.ssid;
      debugPrint('Current SSID: $connectedSSID');
      if (connectedSSID != null && connectedSSID.startsWith(_hotspotPrefix)) {
        debugPrint('Already connected to $_hotspotPrefix hotspot');
        _findProvisionedMachine();
        return;
      }

      final disconnected = await PluginWifiConnect.disconnect();
      debugPrint('disconnected: $disconnected');
      debugPrint('Connecting to $_hotspotPrefix-#### hotspot');
      final connected = await PluginWifiConnect.connectToSecureNetworkByPrefix(
        _hotspotPrefix,
        _hotspotPassword,
        isWep: false,
        isWpa3: false,
        saveNetwork: true, // flips joinOnce on iOS to false
      );

      switch (connected) {
        case true:
          debugPrint('Connected to hotspot');
          final connectedSSID = await PluginWifiConnect.ssid;
          if (connectedSSID != null && connectedSSID != '<unknown ssid>') {
            _findProvisionedMachine();
          } else {
            throw Exception('Connected to hotspot but no or unknown SSID returned');
          }
          break;
        case false:
          throw Exception('Finished connection attempt with connected=false and no error');
        case null:
          _setIsAttemptingConnectionToHotspot(false);
          break; // user cancelled, do nothing
      }
    } catch (e) {
      if (_retryCount < 2) {
        _setRetryCount(_retryCount + 1);
        await Future.delayed(const Duration(seconds: 2));
        connectToHotspot();
      } else {
        debugPrint('Error connecting to hotspot: ${e.toString()}');
        _setIsRetryingHotspot(true);
        _setRetryCount(0);
        _setIsAttemptingConnectionToHotspot(false);
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
