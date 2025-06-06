import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plugin_wifi_connect/plugin_wifi_connect.dart';
import 'package:viam_sdk/protos/app/app.dart';
import 'package:viam_sdk/viam_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connect_hotspot_prefix_screen.dart';
import 'no_content_widget.dart';
import 'pill_button.dart';

enum RobotStatus { online, offline, loading }

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key, required this.robot, required this.viam, required this.hotspotSsid, required this.mainPart});

  final Viam viam;
  final Robot robot;
  final String hotspotSsid;
  final RobotPart mainPart;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  Timer? _timer;
  RobotStatus _robotStatus = RobotStatus.loading;
  int _secondsLoading = 0;
  static const provisioningTimeoutSeconds = 90;
  static const provisioningStillWaitingSeconds = 45;

  @override
  void initState() {
    super.initState();
    _disconnectAndAssociateHotspot();
    _startCheckingOnline();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCheckingOnline() async {
    if (_timer != null && _timer!.isActive) return;

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _getRobotStatus();
      setState(() {
        _secondsLoading += 5;
      });
    });
  }

  Future<void> _disconnectAndAssociateHotspot() async {
    // TODO: want to await setting network credentials on previous screen, but fails/times out
    // so this is a hack workaround
    // final provisioningState = Provider.of<ProvisioningState>(context, listen: false);
    await Future.delayed(const Duration(seconds: 5));
    final disconnected = await PluginWifiConnect.disconnect();
    debugPrint('disconnected from hotspot: $disconnected');

    final robotId = widget.robot.id;
    final store = await SharedPreferences.getInstance();
    // store in shared prefs as backup if the network request fails
    await store.setString('${robotId}_hotspot_ssid', widget.hotspotSsid);
    // associate with Robot metadata as this is claimed now and has machine credentials
    // final viam = await AuthService.authenticatedViam;
    await widget.viam.appClient.updateRobotMetadata(robotId, {'hotspot_ssid': widget.hotspotSsid});
  }

  void _getRobotStatus() async {
    try {
      // TODO: Call disconnect?
      final reloadedRobot = await widget.viam.appClient.getRobot(widget.robot.id);
      final newRobotStatus = await calculateRobotStatus(reloadedRobot);
      debugPrint('Robot status: $newRobotStatus, name: ${reloadedRobot.name}');
      if (newRobotStatus == RobotStatus.online) {
        // TODO: before we had goToRobotScreen();, decide if we should do something here.
        _timer?.cancel();
      }
      setState(() {
        _robotStatus = newRobotStatus;
      });
    } catch (e) {
      // if an error, that means we still lack network connection
      debugPrint('Error getting robot status ${e.toString()}');
    }
  }

  Future<RobotStatus> calculateRobotStatus(Robot robot) async {
    final seconds = robot.lastAccess.seconds.toInt();
    final actual = DateTime.now().microsecondsSinceEpoch / Duration.microsecondsPerSecond;
    if ((actual - seconds) < 10) {
      return RobotStatus.online;
    }
    return RobotStatus.loading;
  }

  NoContentWidget showErrorScreen() {
    return NoContentWidget(
      icon: Icon(Icons.highlight_off, color: Color(0xFFF86061)),
      titleString: "Connection failed",
      bodyString: "Unable to connect to your boat’s Wi-Fi network",
      button: PillButton(
        buttonString: "Try again",
        iconData: Icons.refresh,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConnectHotspotPrefixScreen(
                  robot: widget.robot,
                  mode: ProvisioningMode.reconnect,
                  // it will always be reconnect now, since your machine credentials are set
                  viam: widget.viam,
                  mainPart: widget.mainPart,
                ),
              ));
        },
      ),
    );
  }

  NoContentWidget showLoadingScreen() {
    if (_secondsLoading < provisioningTimeoutSeconds) {
      return NoContentWidget(
        titleString: _secondsLoading < provisioningStillWaitingSeconds ? "Setting up device..." : "Still trying...",
        bodyString: _secondsLoading < provisioningStillWaitingSeconds
            ? null
            : "Please keep this screen open. We’ll keep trying to connect for a few more minutes.",
      );
    }
    return NoContentWidget(
      icon: Icon(Icons.highlight_off, color: Color(0xFFF86061)),
      titleString: "Connection failed",
      bodyString: "Unable to connect to your device's Wi-Fi network",
      button: PillButton(
        buttonString: "Try again",
        iconData: Icons.refresh,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConnectHotspotPrefixScreen(
                robot: widget.robot,
                mode: ProvisioningMode.reconnect,
                hotspotSsid: widget.hotspotSsid,
                viam: widget.viam,
                mainPart: widget.mainPart,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_robotStatus == RobotStatus.online)
              Column(
                children: [
                  Text('Robot is online'),
                  Icon(Icons.check_circle, color: Colors.green),
                  // TODO: show a robot is online screen here?
                ],
              ),
            if (_robotStatus == RobotStatus.offline)
              Column(
                children: [
                  Text('Robot is offline'),
                  Icon(Icons.error, color: Colors.red),
                  showErrorScreen(),
                ],
              ),
            if (_robotStatus == RobotStatus.loading)
              Column(
                children: [
                  Text('Robot is loading'),
                  Icon(Icons.hourglass_empty, color: Colors.grey),
                  showLoadingScreen(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
