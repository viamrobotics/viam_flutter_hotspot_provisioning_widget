part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class ManualEntryButton extends StatelessWidget {
  const ManualEntryButton({
    super.key,
    required this.onManualEntry,
  });

  final VoidCallback onManualEntry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            elevation: 0,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => TroubleshootingDialog(onManualEntry: onManualEntry),
            );
          },
          child: Text("My network isn't showing up"),
        ),
      ),
    );
  }
}
