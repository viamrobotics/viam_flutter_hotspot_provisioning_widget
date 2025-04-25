part of '../../viam_flutter_provisioning_widget.dart';

class SetupTetheringScreen extends StatelessWidget {
  const SetupTetheringScreen({super.key, required this.connectedPeripheral});

  final BluetoothDevice connectedPeripheral;

  void _onSetupBluetoothPressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _onNextPressed(BuildContext context) {
    // final viewModel = context.read<VesselSetupViewModel>();
    // Navigator.of(context).push(MaterialPageRoute(
    //   builder: (context) => ChangeNotifierProvider.value(
    //     value: viewModel,
    //     child: ConnectedBluetoothDeviceScreen(connectedPeripheral: connectedPeripheral),
    //   ),
    // ));
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
                  'Set up your Wi-Fi hotspot',
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Platform.isIOS ? _buildIOSHotspotSteps(context) : _buildAndroidHotspotSteps(context),
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
                  onPressed: () => _onSetupBluetoothPressed(context),
                  child: Text(
                    'Use Bluetooth instead',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () => _onNextPressed(context),
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

  Widget _buildIOSHotspotSteps(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTile(
          stepNumber: '1',
          onTap: null, // TOD: AppSettings.openAppSettings, in utils
          children: [
            const TextSpan(text: "Go to your phone's "),
            TextSpan(text: "hotspot settings", style: textTheme!.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: " (Settings > Personal Hotspot) and look for this section:"),
          ],
        ),
        GestureDetector(
          onTap: null, // TOD: AppSettings.openAppSettings, in utils
          behavior: HitTestBehavior.opaque,
          child: Image.asset('images/ios_wifi_hotspot.png'),
        ),
        const SizedBox(height: 8),
        StepTile(
          stepNumber: '2',
          onTap: null,
          children: [
            const TextSpan(text: 'Make sure "'),
            TextSpan(text: 'Allow Others to Join"', style: textTheme.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: " is enabled"),
          ],
        ),
        const SizedBox(height: 8),
        StepTile(
          stepNumber: '3',
          onTap: null,
          children: [
            const TextSpan(text: 'Note the '),
            TextSpan(text: 'Wi-Fi Password', style: textTheme.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: " shown on this screen and write it down if necessary. You'll need it to connect your device."),
          ],
        ),
      ],
    );
  }

  Widget _buildAndroidHotspotSteps(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTile(
          stepNumber: '1',
          onTap: null, // TOD: AppSettings.openAppSettings, in utils
          children: [
            const TextSpan(text: "In your phone's settings, go to "),
            TextSpan(text: "Network & internet", style: textTheme!.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: ", then "),
            TextSpan(text: "Hotspot & tethering", style: textTheme.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        StepTile(
          stepNumber: '2',
          onTap: null,
          children: [
            const TextSpan(text: 'Make sure '),
            TextSpan(text: 'Wi-Fi hotspot', style: textTheme.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: " is enabled"),
          ],
        ),
        const SizedBox(height: 8),
        StepTile(
          stepNumber: '3',
          onTap: null,
          children: [
            const TextSpan(text: 'Tap on "Wi-Fi hotspot" and note the '),
            TextSpan(text: 'Hotspot name', style: textTheme.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: " and "),
            TextSpan(text: 'Hotspot password.', style: textTheme.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: " Write them down if necessary—you'll need them to connect your device."),
          ],
        ),
        GestureDetector(
          onTap: null, // TOD: AppSettings.openAppSettings, in utils
          behavior: HitTestBehavior.opaque,
          child: Image.asset('images/android_wifi_hotspot.png'),
        ),
      ],
    );
  }
}
