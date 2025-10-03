part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class NetworkSelectionScreen extends StatefulWidget {
  final void Function(NetworkInfo) onSelectNetwork;
  final VoidCallback onManualEntry;
  final Viam viam;
  final NetworkSelectionViewModel viewModel;

  const NetworkSelectionScreen({
    super.key,
    required this.onSelectNetwork,
    required this.onManualEntry,
    required this.viam,
    required this.viewModel,
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
        widget.viewModel.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        if (widget.viewModel.loadingNetworks) {
          return const NoContentWidget(
            titleString: "Scanning...",
            bodyString: "Looking for visible networks...",
          );
        }
        if (widget.viewModel.machineVisibleNetworks.isEmpty) {
          return NoContentWidget(
              icon: Icon(Icons.error, color: Theme.of(context).colorScheme.error),
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
                  onPressed: widget.viewModel.loadingNetworks ? null : () => widget.viewModel.getNetworks(refresh: true),
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
                    itemCount: widget.viewModel.machineVisibleNetworks.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () => widget.onSelectNetwork(widget.viewModel.machineVisibleNetworks[index]),
                        child: ProvisioningListItem(
                          textString: widget.viewModel.machineVisibleNetworks[index].ssid,
                          leading: Icon(
                            widget.viewModel.signalToIcon(widget.viewModel.machineVisibleNetworks[index].signal),
                            size: 24.0,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          add: false,
                          trailing: Icon(
                            widget.viewModel.securityToIcon(widget.viewModel.machineVisibleNetworks[index].security),
                            size: 20.0,
                            color: Theme.of(context).colorScheme.onSurface,
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
