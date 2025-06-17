part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class ConfirmationViewModel extends ChangeNotifier {
  ConfirmationViewModel({
    required Viam viam,
    required Robot robot,
  })  : _viam = viam,
        _robot = robot {
    _disconnectFromHotspot();
    _startCheckingOnline();
  }

  final Viam _viam;
  final Robot _robot;

  Timer? _timer;
  RobotStatus _robotStatus = RobotStatus.loading;
  int _secondsLoading = 0;

  static const int provisioningTimeoutSeconds = 90;
  static const int provisioningStillWaitingSeconds = 45;

  // Getters
  RobotStatus get robotStatus => _robotStatus;
  int get secondsLoading => _secondsLoading;

  // Setters that notify listeners
  void _setRobotStatus(RobotStatus value) {
    if (_robotStatus != value) {
      _robotStatus = value;
      notifyListeners();
    }
  }

  void _setSecondsLoading(int value) {
    if (_secondsLoading != value) {
      _secondsLoading = value;
      notifyListeners();
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
