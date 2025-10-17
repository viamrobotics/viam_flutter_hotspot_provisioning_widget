part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class NetworkSelectionScreen extends StatefulWidget {
  final void Function(NetworkInfo) onSelectNetwork;
  final VoidCallback onManualEntry;
  final NetworkSelectionViewModel viewModel;
  final VoidCallback onBack;

  const NetworkSelectionScreen({
    super.key,
    required this.onSelectNetwork,
    required this.onManualEntry,
    required this.viewModel,
    required this.onBack,
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
        widget.viewModel.getNetworks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Connect to your machine's Wi-Fi",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18.0, fontWeight: FontWeight.w500)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24, color: Theme.of(context).colorScheme.onSurface),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, child) {
            if (widget.viewModel.loadingNetworks) {
              return const NoContentWidget(
                titleString: "Scanning...",
                bodyString: "Looking for visible networks...",
              );
            }
            if (widget.viewModel.machineVisibleNetworks.isEmpty) {
              return NetworkEmptyState(
                onManualEntry: widget.onManualEntry,
                onRefresh: () => widget.viewModel.getNetworks(refresh: true),
                isLoading: widget.viewModel.loadingNetworks,
              );
            }
            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  Expanded(
                    child: NetworkList(
                      networks: widget.viewModel.machineVisibleNetworks,
                      onSelectNetwork: widget.onSelectNetwork,
                      signalToIcon: widget.viewModel.signalToIcon,
                      securityToIcon: widget.viewModel.securityToIcon,
                    ),
                  ),
                  ManualEntryButton(
                    onManualEntry: widget.onManualEntry,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
