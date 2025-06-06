import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plugin_wifi_connect/plugin_wifi_connect.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:viam_sdk/viam_sdk.dart';
import 'package:viam_sdk/protos/app/app.dart';

import 'consts.dart';
import 'primary_button.dart';
import 'network_selection_screen.dart';

// Currently, we are assuming that we are always provisioning a new machine. 

class ConnectHotspotPrefixScreen extends StatefulWidget {
  final Robot robot;
  final Viam viam;
  final RobotPart mainPart;


  const ConnectHotspotPrefixScreen({super.key, required this.robot, required this.viam, required this.mainPart});

  @override
  State<ConnectHotspotPrefixScreen> createState() => _ConnectHotspotPrefixScreenState();
}

class _ConnectHotspotPrefixScreenState extends State<ConnectHotspotPrefixScreen> {
  bool _isAttemptingConnectionToHotspot = false;
  bool _isRetryingHotspot = false;
  Timer? _pollingTimer;
  bool _foundValidSmartMachineStatus = false;
  bool _pollingForMachine = false;
  bool _connectedToHotspot = false;
  int _retryCount = 0;
  // String? _storedSsid;
  static const listStyle = TextStyle(
    color: Colors.black,
    fontSize: 16.0,
  );

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _getLocationPermission();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // TODO: separate out business logic from view logic for entire screen.

  /// Android considers Wi-Fi information to be location information
  /// If we don't have location permission any connected ssid will show as 'unown ssid'
  Future<void> _getLocationPermission() async {
    final status = await ph.Permission.location.request();
    switch (status) {
      case ph.PermissionStatus.granted:
        break; // safe to continue!
      case ph.PermissionStatus.denied:
      case ph.PermissionStatus.permanentlyDenied:
      case ph.PermissionStatus.restricted:
        _needLocationPermissionDialog();
      case ph.PermissionStatus.limited:
      case ph.PermissionStatus.provisional:
        assert(false, 'Statuses on iOS only');
    }
  }

  // this needs to be moved to view model also
  Future<GetSmartMachineStatusResponse> getSmartMachineStatus() async {
    return await widget.viam.provisioningClient.getSmartMachineStatus();
  }

  void _findProvisionedMachine() {
    if (!mounted || _pollingForMachine || _foundValidSmartMachineStatus) return;
    setState(() {
      _pollingForMachine = true;
      _connectedToHotspot = true;
      _isAttemptingConnectionToHotspot = false;
      _retryCount = 0;
    });
    // Ensure we don't start multiple timers
    if (!_foundValidSmartMachineStatus && (_pollingTimer == null || !_pollingTimer!.isActive)) {
      debugPrint('Starting periodic check every 3 seconds');
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
        try {
          debugPrint('checking smart machine status');
          final response = await getSmartMachineStatus();
          debugPrint('provisioningInfo: ${response.provisioningInfo}');
          _pollingTimer?.cancel();
          setState(() {
            _foundValidSmartMachineStatus = true;
            _pollingForMachine = false;
          });
          // TODO: continue with a found machine for machine already exists flow
          _navigateToNetworkSelection();
        } catch (e) {
          debugPrint('Error during smart machine status check, continuing polling. Error: $e');
        }
      });
    }
  }

  Future<ProvisioningInfo?> getSmartMachineProvisioningInfo() async {
    final response = await widget.viam.provisioningClient.getSmartMachineStatus();
    // TODO: alreadyHasSmartMachineCredentials = response.hasSmartMachineCredentials; use to skip step later
    return response.provisioningInfo;
  }

  Future<void> _needLocationPermissionDialog() async {
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
              // TODO: we need to do some clean up with the robot here if we were provisioning a new machine, if we care about that. 
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _connectToHotspot(BuildContext context) async {
    try {
      debugPrint('connectToHotspot called and retryCount is $_retryCount');
      setState(() {
        _isAttemptingConnectionToHotspot = true;
        _isRetryingHotspot = false;
      });
      final connectedSSID = await PluginWifiConnect.ssid;
      debugPrint('Current SSID: $connectedSSID');
      if (connectedSSID != null && connectedSSID.startsWith(Consts.hotspotPrefix)) {
        debugPrint('Already connected to gost hotspot');
        _findProvisionedMachine();
        return;
      }
      final disconnected = await PluginWifiConnect.disconnect();
      debugPrint('disconnected: $disconnected');
      debugPrint('Connecting to gost-#### hotspot');
      final connected = await PluginWifiConnect.connectToSecureNetworkByPrefix(
        Consts.hotspotPrefix,
        Consts.hotspotPassword,
        isWep: false,
        isWpa3: false,
        saveNetwork: true, // flips joinOnce on iOS to false
      );
      switch (connected) {
        case true:
          debugPrint('Connected to hotspot');
          if (context.mounted) {
            final connectedSSID = await PluginWifiConnect.ssid;
            if (connectedSSID != null && connectedSSID != '<unknown ssid>') {
              _findProvisionedMachine();
            } else {
              throw Exception('Connected to hotspot but no or unknown SSID returned');
            }
          }
          break;
        case false:
          throw Exception('Finished connection attempt with connected=false and no error');
        case null:
          if (mounted) {
            setState(() {
              _isAttemptingConnectionToHotspot = false;
            });
          }
          break; // user cancelled, do nothing
      }
    } catch (e) {
      if (_retryCount < 2) {
        setState(() {
          _retryCount++;
        });
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          _connectToHotspot(context);
        }
      } else {
        if (context.mounted) {
          debugPrint('Error connecting to hotspot: ${e.toString()}');
          setState(() {
            _isRetryingHotspot = true;
            _retryCount = 0;
            _isAttemptingConnectionToHotspot = false;
          });
        }
      }
    }
  }

// TODO: control navigation outside of this screen.
  void _navigateToNetworkSelection() {
    if (!mounted) return;
    debugPrint('Navigating to network selection screen...');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/network-selection'),
        builder: (context) => NetworkSelectionScreen(robot: widget.robot, viam: widget.viam, mainPart: widget.mainPart),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Connect to Device Hotspot', style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 24.0),
                      child: Text(
                        "Steps to connect to your device:",
                        style: const TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 14.0, bottom: 20.0),
                      child: Text("1. Turn on the device you are trying to connect to.", style: listStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 14.0, bottom: 20.0),
                      child: Text("2. Make sure you are nearby the device.", style: listStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 14.0, bottom: 20.0),
                      child: Text("3. Press the button below to connect to the device's hotspot.", style: listStyle),
                    ),
                    if (_connectedToHotspot)
                      Padding(
                        padding: const EdgeInsets.only(left: 14.0, bottom: 20.0),
                        child: Column(
                          children: [
                            Text("You are connected to the device's hotspot.", style: listStyle),
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                Spacer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14.0, right: 14.0, bottom: 28.0),
                  child: PrimaryButton(
                    onPressed: _isAttemptingConnectionToHotspot || _pollingForMachine ? null : () => _connectToHotspot(context),
                    text: _isRetryingHotspot ? "Retry Connect to Device Hotspot" : "Connect to Device Hotspot",
                    isLoading: _isAttemptingConnectionToHotspot || _pollingForMachine,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
