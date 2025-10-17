part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class HotspotProvisioningRepository {
  final Viam viam;

  HotspotProvisioningRepository({required this.viam});

  Future<GetSmartMachineStatusResponse> getSmartMachineStatus() async {
    return await viam.provisioningClient.getSmartMachineStatus();
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
    return await PluginWifiConnect.ssid;
  }

  Future<bool> connectToSecureNetworkByPrefix({
    required String prefix,
    required String password,
    required bool isWep,
    required bool isWpa3,
    required bool saveNetwork,
  }) async {
    final result = await PluginWifiConnect.connectToSecureNetworkByPrefix(
      prefix,
      password,
      isWep: isWep,
      isWpa3: isWpa3,
      saveNetwork: saveNetwork,
    );
    return result ?? false;
  }

  Future<bool> disconnect() async {
    final result = await PluginWifiConnect.disconnect();
    return result ?? false;
  }

  Future<ph.PermissionStatus> requestLocationPermission() async {
    return await ph.Permission.location.request();
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
