part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class ConfirmationViewModel extends ChangeNotifier {
  ConfirmationViewModel({
    required Viam viam,
    required Robot robot,
    required void Function(Robot robot, RobotStatus status) onStatusDetermined,
  })  : _viam = viam,
        _robot = robot,
        _onStatusDetermined = onStatusDetermined {
    _disconnectFromHotspot();
    _startCheckingOnline();
  }

  final Viam _viam;
  final Robot _robot;
  final void Function(Robot robot, RobotStatus status) _onStatusDetermined;

  Timer? _timer;
  RobotStatus _robotStatus = RobotStatus.loading;
  int _secondsLoading = 0;

  static const int provisioningTimeoutSeconds = 90;
  static const int provisioningStillWaitingSeconds = 45;

  RobotStatus get robotStatus => _robotStatus;
  int get secondsLoading => _secondsLoading;

  void _setRobotStatus(RobotStatus value) {
    if (_robotStatus != value) {
      _robotStatus = value;
      notifyListeners();
      _whenFinalRobotStatusIsDetermined();
    }
  }

  void _setSecondsLoading(int value) {
    if (_secondsLoading != value) {
      _secondsLoading = value;
      notifyListeners();
      // Check for timeout when seconds are updated
      _checkForTimeout();
    }
  }

// triggers a callback to the hotspot provisioning flow to to indicate if the robot is online or offline
  void _whenFinalRobotStatusIsDetermined() {
    // robot provisioned succesfully and is online
    if (_robotStatus == RobotStatus.online) {
      _onStatusDetermined.call(_robot, RobotStatus.online);
      _timer?.cancel();
      // robot provisioning did not complete successfully and is offline
    } else if (_robotStatus == RobotStatus.offline) {
      _onStatusDetermined.call(_robot, RobotStatus.offline);
      _timer?.cancel();
    }
  }

  void _checkForTimeout() {
    if (_robotStatus == RobotStatus.loading && _secondsLoading >= provisioningTimeoutSeconds) {
      debugPrint('robot provisioning timed out and is offline');
      _setRobotStatus(RobotStatus.offline);
    }
  }

  void _startCheckingOnline() async {
    if (_timer != null && _timer!.isActive) return;

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _getRobotStatus();
      _setSecondsLoading(_secondsLoading + 5);
    });
  }

  Future<void> _disconnectFromHotspot() async {
    await Future.delayed(const Duration(seconds: 5));
    final disconnected = await PluginWifiConnect.disconnect();
    debugPrint('disconnected from hotspot: $disconnected');
    // TODO (APP-8749): Associate a unique ID from machine with (maybe hotspot ssid) w/ robot as part of the machine already exists flow.
    // This is so we can associate the machine with the correct robot when we reconnect.
  }

  void _getRobotStatus() async {
    try {
      final reloadedRobot = await _viam.appClient.getRobot(_robot.id);
      final newRobotStatus = await calculateRobotStatus(reloadedRobot);
      debugPrint('Robot status: $newRobotStatus, name: ${reloadedRobot.name}');
      if (newRobotStatus == RobotStatus.online) {
        _timer?.cancel();
      }
      _setRobotStatus(newRobotStatus);
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
