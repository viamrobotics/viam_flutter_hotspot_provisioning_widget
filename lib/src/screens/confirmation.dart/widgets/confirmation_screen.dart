part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

enum RobotStatus { online, offline, loading }

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen(
      {super.key, required this.robot, required this.viam, required this.mainPart, this.onlineBuilder, this.offlineBuilder});

  final Viam viam;
  final Robot robot;
  final RobotPart mainPart;
  final Widget Function(BuildContext context)? onlineBuilder;
  final Widget Function(BuildContext context)? offlineBuilder;

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
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.robotStatus == RobotStatus.online) {
          return widget.onlineBuilder != null
              ? widget.onlineBuilder!(context)
              : Expanded(
                  child: RobotOnlineWidget(
                  robot: widget.robot,
                ));
        } else if (_viewModel.robotStatus == RobotStatus.offline) {
          return widget.offlineBuilder != null ? widget.offlineBuilder!(context) : const Expanded(child: RobotOfflineWidget());
        } else if (_viewModel.secondsLoading >= ConfirmationViewModel.provisioningTimeoutSeconds) {
          return widget.offlineBuilder != null ? widget.offlineBuilder!(context) : const Expanded(child: RobotOfflineWidget());
        } else {
          return Expanded(
            child: RobotLoadingWidget(
              secondsLoading: _viewModel.secondsLoading,
              provisioningStillWaitingSeconds: ConfirmationViewModel.provisioningStillWaitingSeconds,
            ),
          );
        }
      },
    );
  }
}
