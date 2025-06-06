import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plugin_wifi_connect/plugin_wifi_connect.dart';
import 'package:viam_sdk/protos/app/app.dart';
import 'package:viam_sdk/viam_sdk.dart';

import 'no_content_widget.dart';
import 'pill_button.dart';

enum RobotStatus { online, offline, loading }

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key, required this.robot, required this.viam, required this.mainPart});

  final Viam viam;
  final Robot robot;
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
    _disconnectFromHotspot();
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

  Future<void> _disconnectFromHotspot() async {
    // TODO: want to await setting network credentials on previous screen, but fails/times out
    // so this is a hack workaround
    await Future.delayed(const Duration(seconds: 5));
    final disconnected = await PluginWifiConnect.disconnect();
    debugPrint('disconnected from hotspot: $disconnected');

    // TODO: associate hotspot sside w/ robot metadata as part of the machine already exists flow.
  }

  void _getRobotStatus() async {
    try {
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

  NoContentWidget showLoadingScreen() {
    if (_secondsLoading < provisioningTimeoutSeconds) {
      return NoContentWidget(
        titleString: _secondsLoading < provisioningStillWaitingSeconds ? "Setting up device..." : "Still trying...",
        bodyString: _secondsLoading < provisioningStillWaitingSeconds
            ? null
            : "Please keep this screen open. We'll keep trying to connect for a few more minutes.",
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
          Navigator.of(context).pop();
          // TODO: instead of popping, we should navigate to the reconnect flow when a user wants to try and reconnect after a failed provision attempt.
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_robotStatus == RobotStatus.online)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Robot is online'),
                      const Icon(Icons.check_circle, color: Colors.green),
                      // TODO: show a robot is online screen here?
                    ],
                  ),
                ),
              ),
            if (_robotStatus == RobotStatus.offline)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Robot is offline. Connection failed'),
                      const Icon(Icons.error, color: Colors.red),
                      // TODO: show error screen that takes user back to reconnect flow
                    ],
                  ),
                ),
              ),
            if (_robotStatus == RobotStatus.loading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Robot is loading'),
                      const SizedBox(height: 24),
                      showLoadingScreen(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
