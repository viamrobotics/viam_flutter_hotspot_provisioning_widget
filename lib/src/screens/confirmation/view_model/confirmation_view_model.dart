part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class ConfirmationViewModel {
  ConfirmationViewModel({
    required HotspotProvisioningRepository repository,
    required Robot robot,
    required RobotPart mainPart,
    required String? fragmentId,
    required bool overrideFragment,
    required bool replaceHardware,
    Map<String, dynamic>? robotConfig,
  })  : _repository = repository,
        _robot = robot,
        _mainPart = mainPart,
        _fragmentId = fragmentId,
        _overrideFragment = overrideFragment,
        _replaceHardware = replaceHardware,
        _robotConfig = robotConfig;

  final HotspotProvisioningRepository _repository;
  final Robot _robot;
  final RobotPart _mainPart;
  final String? _fragmentId;
  final bool _overrideFragment;
  final bool _replaceHardware;
  final Map<String, dynamic>? _robotConfig;

  final StreamController<MachineStatus> _machineStatusController = StreamController<MachineStatus>.broadcast();
  Stream<MachineStatus> get machineStatusStream => _machineStatusController.stream;

  Timer? _timer;
  int _secondsLoading = 0;
  int get secondsLoading => _secondsLoading;

  // Getters for screen access
  Robot get robot => _robot;
  bool get overrideFragment => _overrideFragment;
  bool get replaceHardware => _replaceHardware;

  static const int _provisioningTimeoutSeconds = 120;

  // Updates the machine status stream with the current machine status until the machine is online or we timeout
  void startCheckingOnline() async {
    _addMachineStatus(MachineStatus.loading);

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      _secondsLoading += 5;

      if (_secondsLoading >= _provisioningTimeoutSeconds) {
        _addMachineStatus(MachineStatus.offline);
        _closeMachineStatusStream();
        return;
      }

      try {
        final refreshedRobot = await _repository.getRobot(_robot.id);
        final newMachineStatus = await _repository.calculateMachineStatus(refreshedRobot);
        _addMachineStatus(newMachineStatus);

        if (newMachineStatus == MachineStatus.online) {
          debugPrint('Machine status is online');
          _closeMachineStatusStream();
          return;
        }
      } catch (e) {
        debugPrint('Error getting robot status ${e.toString()}');
        _addMachineStatus(MachineStatus.loading);
      }
    });
  }

  Future<bool> disconnectFromHotspot() async {
    await Future.delayed(const Duration(seconds: 5));
    return await _repository.disconnect();
  }

// Override the currentfragment on the robot with the new fragment
  Future<void> performFragmentOverride() async {
    if (_fragmentId == null || _fragmentId.isEmpty) return;
    Map<String, dynamic> config = {
      "fragments": [_fragmentId]
    };
    await _repository.updateRobotPart(
      partId: _mainPart.id,
      robotName: _robot.name,
      config: config,
    );
  }

  // Update the new robot's config with the saved config from the old robot
  Future<void> applyRobotConfig() async {
    if (_robotConfig == null) return;
    try {
      await _repository.updateRobotPart(
        partId: _mainPart.id,
        robotName: _mainPart.name,
        config: _robotConfig,
      );
    } catch (e) {
      debugPrint('Error applying robotConfig: ${e.toString()}');
    }
  }

  void dispose() {
    _closeMachineStatusStream();
  }

  void _addMachineStatus(MachineStatus machineStatus) {
    debugPrint('Machine status is: $machineStatus');
    _machineStatusController.add(machineStatus);
  }

  void _closeMachineStatusStream() {
    _timer?.cancel();
    _machineStatusController.close();
  }
}
