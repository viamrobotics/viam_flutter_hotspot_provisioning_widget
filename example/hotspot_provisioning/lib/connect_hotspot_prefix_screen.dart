import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plugin_wifi_connect/plugin_wifi_connect.dart';
import 'package:viam_sdk/viam_sdk.dart';

import 'consts.dart';
import 'primary_button.dart';

class ConnectHotspotPrefixScreen extends StatefulWidget {
  const ConnectHotspotPrefixScreen({super.key});

  @override
  State<ConnectHotspotPrefixScreen> createState() => _ConnectHotspotPrefixScreenState();
}

class _ConnectHotspotPrefixScreenState extends State<ConnectHotspotPrefixScreen> {
  bool _isAttemptingConnectionToHotspot = false;
  bool _isRetryingHotspot = false;
  Timer? _pollingTimer;
  bool foundValidSmartMachineStatus = false;
  bool _pollingForMachine = false;
  int _retryCount = 0;

  static const listStyle = TextStyle(
    color: Colors.black,
    fontSize: 16.0,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _findProvisionedMachine() {
    if (!mounted || _pollingForMachine || foundValidSmartMachineStatus) return;
    setState(() {
      _pollingForMachine = true;
    });
    // Ensure we don't start multiple timers
    if (!foundValidSmartMachineStatus && (_pollingTimer == null || !_pollingTimer!.isActive)) {
      debugPrint('Starting periodic check every 3 seconds');
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
        try {
          debugPrint('checking smart machine status');
          final provisioningInfo = await getSmartMachineProvisioningInfo();
          if (provisioningInfo != null) {
            debugPrint('provisioningInfo: $provisioningInfo');
            _pollingTimer?.cancel();
            setState(() {
              foundValidSmartMachineStatus = true;
              _pollingForMachine = false;
            });
            _navigateToNetworkSelection();
          }
        } catch (e) {
          debugPrint('Error during smart machine status check, continuing polling. Error: $e');
        }
      });
    }
  }

  Future<ProvisioningInfo?> getSmartMachineProvisioningInfo() async {
    final viam = await Viam.withApiKey(Consts.viamApiKeyId, Consts.viamApiKey);
    final response = await viam.provisioningClient.getSmartMachineStatus();
    // TODO: alreadyHasSmartMachineCredentials = response.hasSmartMachineCredentials; use to skip step later
    return response.provisioningInfo;
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
        debugPrint('Already connected to hotspot');
        if (context.mounted) {
          setState(() {
            _isAttemptingConnectionToHotspot = false;
          });
          _findProvisionedMachine();
        }
        return;
      }
      final disconnected = await PluginWifiConnect.disconnect();
      debugPrint('disconnected: $disconnected');
      debugPrint('Connecting to ${Consts.hotspotPrefix}-#### hotspot');
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
            _retryCount = 0;
            setState(() {
              _isAttemptingConnectionToHotspot = false; // Connection attempt phase is over
            });
            _findProvisionedMachine();
          }
          break;
        case false:
          throw Exception('Finished connection attempt with connected=false and no error');
        case null:
          if (mounted) {
            setState(() {
              _isAttemptingConnectionToHotspot = false; // Stop loading indicator
            });
          }
          break; // user cancelled, do nothing
      }
    } catch (e) {
      if (_retryCount < 2) {
        _retryCount++;
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

  // TODO: implement this
  void _navigateToNetworkSelection() {
    // if (!mounted) return;
    // debugPrint('Navigating to network selection screen...');
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     settings: const RouteSettings(name: '/network-selection'),
    //     builder: (context) => NetworkSelectionScreen(),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text('Connect to Device Hotspot'),
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
