part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

enum RobotStatus { online, offline, loading }

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key, required this.robot, required this.viam, required this.mainPart, required this.onStatusDetermined});

  final Viam viam;
  final Robot robot;
  final RobotPart mainPart;
  final void Function(Robot robot, RobotStatus status) onStatusDetermined;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  late final ConfirmationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ConfirmationViewModel(
      viam: widget.viam,
      robot: widget.robot,
      onStatusDetermined: widget.onStatusDetermined,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

// Note: The only UI we need to show is the loading screen. Once the robot is online or offline, the callback will be triggered, and the parent (HotspotProvisioningFlow) will pop this screen. THis way the user can decide what to do when the robot is online or offline.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.robotStatus == RobotStatus.loading && _viewModel.secondsLoading < ConfirmationViewModel.provisioningTimeoutSeconds) {
          return RobotLoadingWidget(
            secondsLoading: _viewModel.secondsLoading,
            provisioningStillWaitingSeconds: ConfirmationViewModel.provisioningStillWaitingSeconds,
          );
        }
        // If status is online/offline/timed out, the callback should have already fired.
        // We can return an empty SizedBox or a very minimal placeholder here,
        // as this screen is about to be popped.
        return const SizedBox.shrink();
      },
    );
  }
}
