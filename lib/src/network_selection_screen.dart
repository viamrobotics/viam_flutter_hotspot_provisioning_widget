part of '../../viam_flutter_hotspot_provisioning_widget.dart';

class NetworkSelectionScreen extends StatefulWidget {
  final Viam viam;
  final Robot robot;
  final RobotPart mainPart;

  const NetworkSelectionScreen({
    super.key,
    required this.viam,
    required this.robot,
    required this.mainPart,
  });

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
        final networks = await widget.viam.provisioningClient.getNetworkList();
        final sortedNetworks = networks.toList()..sort((b, a) => a.signal.compareTo(b.signal));
        setState(() {
          machineVisibleNetworks = sortedNetworks;
        });
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

// TODO: sometimes we call this function and othertimes we just navigation to passwordInput screen. why?
  void _goToPasswordInputScreen(NetworkInfo network) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordInputScreen(
          network: network,
          viam: widget.viam,
          robot: widget.robot,
          mainPart: widget.mainPart,
        ),
      ),
    );
  }

  void _showTroubleshootingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Troubleshooting",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "If your boat’s Wi-Fi network isn’t showing up in this list, turn your Specter AI device off and back on again.\n\n"
                  "If you’ve tried this and it still isn’t appearing, you can connect by manually entering your network info.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PasswordInputScreen(
                            // not passing networks here bc we dont see the network
                            viam: widget.viam,
                            robot: widget.robot,
                            mainPart: widget.mainPart,
                          ),
                        ),
                      );
                    },
                    text: "Manually enter network info",
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    text: "Close",
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text('Connect to your vessel’s Wi-Fi'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black, size: 24.0),
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
                    buttons: [
                      FilledButton(
                        onPressed: () {
                          _showTroubleshootingDialog();
                        },
                        child: Text("My network isn't showing up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      ),
                      FilledButton(
                        onPressed: _loadingNetworks ? null : () => _getNetworks(refresh: true),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, color: Colors.white),
                            SizedBox(width: 8),
                            Text("Try again", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                    titleString: "No networks found",
                    bodyString: "Is your device powered on and nearby? Try turning the device off and back on.")
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                        child: Text(
                          "Connect to your machine's Wi-Fi",
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                            ),
                            onPressed: _showTroubleshootingDialog,
                            child: Text(
                              "My network isn't showing up",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
