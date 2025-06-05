import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:plugin_wifi_connect/plugin_wifi_connect.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viam_sdk/viam_sdk.dart';
import 'package:viam_sdk/protos/app/app.dart';
import 'package:viam_sdk/src/utils.dart'; // ignore: implementation_imports

import 'consts.dart';
import 'primary_button.dart';
import 'network_selection_screen.dart';

enum ProvisioningMode { newMachine, reconnect }

class ConnectHotspotPrefixScreen extends StatefulWidget {
  final Robot robot;
  final ProvisioningMode mode;
  final String? hotspotSsid;

  const ConnectHotspotPrefixScreen({super.key, required this.robot, required this.mode, this.hotspotSsid});

  @override
  State<ConnectHotspotPrefixScreen> createState() => _ConnectHotspotPrefixScreenState();
}

class _ConnectHotspotPrefixScreenState extends State<ConnectHotspotPrefixScreen> {
  // bool _isAttemptingConnectionToHotspot = false;
  // bool _isRetryingHotspot = false;
  // bool _connectedToHotspot = false;
  // Timer? _pollingTimer;
  // bool foundValidSmartMachineStatus = false;
  // bool _pollingForMachine = false;
  // int _retryCount = 0;

  bool _isAttemptingConnectionToHotspot = false;
  bool _isRetryingHotspot = false;
  Timer? _pollingTimer;
  bool _foundValidSmartMachineStatus = false;
  bool _pollingForMachine = false;
  bool _connectedToHotspot = false;
  int _retryCount = 0;
  String? _storedSsid;

  late Viam _viam;
  // late Robot _robot;
  late RobotPart _mainPart;
  static const listStyle = TextStyle(
    color: Colors.black,
    fontSize: 16.0,
  );

