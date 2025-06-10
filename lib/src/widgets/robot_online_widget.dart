part of '../../viam_flutter_hotspot_provisioning_widget.dart';

class RobotOnlineWidget extends StatelessWidget {
  final Robot robot;

  const RobotOnlineWidget({super.key, required this.robot});

  @override
  Widget build(BuildContext context) {
    return NoContentWidget(
      icon: const Icon(Icons.check_circle, color: Colors.green, size: 40),
      titleString: 'Connected!',
      bodyString: '${robot.name} is online and ready.',
    );
  }
}
