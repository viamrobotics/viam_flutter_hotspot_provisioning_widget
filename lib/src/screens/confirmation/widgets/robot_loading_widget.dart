part of '../../../../viam_flutter_hotspot_provisioning_widget.dart';

class RobotLoadingWidget extends StatelessWidget {
  final int secondsLoading;

  const RobotLoadingWidget({
    super.key,
    required this.secondsLoading,
  });

  static const int provisioningStillWaitingSeconds = 45;

  @override
  Widget build(BuildContext context) {
    return NoContentWidget(
      titleString: secondsLoading < provisioningStillWaitingSeconds ? "Setting up device..." : "Still trying...",
      bodyString: secondsLoading < provisioningStillWaitingSeconds
          ? null
          : "Please keep this screen open. We'll keep trying to connect for a few more minutes.",
    );
  }
}
