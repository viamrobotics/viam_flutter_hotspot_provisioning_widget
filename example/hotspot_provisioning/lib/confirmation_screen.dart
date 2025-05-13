import 'dart:async';

import 'package:flutter/material.dart';
import 'package:viam_sdk/protos/app/app.dart';
import 'package:viam_sdk/viam_sdk.dart';

import 'consts.dart';

enum RobotStatus { online, offline, loading }

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key, required this.robot});

  final Robot robot;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  Timer? _timer;
  RobotStatus _robotStatus = RobotStatus.loading;
  int _secondsLoading = 0;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initTimer() {
    if (_timer != null && _timer!.isActive) return;

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _getRobotStatus();
      setState(() {
        _secondsLoading += 5;
      });
    });
  }

  void _getRobotStatus() async {
    try {
      final viam = await Viam.withApiKey(Consts.viamApiKeyId, Consts.viamApiKey);
      final reloadedRobot = await viam.appClient.getRobot(widget.robot.id);
      final newRobotStatus = await calculateRobotStatus(reloadedRobot);
      debugPrint('Robot status: $newRobotStatus');
      if (newRobotStatus == RobotStatus.online) {
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
                ],
              ),
            if (_robotStatus == RobotStatus.offline)
              Column(
                children: [
                  Text('Robot is offline'),
                  Icon(Icons.error, color: Colors.red),
                ],
              ),
            if (_robotStatus == RobotStatus.loading)
              Column(
                children: [
                  Text('Robot is loading'),
                  Icon(Icons.hourglass_empty, color: Colors.grey),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