  @override
  void initState() {
    super.initState();
    _initViam();
    // do we need to reset the robot for any reason here??
    // do we need to reset the main part for any reason here?
    if (widget.mode == ProvisioningMode.reconnect) {
      _getStoredSsid();
    }
    if (Platform.isAndroid) {
      _getLocationPermission();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initViam() async {
    try {
      _viam = await Viam.withApiKey(Consts.apiKeyId, Consts.apiKey);
      // you MUST create the robot before connecting to the hotspot
      // once connected to the hotspot you can communicate with the machine, but will not have interet access
      _getMainPart(); // do we need this if we already have a robot?
    } catch (e) {
      debugPrint('Error initializing Viam: $e');
    }
  }
// we already have a robot when we get to this screen
  // Future<void> _createRobot() async {
  //   final location = await _viam.appClient.createLocation(Consts.organizationId, 'test-location-${Random().nextInt(1000)}');
  //   final String robotName = "tester-${Random().nextInt(1000)}";
  //   debugPrint('robotName: $robotName, locationId: ${location.name}');
  //   final robotId = await _viam.appClient.newMachine(robotName, location.id);
  //   _robot = await _viam.appClient.getRobot(robotId);
  //   _mainPart = (await _viam.appClient.listRobotParts(robotId)).firstWhere((element) => element.mainPart);
  // }

  // move to view model
  Future<void> _getMainPart() async {
    _mainPart = (await _viam.appClient.listRobotParts(widget.robot.id)).firstWhere((element) => element.mainPart);
  }

  Future<void> _getStoredSsid() async {
    // final provisioningState = Provider.of<ProvisioningState>(context, listen: false);
    final metadata = await _viam.appClient.getRobotMetadata(widget.robot.id);
    final metadataMap = metadata.data.toMap();
    _storedSsid = metadataMap['hotspot_ssid'] as String?;
    if (_storedSsid == null) {
      // if still null, try to get from shared prefs and update the robot metadata
      final robotId = widget.robot.id; // just using the robot i was given
      final sharedPrefs = await SharedPreferences.getInstance();
      final sharedPrefsSsid = sharedPrefs.getString('${robotId}_hotspot_ssid');
      if (sharedPrefsSsid != null) {
        _storedSsid = sharedPrefsSsid;
        await _viam.appClient.updateRobotMetadata(robotId, {'hotspot_ssid': sharedPrefsSsid});
      }
    }
  }
// this should be in a view model too probs

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
  // void _findProvisionedMachine() {
  //   if (!mounted || _pollingForMachine || foundValidSmartMachineStatus) return;
  //   setState(() {
  //     _pollingForMachine = true;
  //   });
  //   // Ensure we don't start multiple timers
  //   if (!foundValidSmartMachineStatus && (_pollingTimer == null || !_pollingTimer!.isActive)) {
  //     debugPrint('Starting periodic check every 3 seconds');
  //     _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
  //       try {
  //         debugPrint('checking smart machine status');
  //         final provisioningInfo = await getSmartMachineProvisioningInfo();
  //         if (provisioningInfo != null) {
  //           debugPrint('provisioningInfo: $provisioningInfo');
  //           _pollingTimer?.cancel();
  //           setState(() {
  //             foundValidSmartMachineStatus = true;
  //             _pollingForMachine = false;
  //           });
  //           _navigateToNetworkSelection();
  //         }
  //       } catch (e) {
  //         debugPrint('Error during smart machine status check, continuing polling. Error: $e');
  //       }
  //     });
  //   }
  // }

  // this needs to be moved to view model also
  Future<GetSmartMachineStatusResponse> getSmartMachineStatus() async {
    return await _viam.provisioningClient.getSmartMachineStatus();
  }

  void _findProvisionedMachine(String hotspotSsid) {
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
          // final provisioningState = Provider.of<ProvisioningState>(context, listen: false);
          final response = await getSmartMachineStatus();
          debugPrint('provisioningInfo: ${response.provisioningInfo}');
          _pollingTimer?.cancel();
          setState(() {
            _foundValidSmartMachineStatus = true;
            _pollingForMachine = false;
          });
          _continueWithFoundMachine(
            hotspotSsid: hotspotSsid,
            hasSmartMachineCredentials: response.hasSmartMachineCredentials,
          );
        } catch (e) {
          debugPrint('Error during smart machine status check, continuing polling. Error: $e');
        }
      });
    }
  }

  Future<ProvisioningInfo?> getSmartMachineProvisioningInfo() async {
    final response = await _viam.provisioningClient.getSmartMachineStatus();
    // TODO: alreadyHasSmartMachineCredentials = response.hasSmartMachineCredentials; use to skip step later
    return response.provisioningInfo;
  }

  void _continueWithFoundMachine({required String hotspotSsid, required bool hasSmartMachineCredentials}) async {
    switch (widget.mode) {
      case ProvisioningMode.newMachine:
        if (hasSmartMachineCredentials) {
          _machineExistsDialog();
        } else {
          _navigateToNetworkSelection(hotspotSsid);
        }
      case ProvisioningMode.reconnect:
        if (hasSmartMachineCredentials) {
          if (_storedSsid == hotspotSsid) {
            _navigateToNetworkSelection(hotspotSsid);
          } else {
            _machineExistsDialog();
          }
        } else {
          // In this case the machine exists but doesn't have machine creds yet.
          // This can happen if the user created the machine but didn't complete the provisioning process.
          // We should allow them to complete the provisioning process now
          _navigateToNetworkSelection(hotspotSsid);
        }
    }
  }

  Future<void> _machineExistsDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Machine has Credentials'),
          content: const Text(
            'The machine with this hotspot has Viam credentials set.\n\nYou can find and re-connect this machine from the home screen if you\'re the owner.',
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
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
              onPressed: () => _navigateToHomeScreenCleanup(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToHomeScreenCleanup() async {
    await PluginWifiConnect.disconnect(); // can't delete if still on the hotspot
    if (widget.mode == ProvisioningMode.newMachine && widget.robot != null) {
      // shouldn't delete if use is reconnecting
      // should only delete the case where the use setup a new machine that we won't ever get online
      _viam.appClient.deleteRobot(widget.robot.id); // fire and forget
    }
    if (mounted) {
      Navigator.of(context).pop(); // im not sure if this is even the right place to pop and do this in
    }
  }

  // void _connectToHotspot(BuildContext context) async {
  //   try {
  //     debugPrint('connectToHotspot called and retryCount is $_retryCount');
  //     setState(() {
  //       _isAttemptingConnectionToHotspot = true;
  //       _isRetryingHotspot = false;
  //     });
  //     final connectedSSID = await PluginWifiConnect.ssid;
  //     debugPrint('Current SSID: $connectedSSID');
  //     if (connectedSSID != null && connectedSSID.startsWith(Consts.hotspotPrefix)) {
  //       debugPrint('Already connected to hotspot');
  //       if (context.mounted) {
  //         setState(() {
  //           _connectedToHotspot = true;
  //           _isAttemptingConnectionToHotspot = false;
  //         });
  //         _findProvisionedMachine(hotspotSsid);
  //       }
  //       return;
  //     }
  //     final disconnected = await PluginWifiConnect.disconnect();
  //     debugPrint('disconnected: $disconnected');
  //     debugPrint('Connecting to ${Consts.hotspotPrefix}-#### hotspot');
  //     final connected = await PluginWifiConnect.connectToSecureNetworkByPrefix(
  //       Consts.hotspotPrefix,
  //       Consts.hotspotPassword,
  //       isWep: false,
  //       isWpa3: false,
  //       saveNetwork: true, // flips joinOnce on iOS to false
  //     );
  //     switch (connected) {
  //       case true:
  //         debugPrint('Connected to hotspot');
  //         if (context.mounted) {
  //           _retryCount = 0;
  //           setState(() {
  //             _connectedToHotspot = true;
  //             _isAttemptingConnectionToHotspot = false; // Connection attempt phase is over
  //           });
  //           _findProvisionedMachine();
  //         }
  //         break;
  //       case false:
  //         throw Exception('Finished connection attempt with connected=false and no error');
  //       case null:
  //         if (mounted) {
  //           setState(() {
  //             _isAttemptingConnectionToHotspot = false; // Stop loading indicator
  //           });
  //         }
  //         break; // user cancelled, do nothing
  //     }
  //   } catch (e) {
  //     if (_retryCount < 2) {
  //       _retryCount++;
  //       await Future.delayed(const Duration(seconds: 2));
  //       if (context.mounted) {
  //         _connectToHotspot(context);
  //       }
  //     } else {
  //       if (context.mounted) {
  //         debugPrint('Error connecting to hotspot: ${e.toString()}');
  //         setState(() {
  //           _isRetryingHotspot = true;
  //           _retryCount = 0;
  //           _isAttemptingConnectionToHotspot = false;
  //         });
  //       }
  //     }
  //   }
  // }
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
        _findProvisionedMachine(connectedSSID);
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
              _findProvisionedMachine(connectedSSID);
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

  void _navigateToNetworkSelection(String hotspotSsid) {
    if (!mounted) return;
    debugPrint('Navigating to network selection screen...');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/network-selection'),
        builder: (context) => NetworkSelectionScreen(robot: widget.robot, viam: _viam, hotspotSsid: hotspotSsid, mainPart: _mainPart),
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
