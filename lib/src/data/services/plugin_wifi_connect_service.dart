part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class PluginWifiConnectService {
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
}
