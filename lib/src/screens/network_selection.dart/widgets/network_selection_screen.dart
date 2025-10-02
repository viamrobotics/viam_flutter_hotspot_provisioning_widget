part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class NetworkSelectionScreen extends StatefulWidget {
  final void Function(NetworkInfo) onSelectNetwork;
  final VoidCallback onManualEntry;
  final Viam viam;

  const NetworkSelectionScreen({
    super.key,
    required this.onSelectNetwork,
    required this.onManualEntry,
    required this.viam,
  });

  @override
  State<NetworkSelectionScreen> createState() => _NetworkSelectionScreenState();
}

class _NetworkSelectionScreenState extends State<NetworkSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final viewModel = context.read<NetworkSelectionViewModel>();
        viewModel.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkSelectionViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.loadingNetworks) {
          return const NoContentWidget(
            titleString: "Scanning...",
            bodyString: "Looking for visible networks...",
          );
        }
        if (viewModel.machineVisibleNetworks.isEmpty) {
          return NoContentWidget(
              icon: const Icon(Icons.error, color: Colors.red),
              buttons: [
                FilledButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return TroubleshootingDialog(onManualEntry: widget.onManualEntry);
                      },
                    );
                  },
                  child: Text(
                    "My network isn't showing up",
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w500),
                  ),
                ),
                FilledButton(
                  onPressed: viewModel.loadingNetworks ? null : () => viewModel.getNetworks(refresh: true),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Theme.of(context).colorScheme.onPrimary),
                      SizedBox(width: 8),
                      Text("Try again", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
              titleString: "No networks found",
              bodyString: "Is your device powered on and nearby? Try turning the device off and back on.");
        }
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top text
              Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Text(
                  "Connect to your machine's Wi-Fi",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              // ListView in the middle
              Expanded(
                child: Material(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surface,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: viewModel.machineVisibleNetworks.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () => widget.onSelectNetwork(viewModel.machineVisibleNetworks[index]),
                        child: ProvisioningListItem(
                          textString: viewModel.machineVisibleNetworks[index].ssid,
                          leading: Icon(
                            viewModel.signalToIcon(viewModel.machineVisibleNetworks[index].signal),
                            size: 24.0,
                            color: Colors.grey,
                          ),
                          add: false,
                          trailing: Icon(
                            viewModel.securityToIcon(viewModel.machineVisibleNetworks[index].security),
                            size: 20.0,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      elevation: 0,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return TroubleshootingDialog(onManualEntry: widget.onManualEntry);
                        },
                      );
                    },
                    child: Text(
                      "My network isn't showing up",
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
