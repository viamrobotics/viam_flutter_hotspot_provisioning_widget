part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

enum MachineStatus { online, offline, loading }

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({
    super.key,
    required this.viewModel,
    required this.onStatusDetermined,
  });

  final ConfirmationViewModel viewModel;
  final void Function(Robot robot, MachineStatus status) onStatusDetermined;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.disconnectFromHotspot();
    widget.viewModel.startCheckingOnline();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: StreamBuilder<MachineStatus>(
            stream: widget.viewModel.machineStatusStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return RobotLoadingWidget(secondsLoading: widget.viewModel.secondsLoading);
              }
              final status = snapshot.data!;
              switch (status) {
                case MachineStatus.loading:
                  return RobotLoadingWidget(secondsLoading: widget.viewModel.secondsLoading);
                case MachineStatus.online:
                  if (widget.viewModel.overrideFragment) {
                    widget.viewModel.performFragmentOverride();
                  }
                  if (widget.viewModel.replaceHardware) {
                    widget.viewModel.applyRobotConfig();
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onStatusDetermined(widget.viewModel.robot, status);
                  });
                  break;
                case MachineStatus.offline:
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onStatusDetermined(widget.viewModel.robot, status);
                  });
                  break;
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
