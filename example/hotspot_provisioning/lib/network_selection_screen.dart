import 'dart:async';

import 'package:flutter/material.dart';
import 'package:viam_sdk/protos/provisioning/provisioning.dart';
import 'package:viam_sdk/viam_sdk.dart';

import 'no_content_widget.dart';
import 'pill_button.dart';
import 'provisioning_list_item.dart';
import 'password_input_screen.dart';

class NetworkSelectionScreen extends StatefulWidget {
  const NetworkSelectionScreen({super.key});

  @override
  State<NetworkSelectionScreen> createState() => _NetworkSelectionScreenState();
}

class _NetworkSelectionScreenState extends State<NetworkSelectionScreen> {
  bool _loadingNetworks = false;
  List<NetworkInfo> machineVisibleNetworks = [];

  @override
  void initState() {
    super.initState();
    _getNetworks();
  }

  Future<void> _getNetworks({bool refresh = false}) async {
    setState(() {
      _loadingNetworks = true;
    });
    try {
      if (refresh) {
        // The loading seems too fast for the user to trust
        await Future.delayed(Duration(milliseconds: 500));
      }
      if (mounted) {
        // TODO: DO DIRECTLY!
        //await Provider.of<ProvisioningState>(context, listen: false).getNetworkList();
      }
    } catch (e) {
      debugPrint('getNetworkList error: ${e.toString()}'); // not showing error, but _loadingNetworks=false allows the retry
    }
    setState(() {
      _loadingNetworks = false;
    });
  }

  IconData signalToIcon(int signal) {
    if (signal <= 40) return Icons.wifi_1_bar;
    if (40 <= signal && signal <= 70) return Icons.wifi_2_bar;
    return Icons.wifi;
  }

  void _goToPasswordInputScreen(NetworkInfo network) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordInputScreen(network: network)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect to your vessel’s Wi-Fi'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey, size: 24.0),
            onPressed: () => _getNetworks(refresh: true),
          )
        ],
      ),
      body: SafeArea(
        child: _loadingNetworks
            ? NoContentWidget(
                titleString: "Scanning...",
                bodyString: "Looking for visible networks...",
              )
            : machineVisibleNetworks.isEmpty
                ? NoContentWidget(
                    icon: Icon(Icons.error, color: Colors.red),
                    button: PillButton(
                      iconData: Icons.refresh,
                      buttonString: "Try again",
                      onPressed: _loadingNetworks ? null : () => _getNetworks(refresh: true),
                    ),
                    titleString: "No networks found",
                    bodyString: "Make sure your device is turned on and nearby",
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                        child: Text(
                          "Connect to your vessel’s Wi-Fi",
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: machineVisibleNetworks.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () => _goToPasswordInputScreen(machineVisibleNetworks[index]),
                              child: ProvisioningListItem(
                                textString: machineVisibleNetworks[index].ssid,
                                leading: Icon(
                                  signalToIcon(machineVisibleNetworks[index].signal),
                                  size: 24.0,
                                  color: Colors.grey,
                                ),
                                add: false,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
