part of '../../../../viam_flutter_hotspot_provisioning_widget.dart';

class TroubleshootingDialog extends StatelessWidget {
  final VoidCallback onManualEntry;

  const TroubleshootingDialog({
    super.key,
    required this.onManualEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Troubleshooting",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "If your boat's Wi-Fi network isn't showing up in this list, turn your Specter AI device off and back on again.\n\n"
              "If you've tried this and it still isn't appearing, you can connect by manually entering your network info.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onManualEntry();
                },
                text: "Manually enter network info",
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                text: "Close",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
