part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class ConnectionSuccessBanner extends StatelessWidget {
  const ConnectionSuccessBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, bottom: 20.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              "You are connected to the device's hotspot.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
