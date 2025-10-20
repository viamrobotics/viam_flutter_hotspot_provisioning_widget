part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class NetworkEmptyState extends StatelessWidget {
  const NetworkEmptyState({
    super.key,
    required this.onManualEntry,
    required this.onRefresh,
    required this.isLoading,
  });

  final VoidCallback onManualEntry;
  final VoidCallback onRefresh;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return NoContentWidget(
      icon: Icon(Icons.error, color: Theme.of(context).colorScheme.error),
      buttons: [
        FilledButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => TroubleshootingDialog(onManualEntry: onManualEntry),
            );
          },
          child: Text(
            "My network isn't showing up",
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w500),
          ),
        ),
        FilledButton(
          onPressed: isLoading ? null : onRefresh,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh, color: Theme.of(context).colorScheme.onPrimary),
              SizedBox(width: 8),
              Text("Try again", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
      titleString: "No networks found",
      bodyString: "Is your device powered on and nearby? Try turning the device off and back on.",
    );
  }
}
