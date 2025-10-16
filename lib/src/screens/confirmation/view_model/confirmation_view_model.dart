part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class ConfirmationViewModel extends ChangeNotifier {
  ConfirmationViewModel({
    required Viam viam,
    required Robot robot,
    required void Function(Robot robot, MachineStatus status) onStatusDetermined,
    required String? fragmentId,
    required RobotPart mainPart,
    required bool overrideFragment,
    required bool replaceHardware,
    Map<String, dynamic>? robotConfig,
  })  : _viam = viam,
        _robot = robot,
        _fragmentId = fragmentId,
        _mainPart = mainPart,
        _onStatusDetermined = onStatusDetermined,
        _overrideFragment = overrideFragment,
        _replaceHardware = replaceHardware,
        _robotConfig = robotConfig {
    _disconnectFromHotspot();
    _startCheckingOnline();
  }

  final Viam _viam;
  final Robot _robot;
  final String? _fragmentId;
  final RobotPart _mainPart;
  final void Function(Robot robot, MachineStatus status) _onStatusDetermined;
  final bool _overrideFragment;
  final bool _replaceHardware;
  final Map<String, dynamic>? _robotConfig;

  Timer? _timer;
  MachineStatus _machineStatus = MachineStatus.loading;
  int _secondsLoading = 0;

  static const int provisioningTimeoutSeconds = 120;
  static const int provisioningStillWaitingSeconds = 45;

  MachineStatus get machineStatus => _machineStatus;
  int get secondsLoading => _secondsLoading;

  void _setMachineStatus(MachineStatus value) {
    if (_machineStatus != value) {
      _machineStatus = value;
      notifyListeners();
      _whenFinalMachineStatusIsDetermined();
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
// Also, at this point we know we are online so we can call the fragment override.
  void _whenFinalMachineStatusIsDetermined() {
    // robot provisioned succesfully and is online
    if (_machineStatus == MachineStatus.online) {
      _onStatusDetermined.call(_robot, MachineStatus.online);
      _timer?.cancel();
      if (_overrideFragment) {
        _performFragmentOverride(_viam, _fragmentId, _mainPart, _robot);
      }
      if (_replaceHardware && _robotConfig != null) {
        _applyRobotConfig(_viam, _mainPart, _robotConfig);
      }
      // robot provisioning did not complete successfully and is offline
    } else if (_machineStatus == MachineStatus.offline) {
      _onStatusDetermined.call(_robot, MachineStatus.offline);
      _timer?.cancel();
    }
  }

  void _checkForTimeout() {
    if (_machineStatus == MachineStatus.loading && _secondsLoading >= provisioningTimeoutSeconds) {
      debugPrint('robot provisioning timed out and is offline');
      _setMachineStatus(MachineStatus.offline);
    }
  }

  void _startCheckingOnline() async {
    if (_timer != null && _timer!.isActive) return;

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _getMachineStatus();
      _setSecondsLoading(_secondsLoading + 5);
    });
  }

  Future<void> _disconnectFromHotspot() async {
    await Future.delayed(const Duration(seconds: 5));
    final disconnected = await PluginWifiConnect.disconnect();
    debugPrint('disconnected from hotspot: $disconnected');
  }

  Future<void> _performFragmentOverride(Viam viam, String? fragmentId, RobotPart robotPart, Robot robot) async {
    if (fragmentId == null || fragmentId.isEmpty) return;
    Map<String, dynamic> config = {
      "fragments": [fragmentId]
    };
    await viam.appClient.updateRobotPart(robotPart.id, robot.name, config);
  }

  // Update the new robot's config with the saved config from the old robot
  Future<void> _applyRobotConfig(Viam viam, RobotPart mainPart, Map<String, dynamic> savedRobotConfig) async {
    try {
      await viam.appClient.updateRobotPart(mainPart.id, mainPart.name, savedRobotConfig);
    } catch (e) {
      debugPrint('Error applying robotConfig: ${e.toString()}');
    }
  }

  void _getMachineStatus() async {
    try {
      final reloadedRobot = await _viam.appClient.getRobot(_robot.id);
      final newMachineStatus = await calculateMachineStatus(reloadedRobot);
      debugPrint('Robot status: $newMachineStatus, name: ${reloadedRobot.name}');
      if (newMachineStatus == MachineStatus.online) {
        _timer?.cancel();
      }
      _setMachineStatus(newMachineStatus);
    } catch (e) {
      // if an error, that means we still lack network connection
      debugPrint('Error getting robot status ${e.toString()}');
    }
  }

  Future<MachineStatus> calculateMachineStatus(Robot robot) async {
    final seconds = robot.lastAccess.seconds.toInt();
    final actual = DateTime.now().microsecondsSinceEpoch / Duration.microsecondsPerSecond;
    if ((actual - seconds) < 10) {
      return MachineStatus.online;
    }
    return MachineStatus.loading;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
