part of '../../../../viam_flutter_hotspot_provisioning_widget.dart';

class MissingRobotConfigDialog extends StatelessWidget {
  const MissingRobotConfigDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showAdaptiveDialog(
      context: context,
      builder: (context) => const MissingRobotConfigDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text('Missing Robot Configuration'),
      content: const Text(
        'Hardware replacement mode is enabled, but no robot configuration was provided. '
        'The new machine will come online with an empty configuration. '
        'To preserve the old machine\'s settings, provide the robot configuration from the old robot.',
      ),
      actions: [
        PlatformDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        )
      ],
    );
  }
}
