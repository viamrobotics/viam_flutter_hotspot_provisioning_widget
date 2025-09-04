part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

// Currently, we are assuming that we are always provisioning a new machine.

class ConnectHotspotPrefixScreen extends StatefulWidget {
  final Robot robot;
  final Viam viam;
  final RobotPart mainPart;
  final VoidCallback onNavigateToNetworkSelection;
  final String hotspotPrefix;
  final String hotspotPassword;

  const ConnectHotspotPrefixScreen({
    super.key,
    required this.robot,
    required this.viam,
    required this.mainPart,
    required this.onNavigateToNetworkSelection,
    required this.hotspotPrefix,
    required this.hotspotPassword,
  });

  @override
  State<ConnectHotspotPrefixScreen> createState() => _ConnectHotspotPrefixScreenState();
}

class _ConnectHotspotPrefixScreenState extends State<ConnectHotspotPrefixScreen> {
  late final ConnectHotspotPrefixViewModel _viewModel;
  TextStyle get listStyle => TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16.0,
      );

  @override
  void initState() {
    super.initState();
    _viewModel = ConnectHotspotPrefixViewModel(
      viam: widget.viam,
      context: context,
      hotspotPrefix: widget.hotspotPrefix,
      hotspotPassword: widget.hotspotPassword,
      onNavigateToNetworkSelection: widget.onNavigateToNetworkSelection,
    );
    if (Platform.isAndroid) {
      _viewModel.getLocationPermission();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
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
                    if (_viewModel.connectedToHotspot)
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
                    if (_viewModel.wrongPassword)
                      Padding(
                        padding: const EdgeInsets.only(left: 14.0, bottom: 20.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    "Having trouble connecting? The password may be incorrect. Please check it or try again.",
                                    style: listStyle.copyWith(fontSize: 15.0),
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
                    onPressed: _viewModel.isAttemptingConnectionToHotspot || _viewModel.pollingForMachine
                        ? null
                        : () => _viewModel.connectToHotspot(),
                    text: _viewModel.isRetryingHotspot ? "Retry Connect to Device Hotspot" : "Connect to Device Hotspot",
                    isLoading: _viewModel.isAttemptingConnectionToHotspot || _viewModel.pollingForMachine,
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
