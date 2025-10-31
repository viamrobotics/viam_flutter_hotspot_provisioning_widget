part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class NetworkList extends StatelessWidget {
  const NetworkList({
    super.key,
    required this.networks,
    required this.onSelectPublicNetwork,
    required this.onSelectPrivateNetwork,
    required this.signalToIcon,
    required this.securityToIcon,
  });

  final List<NetworkInfo> networks;
  final Future<void> Function(NetworkInfo) onSelectPublicNetwork;
  final void Function(NetworkInfo) onSelectPrivateNetwork;
  final IconData Function(int) signalToIcon;
  final IconData Function(String?) securityToIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: networks.length,
        itemBuilder: (context, index) {
          final network = networks[index];
          return GestureDetector(
            // onTap: () => onSelectNetwork(network),
            onTap: () async {
              if (network.security == '-') {
                await onSelectPublicNetwork(network);
              } else {
                onSelectPrivateNetwork(network);
              }
            },
            child: ProvisioningListItem(
              textString: network.ssid,
              leading: Icon(
                signalToIcon(network.signal),
                size: 24.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              add: false,
              trailing: Icon(
                securityToIcon(network.security),
                size: 20.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        },
      ),
    );
  }
}
