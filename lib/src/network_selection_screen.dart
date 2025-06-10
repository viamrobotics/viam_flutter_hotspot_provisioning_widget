part of '../../viam_flutter_hotspot_provisioning_widget.dart';

class NetworkSelectionScreen extends StatefulWidget {
  final void Function(NetworkInfo) onSelectNetwork;
  final VoidCallback onManualEntry;

  const NetworkSelectionScreen({
    super.key,
    required this.onSelectNetwork,
    required this.onManualEntry,
  });

  @override
  State<NetworkSelectionScreen> createState() => _NetworkSelectionScreenState();
}

class _NetworkSelectionScreenState extends State<NetworkSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NetworkSelectionViewModel>().getNetworks();
      }
    });
  }

  IconData signalToIcon(int signal) {
    if (signal <= 40) return Icons.wifi_1_bar;
    if (40 <= signal && signal <= 70) return Icons.wifi_2_bar;
    return Icons.wifi;
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
                const Text(
                  "Troubleshooting",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "If your boat's Wi-Fi network isn't showing up in this list, turn your Specter AI device off and back on again.\n\n"
                  "If you've tried this and it still isn't appearing, you can connect by manually entering your network info.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onManualEntry();
                    },
                    text: "Manually enter network info",
                  ),
                ),
                const SizedBox(height: 12),
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
    final viewModel = context.watch<NetworkSelectionViewModel>();
    return Column(
      children: [
        Expanded(
          child: viewModel.loadingNetworks
              ? const NoContentWidget(
                  titleString: "Scanning...",
                  bodyString: "Looking for visible networks...",
                )
              : viewModel.machineVisibleNetworks.isEmpty
                  ? NoContentWidget(
                      icon: const Icon(Icons.error, color: Colors.red),
                      buttons: [
                        FilledButton(
                          onPressed: () {
                            _showTroubleshootingDialog();
                          },
                          child:
                              const Text("My network isn't showing up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        ),
                        FilledButton(
                          onPressed: viewModel.loadingNetworks ? null : () => viewModel.getNetworks(refresh: true),
                          child: const Row(
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
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
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
                            itemCount: viewModel.machineVisibleNetworks.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () => widget.onSelectNetwork(viewModel.machineVisibleNetworks[index]),
                                child: ProvisioningListItem(
                                  textString: viewModel.machineVisibleNetworks[index].ssid,
                                  leading: Icon(
                                    signalToIcon(viewModel.machineVisibleNetworks[index].signal),
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
                              child: const Text(
                                "My network isn't showing up",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }
}
