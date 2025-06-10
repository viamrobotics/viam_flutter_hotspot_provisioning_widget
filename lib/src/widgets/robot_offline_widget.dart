part of '../../viam_flutter_hotspot_provisioning_widget.dart';

class RobotOfflineWidget extends StatelessWidget {
  const RobotOfflineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const NoContentWidget(
      icon: Icon(Icons.error, color: Colors.red),
      titleString: 'Robot is offline',
      bodyString: 'Connection failed',
      // TODO: decide if we want to reconnect here?
    );
  }
}
