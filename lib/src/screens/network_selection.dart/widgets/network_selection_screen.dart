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
  NetworkSelectionViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = NetworkSelectionViewModel(viam: widget.viam);
    // Initialize after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _viewModel?.initialize();
      }
    });
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel == null) {
      return const SizedBox.shrink(); // or some loading indicator
    }

    return ListenableBuilder(
      listenable: _viewModel!,
      builder: (context, _) {
        return Column(
          children: [
            Expanded(
              child: _viewModel!.loadingNetworks
                  ? const NoContentWidget(
                      titleString: "Scanning...",
                      bodyString: "Looking for visible networks...",
                    )
                  : _viewModel!.machineVisibleNetworks.isEmpty
                      ? NoContentWidget(
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
                              onPressed: _viewModel!.loadingNetworks ? null : () => _viewModel!.getNetworks(refresh: true),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh, color: Theme.of(context).colorScheme.onPrimary),
                                  SizedBox(width: 8),
                                  Text("Try again",
                                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ],
                          titleString: "No networks found",
                          bodyString: "Is your device powered on and nearby? Try turning the device off and back on.")
                      : Stack(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                                child: Text(
                                  "Connect to your machine's Wi-Fi",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _viewModel!.machineVisibleNetworks.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () => widget.onSelectNetwork(_viewModel!.machineVisibleNetworks[index]),
                                      child: ProvisioningListItem(
                                        textString: _viewModel!.machineVisibleNetworks[index].ssid,
                                        leading: Icon(
                                          _viewModel!.signalToIcon(_viewModel!.machineVisibleNetworks[index].signal),
                                          size: 24.0,
                                          color: Colors.grey,
                                        ),
                                        add: false,
                                        trailing: Icon(
                                          _viewModel!.securityToIcon(_viewModel!.machineVisibleNetworks[index].security),
                                          size: 20.0,
                                          color: Colors.grey,
                                        ),
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
                        ]),
            ),
          ],
        );
      },
    );
  }
}
