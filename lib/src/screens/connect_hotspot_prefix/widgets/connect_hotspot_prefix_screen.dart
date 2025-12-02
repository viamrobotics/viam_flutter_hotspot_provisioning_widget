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
  TextStyle get listStyle => TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16.0,
      );

  @override
  void initState() {
    super.initState();
    widget.viewModel.resetConnectionState();
    if (Platform.isAndroid) {
      _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    final hasPermission = await widget.viewModel.getLocationPermission();
    if (!hasPermission) {
      await showLocationPermissionDialog();
    }
  }

  Future<void> showLocationPermissionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Precise Location Permission Required'),
          content: const Text(
            'Please enable precise location permissions in your device settings to continue.\n\nWi-Fi information is considered location information on Android.',
          ),
          actions: <Widget>[
            OutlinedButton(
              child: const Text('Continue'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void showCredentialErrorDialog() {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Missing Credentials'),
        content: const Text(
          'Hotspot credentials are required but were not provided. '
          'Please ensure hotspotPrefix and hotspotPassword are set when calling this flow with promptForCredentials set to false.',
        ),
        actions: [
          PlatformDialogAction(
            onPressed: Navigator.of(context).pop,
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> showConnectionErrorDialog() {
    return showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Connection Failed'),
        content: const Text('Failed to connect to the device hotspot. Please try again.'),
        actions: [
          PlatformDialogAction(
            onPressed: Navigator.of(context).pop,
            child: const Text('OK'),
          )
        ],
      ),
    );
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
          onPressed: () {
            widget.viewModel.resetConnectionState();
            widget.onBack();
          },
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            // Show error dialog if connection failed
            if (widget.viewModel.failedToConnectToHotspot) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.viewModel.setFailedToConnectToHotspot(false);
                showConnectionErrorDialog();
              });
            }

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
                            : () {
                                if (widget.viewModel.hotspotPrefix.isEmpty || widget.viewModel.hotspotPassword.isEmpty) {
                                  showCredentialErrorDialog();
                                } else {
                                  widget.viewModel.connectToHotspot();
                                }
                              },
                        text: "Connect to Device Hotspot",
                        isLoading: widget.viewModel.isAttemptingConnectionToHotspot || widget.viewModel.pollingForMachine,
                      ),
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
