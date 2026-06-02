part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class HotspotProvisioningRepository {
  final Viam viam;
  final PluginWifiConnectService pluginWifiConnectService;
  final PermissionService permissionService;

  HotspotProvisioningRepository({
    required this.viam,
    required this.pluginWifiConnectService,
    required this.permissionService,
  });

  Future<GetSmartMachineStatusResponse> getSmartMachineStatus() async {
    return await viam.provisioningClient.getSmartMachineStatus();
  }

  // Returns true if the device's provisioning service responds, regardless of the connected SSID
  Future<bool> isDeviceReachable() async {
    try {
      await getSmartMachineStatus();
      return true;
    } catch (e) {
      debugPrint('Device not reachable on current network: $e');
      return false;
    }
  }

  Future<void> setSmartMachineCredentials({
    required String id,
    required String secret,
  }) async {
    await viam.provisioningClient.setSmartMachineCredentials(
      id: id,
      secret: secret,
    );
  }

  // For versions of viam-agent less than 0.20.0
  Future<void> setNetworkCredentialsOnOldAgent({
    required NetworkType type,
    required String ssid,
    required String psk,
  }) {
    return viam.provisioningClient.setNetworkCredentials(
      type: type,
      ssid: ssid,
      psk: psk,
    );
  }

  Future<void> setNetworkCredentials({
    required NetworkType type,
    required String ssid,
    required String psk,
  }) async {
    await viam.provisioningClient.setNetworkCredentials(
      type: type,
      ssid: ssid,
      psk: psk,
    );
  }

  Future<void> exitProvisioning() async {
    await viam.provisioningClient.exitProvisioning();
  }

  Future<List<NetworkInfo>> getNetworkList() async {
    final networks = await viam.provisioningClient.getNetworkList();
    return networks.toList();
  }

  Future<String?> getCurrentSSID() async {
    return await pluginWifiConnectService.getCurrentSSID();
  }

  Future<bool> connectToSecureNetworkByPrefix({
    required String prefix,
    required String password,
    required bool isWep,
    required bool isWpa3,
    required bool saveNetwork,
  }) async {
    return await pluginWifiConnectService.connectToSecureNetworkByPrefix(
      prefix: prefix,
      password: password,
      isWep: isWep,
      isWpa3: isWpa3,
      saveNetwork: saveNetwork,
    );
  }

  Future<bool> disconnect() async {
    return await pluginWifiConnectService.disconnect();
  }

  Future<ph.PermissionStatus> requestLocationPermission() async {
    return await permissionService.requestLocationPermission();
  }

  // Android considers Wi-Fi information to be location information
  // If we don't have location permission any connected ssid will show as 'unknown ssid'
  Future<bool> getLocationPermission() async {
    return await permissionService.getLocationPermission();
  }

  Future<void> updateRobotPart({
    required String partId,
    required String robotName,
    required Map<String, dynamic> config,
  }) async {
    await viam.appClient.updateRobotPart(partId, robotName, config);
  }

  Future<Robot> getRobot(String robotId) async {
    return await viam.appClient.getRobot(robotId);
  }

  Future<MachineStatus> calculateMachineStatus(Robot robot) async {
    final seconds = robot.lastAccess.seconds.toInt();
    final actual = DateTime.now().microsecondsSinceEpoch / Duration.microsecondsPerSecond;
    if ((actual - seconds) < 10) {
      return MachineStatus.online;
    }
    return MachineStatus.loading;
  }
}
