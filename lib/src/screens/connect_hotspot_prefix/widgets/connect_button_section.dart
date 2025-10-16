part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class ConnectButtonSection extends StatelessWidget {
  final bool isLoading;
  final bool isRetrying;
  final VoidCallback onPressed;

  const ConnectButtonSection({
    super.key,
    required this.isLoading,
    required this.isRetrying,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14.0, bottom: 28.0),
      child: PrimaryButton(
        onPressed: isLoading ? null : onPressed,
        text: isRetrying ? "Retry Connect to Device Hotspot" : "Connect to Device Hotspot",
        isLoading: isLoading,
      ),
    );
  }
}
