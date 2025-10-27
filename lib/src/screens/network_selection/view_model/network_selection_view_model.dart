part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class NetworkSelectionViewModel extends ChangeNotifier {
  NetworkSelectionViewModel({
    required this.repository,
  });

  final HotspotProvisioningRepository repository;

  bool _loadingNetworks = false;
  List<NetworkInfo> _machineVisibleNetworks = [];

  bool get loadingNetworks => _loadingNetworks;
  List<NetworkInfo> get machineVisibleNetworks => _machineVisibleNetworks;

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
    setLoadingNetworks(true);

    try {
      if (refresh) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      final networks = await repository.getNetworkList();
      final sortedNetworks = networks.toList()..sort((b, a) => a.signal.compareTo(b.signal));
      setMachineVisibleNetworks(sortedNetworks);
    } catch (e) {
      debugPrint('getNetworkList error: ${e.toString()}');
    }

    setLoadingNetworks(false);
  }

  void setLoadingNetworks(bool value) {
    _loadingNetworks = value;
    notifyListeners();
  }

  void setMachineVisibleNetworks(List<NetworkInfo> networks) {
    _machineVisibleNetworks = networks;
    notifyListeners();
  }
}
