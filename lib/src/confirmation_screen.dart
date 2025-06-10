part of '../../viam_flutter_hotspot_provisioning_widget.dart';

enum RobotStatus { online, offline, loading }

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen(
      {super.key, required this.robot, required this.viam, required this.mainPart, this.onlineBuilder, this.offlineBuilder});

  final Viam viam;
  final Robot robot;
  final RobotPart mainPart;
  final Widget Function(BuildContext context)? onlineBuilder;
  final Widget Function(BuildContext context)? offlineBuilder;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  Timer? _timer;
  RobotStatus _robotStatus = RobotStatus.loading;
  int _secondsLoading = 0;
  static const provisioningTimeoutSeconds = 90;
  static const provisioningStillWaitingSeconds = 45;

  @override
  void initState() {
    super.initState();
    _disconnectFromHotspot();
    _startCheckingOnline();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCheckingOnline() async {
    if (_timer != null && _timer!.isActive) return;

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _getRobotStatus();
      setState(() {
        _secondsLoading += 5;
      });
    });
  }

  Future<void> _disconnectFromHotspot() async {
    // TODO: want to await setting network credentials on previous screen, but fails/times out
    // so this is a hack workaround
    await Future.delayed(const Duration(seconds: 5));
    final disconnected = await PluginWifiConnect.disconnect();
    debugPrint('disconnected from hotspot: $disconnected');

    // TODO: associate hotspot sside w/ robot metadata as part of the machine already exists flow.
  }

  void _getRobotStatus() async {
    try {
      final reloadedRobot = await widget.viam.appClient.getRobot(widget.robot.id);
      final newRobotStatus = await calculateRobotStatus(reloadedRobot);
      debugPrint('Robot status: $newRobotStatus, name: ${reloadedRobot.name}');
      if (newRobotStatus == RobotStatus.online) {
        _timer?.cancel();
        // TODO: show a robot is online screen here?
      }
      if (mounted) {
        setState(() {
          _robotStatus = newRobotStatus;
        });
      }
    } catch (e) {
      // if an error, that means we still lack network connection
      debugPrint('Error getting robot status ${e.toString()}');
    }
  }

  Future<RobotStatus> calculateRobotStatus(Robot robot) async {
    final seconds = robot.lastAccess.seconds.toInt();
    final actual = DateTime.now().microsecondsSinceEpoch / Duration.microsecondsPerSecond;
    if ((actual - seconds) < 10) {
      return RobotStatus.online;
    }
    return RobotStatus.loading;
  }

  NoContentWidget showLoadingScreen() {
    if (_secondsLoading < provisioningTimeoutSeconds) {
      return NoContentWidget(
        titleString: _secondsLoading < provisioningStillWaitingSeconds ? "Setting up device..." : "Still trying...",
        bodyString: _secondsLoading < provisioningStillWaitingSeconds
            ? null
            : "Please keep this screen open. We'll keep trying to connect for a few more minutes.",
      );
    }
    return NoContentWidget(
      icon: Icon(Icons.highlight_off, color: Color(0xFFF86061)),
      titleString: "Connection failed",
      bodyString: "Unable to connect to your device's Wi-Fi network",
      button: PillButton(
        buttonString: "Try again",
        iconData: Icons.refresh,
        onPressed: () {
          Navigator.of(context).pop();
          // add a callback that allows the user to fill in what they want to do / where they want to go.
          // TODO: instead of popping, we should navigate to the reconnect flow when a user wants to try and reconnect after a failed provision attempt.
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_robotStatus == RobotStatus.online)
          widget.onlineBuilder != null
              ? widget.onlineBuilder!(context)
              : Expanded(
                  child: RobotOnlineWidget(
                  robot: widget.robot,
                )),
        if (_robotStatus == RobotStatus.offline)
          widget.offlineBuilder != null ? widget.offlineBuilder!(context) : const Expanded(child: RobotOfflineWidget()),
        if (_robotStatus == RobotStatus.loading)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Robot is loading'),
                  const SizedBox(height: 24),
                  showLoadingScreen(),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
