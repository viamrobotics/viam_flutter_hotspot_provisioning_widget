part of '../../viam_flutter_provisioning_widget.dart';

class InternetSuccessScreen extends StatefulWidget {
  const InternetSuccessScreen({
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
  //       child: InternetSuccessScreen(connectedPeripheral: connectedPeripheral),
  //     ),
  //   );
  // }

  @override
  State<InternetSuccessScreen> createState() => _InternetSuccessScreenState();
}

class _InternetSuccessScreenState extends State<InternetSuccessScreen> {
  bool _isLoading = false;

  Future<void> _onNextPressed(BuildContext context) async {
    // if (_isLoading) return;
    // final viewModel = context.read<VesselSetupViewModel>();
    // final bool isReprovisioning = viewModel.robotToProvision != null;
    // // Re-provisioning a an existing robot
    // if (isReprovisioning) {
    //   _handleReprovisioning(context, viewModel);
    // } else {
    //   // Provisioning a new robot
    //   Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => ChangeNotifierProvider.value(
    //       value: viewModel,
    //       child: NameConnectedDeviceScreen(
    //         ssid: null,
    //         passkey: null,
    //         connectedPeripheral: widget.connectedPeripheral,
    //       ),
    //     ),
    //   ));
    // }
  }

  Future<void> _handleReprovisioning(BuildContext context) async {
    // setState(() {
    //   _isLoading = true;
    // });
    // try {
    //   debugPrint("reprovisioning, writing config (BT path)");
    //   await viewModel.writeConfigForExistingRobot(
    //     peripheral: widget.connectedPeripheral,
    //     ssid: null,
    //     passkey: null,
    //   );
    //   if (context.mounted) {
    //     Navigator.of(context).push(CheckConnectedDeviceOnlineScreen.route(
    //       robot: viewModel.robotToProvision!,
    //       connectedPeripheral: widget.connectedPeripheral,
    //     ));
    //   }
    // } catch (e, s) {
    //   debugPrint("Error during config write $e\n$s");
    // } finally {
    //   if (mounted) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.check_circle, size: 48),
              const SizedBox(height: 24),
              Text(
                'Success!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Your VC Box is connected to the Internet',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              const Spacer(), // Add extra spacer to push button lower
              FilledButton(
                onPressed: () => _onNextPressed(context),
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
