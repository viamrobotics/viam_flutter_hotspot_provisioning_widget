part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class NetworkSelectionViewModel extends ChangeNotifier {
  NetworkSelectionViewModel({
    required Viam viam,
  }) : _viam = viam;

  final Viam _viam;

  bool _loadingNetworks = false;
  List<NetworkInfo> _machineVisibleNetworks = [];

  bool get loadingNetworks => _loadingNetworks;
  List<NetworkInfo> get machineVisibleNetworks => _machineVisibleNetworks;

  void _setLoadingNetworks(bool value) {
    _loadingNetworks = value;
    notifyListeners();
  }

  void _setMachineVisibleNetworks(List<NetworkInfo> networks) {
    _machineVisibleNetworks = networks;
    notifyListeners();
  }

  IconData signalToIcon(int signal) {
    if (signal <= 40) return Icons.wifi_1_bar;
    if (40 <= signal && signal <= 70) return Icons.wifi_2_bar;
    return Icons.wifi;
  }

  IconData securityToIcon(String? security) {
    if (security == '-') {
      return Icons.lock_open;
    }
    return Icons.lock;
  }

  Future<void> getNetworks({bool refresh = false}) async {
    _setLoadingNetworks(true);

    try {
      if (refresh) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      final networks = await _viam.provisioningClient.getNetworkList();
      final sortedNetworks = networks.toList()..sort((b, a) => a.signal.compareTo(b.signal));
      _setMachineVisibleNetworks(sortedNetworks);
    } catch (e) {
      debugPrint('getNetworkList error: ${e.toString()}');
    }

    _setLoadingNetworks(false);
  }
}
