part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

// Currently, we are assuming that we are always provisioning a new machine.

class ConnectHotspotPrefixScreen extends StatefulWidget {
  final ConnectHotspotPrefixViewModel viewModel;

  const ConnectHotspotPrefixScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<ConnectHotspotPrefixScreen> createState() => _ConnectHotspotPrefixScreenState();
}

class _ConnectHotspotPrefixScreenState extends State<ConnectHotspotPrefixScreen> {
  TextStyle get listStyle => TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16.0,
      );

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      widget.viewModel.getLocationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
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
                    if (widget.viewModel.connectedToHotspot)
                      Padding(
                        padding: const EdgeInsets.only(left: 14.0, bottom: 20.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    "You are connected to the device's hotspot.",
                                    style: listStyle,
                                  ),
                                ),
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
                    onPressed: widget.viewModel.isAttemptingConnectionToHotspot || widget.viewModel.pollingForMachine
                        ? null
                        : () => widget.viewModel.connectToHotspot(),
                    text: widget.viewModel.isRetryingHotspot ? "Retry Connect to Device Hotspot" : "Connect to Device Hotspot",
                    isLoading: widget.viewModel.isAttemptingConnectionToHotspot || widget.viewModel.pollingForMachine,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
