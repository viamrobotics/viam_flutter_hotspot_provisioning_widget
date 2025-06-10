part of '../../viam_flutter_hotspot_provisioning_widget.dart';

class NetworkSelectionViewModel extends ChangeNotifier {
  final Viam _viam;

  NetworkSelectionViewModel(this._viam);

  bool _loadingNetworks = false;
  bool get loadingNetworks => _loadingNetworks;

  List<NetworkInfo> _machineVisibleNetworks = [];
  List<NetworkInfo> get machineVisibleNetworks => _machineVisibleNetworks;

  Future<void> getNetworks({bool refresh = false}) async {
    _loadingNetworks = true;
    notifyListeners();

    try {
      if (refresh) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      final networks = await _viam.provisioningClient.getNetworkList();
      final sortedNetworks = networks.toList()..sort((b, a) => a.signal.compareTo(b.signal));
      _machineVisibleNetworks = sortedNetworks;
    } catch (e) {
      debugPrint('getNetworkList error: ${e.toString()}');
    }
    _loadingNetworks = false;
    notifyListeners();
  }
}
