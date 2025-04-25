part of '../../viam_flutter_provisioning_widget.dart';

class SetupHotspotScreen extends StatelessWidget {
  const SetupHotspotScreen({
    super.key,
    required this.connectedPeripheral,
  });

  final BluetoothDevice connectedPeripheral;

  // static Route route(
  //   BluetoothDevice connectedPeripheral,
  //   VesselSetupViewModel viewModel,
  // ) {
  //   return MaterialPageRoute(
  //     builder: (context) => ChangeNotifierProvider.value(
  //       value: viewModel,
  //       child: SetupHotspotScreen(connectedPeripheral: connectedPeripheral),
  //     ),
  //   );
  // }

  void _onSetupWifiPressed(BuildContext context) {
    //   final viewModel = context.read<VesselSetupViewModel>();
    //   Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => ChangeNotifierProvider.value(
    //       value: viewModel,
    //       child: SetupTetheringScreen(connectedPeripheral: connectedPeripheral),
    //     ),
    //   ));
  }

  void _onContinuePressed(BuildContext context) {
    // final viewModel = context.read<VesselSetupViewModel>();

    // // Pop twice to remove both this screen and the previous screen
    // Navigator.of(context).pop();
    // Navigator.of(context).pop();

    // // Then push the new screen
    // Navigator.of(context).push(
    //   WifiQuestionScreen.route(
    //     connectedPeripheral: connectedPeripheral,
    //     viewModel: viewModel,
    //     startInConnectingState: true,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Set up Bluetooth hotspot',
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  "If your boat doesn't have Internet, you can use Bluetooth to share your phone's cellular connection with the VC Box.",
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.visible,
                ),
                Spacer(),
                Platform.isIOS ? _buildIOSHotspotInstructions(context) : _buildAndroidHotspotInstructions(context),
                Spacer(),
                Text(
                  "Once you've completed these steps, come back to this screen and tap ${"Continue."}",
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.visible,
                ),
                Spacer(),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  onPressed: () => _onSetupWifiPressed(context),
                  child: Text(
                    'Use Wi-Fi hotspot instead',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () => _onContinuePressed(context),
                  child: Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIOSHotspotInstructions(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTile(
          stepNumber: '1',
          onTap: null,
          children: [
            const TextSpan(text: "In your phone's settings, go to the "),
            TextSpan(text: "Personal Hotspot", style: textTheme!.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: " page (Settings > Personal Hotspot)"),
          ],
        ),
        const SizedBox(height: 16),
        StepTile(
          stepNumber: '2',
          onTap: null, // TODO: AppSettings.openAppSettings,
          children: [
            const TextSpan(text: 'Make sure "'),
            TextSpan(text: 'Allow Others to Join"', style: textTheme.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: " is enabled"),
          ],
        ),
        GestureDetector(
          onTap: null, // TODO: AppSettings.openAppSettings,
          behavior: HitTestBehavior.opaque,
          child: Image.asset('images/ios_bluetooth_hotspot.png'),
        ),
      ],
    );
  }

  Widget _buildAndroidHotspotInstructions(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTile(
          stepNumber: '1',
          onTap: null,
          children: [
            const TextSpan(text: "In your phone's settings, go to "),
            TextSpan(text: "Network & internet", style: textTheme!.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: ", then "),
            TextSpan(text: "Hotspot & tethering", style: textTheme.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        StepTile(
          stepNumber: '2',
          onTap: null, // TODO: AppSettings.openAppSettings,
          children: [
            const TextSpan(text: 'Make sure '),
            TextSpan(text: 'Bluetooth tethering', style: textTheme.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: " is enabled:"),
          ],
        ),
        GestureDetector(
          onTap: null, // TODO: AppSettings.openAppSettings,
          behavior: HitTestBehavior.opaque,
          child: Image.asset('images/android_bluetooth_hotspot.png'),
        ),
      ],
    );
  }
}
