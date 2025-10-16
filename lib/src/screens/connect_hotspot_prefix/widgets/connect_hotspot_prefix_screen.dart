part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class ConnectHotspotPrefixScreen extends StatefulWidget {
  final ConnectHotspotPrefixViewModel viewModel;
  final VoidCallback onBack;

  const ConnectHotspotPrefixScreen({
    super.key,
    required this.viewModel,
    required this.onBack,
  });

  @override
  State<ConnectHotspotPrefixScreen> createState() => _ConnectHotspotPrefixScreenState();
}

class _ConnectHotspotPrefixScreenState extends State<ConnectHotspotPrefixScreen> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      widget.viewModel.getLocationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Connect to Device Hotspot",
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
          builder: (context, _) {
            return Column(
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
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const InstructionItem(text: "1. Turn on the device you are trying to connect to."),
                        const InstructionItem(text: "2. Make sure you are nearby the device."),
                        const InstructionItem(text: "3. Press the button below to connect to the device's hotspot."),
                        if (widget.viewModel.connectedToHotspot) const ConnectionSuccessBanner(),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConnectButtonSection(
                      isLoading: widget.viewModel.isAttemptingConnectionToHotspot || widget.viewModel.pollingForMachine,
                      isRetrying: widget.viewModel.isRetryingHotspot,
                      onPressed: () => widget.viewModel.connectToHotspot(),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
