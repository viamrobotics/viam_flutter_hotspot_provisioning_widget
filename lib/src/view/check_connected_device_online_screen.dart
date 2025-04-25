part of '../../viam_flutter_provisioning_widget.dart';

class CheckConnectedDeviceOnlineScreen extends StatefulWidget {
  const CheckConnectedDeviceOnlineScreen({
    super.key,
    required this.robot,
    required this.connectedPeripheral,
  });

  final Robot robot;
  final BluetoothDevice connectedPeripheral;

  static MaterialPageRoute<void> route({
    required Robot robot,
    required BluetoothDevice connectedPeripheral,
  }) {
    return MaterialPageRoute(
      builder: (context) => CheckConnectedDeviceOnlineScreen(
        robot: robot,
        connectedPeripheral: connectedPeripheral,
      ),
    );
  }

  @override
  State<CheckConnectedDeviceOnlineScreen> createState() => _CheckConnectedDeviceOnlineScreenState();
}

enum _DeviceOnlineState {
  checking,
  agentConnected,
  success,
}

class _CheckConnectedDeviceOnlineScreenState extends State<CheckConnectedDeviceOnlineScreen> {
  Timer? _onlineTimer;
  _DeviceOnlineState _setupState = _DeviceOnlineState.checking;

  @override
  void initState() {
    super.initState();
    _initTimers();
    _markAsConnecting();
  }

  @override
  void dispose() {
    _onlineTimer?.cancel();
    super.dispose();
  }

  Future<void> _markAsConnecting() async {
    // TODO: !
    // final provisioningState = Provider.of<ProvisioningState>(context, listen: false);
    // provisioningState.provisionAttempts[widget.robot.id] = Timer(Duration(minutes: 5), () {});
  }

  void _initTimers() {
    _onlineTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkOnline();
      _checkAgentStatus();
    });
  }

  Future<void> _checkAgentStatus() async {
    try {
      final status = await widget.connectedPeripheral.readStatus();

      if (status.isConnected && status.isConfigured && _setupState != _DeviceOnlineState.success) {
        setState(() {
          _setupState = _DeviceOnlineState.agentConnected;
        });
      }
    } on Exception catch (e) {
      // TODO: determine what action to take here
      print(e);
    }
  }

  void _checkOnline() async {
    // TODO: gotta pass in appClient I think
    // final viam = await AuthService.authenticatedViam;
    // final refreshedRobot = await viam.appClient.getRobot(widget.robot.id);
    // final seconds = refreshedRobot.lastAccess.seconds.toInt();
    // final actual = DateTime.now().microsecondsSinceEpoch / Duration.microsecondsPerSecond;
    // if ((actual - seconds) < 10) {
    //   setState(() {
    //     _setupState = _DeviceOnlineState.success;
    //   });
    //   _onlineTimer?.cancel();
    // }
  }

  void _proceedOnSuccess() {
    // TODO: set selected robot with vm
    //context.push('/');
  }

  // Helper method for the 'checking' state
  Widget _buildCheckingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 32),
            Text(
              'Finishing up...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Please keep this screen open until setup is complete. This should take a minute or two.',
              maxLines: 3,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for the 'agentConnected' state
  Widget _buildAgentConnectedState(BuildContext context) {
    // Currently same as checking, can customize later if needed
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Connected!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '${widget.robot.name} is connected and almost ready to use. You can leave this screen now and it will automatically come online in a few minutes.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
            maxLines: 4,
          ),
          Spacer(),
          FilledButton(
            onPressed: _proceedOnSuccess,
            child: Text('Close'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  // Helper method for the 'success' state
  Widget _buildSuccessState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Spacer(),
          Icon(Icons.check_circle, color: Colors.green, size: 40),
          SizedBox(height: 24),
          Text('All set!', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          SizedBox(height: 8),
          Text(
            '${widget.robot.name} is connected and ready to use.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          Spacer(),
          FilledButton(
            onPressed: _proceedOnSuccess,
            child: Text('Close'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      appBar: AppBar(
        // TODO: TEMP HACK FOR TESTING
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: _proceedOnSuccess,
        ),
      ),
      body: SafeArea(
        child: switch (_setupState) {
          _DeviceOnlineState.checking => _buildCheckingState(context),
          _DeviceOnlineState.agentConnected => _buildAgentConnectedState(context),
          _DeviceOnlineState.success => _buildSuccessState(context),
        },
      ),
    );
  }
}
