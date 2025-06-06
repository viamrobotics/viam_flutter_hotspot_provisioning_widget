import 'dart:math';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:viam_sdk/viam_sdk.dart';
// ignore: depend_on_referenced_packages
import 'package:viam_sdk/protos/app/app.dart';

import 'connect_hotspot_prefix_screen.dart';
import 'consts.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  String? _robotName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _createRobot(); // creates robot and gets main part
  }

// this initializes viam, gets the robot, gets the main part, and then goes to the intro screen.
// TODO: should we be initializing robot, viam, and main part and storing them in a viewModel or a repository?
// TODO: also we should have one function for one thing - one for init viam, one for creating robot, one for the main part.
  Future<void> _createRobot() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final viam = await Viam.withApiKey(Consts.apiKeyId, Consts.apiKey);
      final location = await viam.appClient.createLocation(Consts.organizationId, 'test-location-${Random().nextInt(1000)}');
      final String robotName = "tester-${Random().nextInt(1000)}";
      setState(() {
        _robotName = robotName;
      });
      debugPrint('robotName: $robotName, locationId: ${location.name}');
      final robotId = await viam.appClient.newMachine(robotName, location.id);
      final robot = await viam.appClient.getRobot(robotId);
      final mainPart = (await viam.appClient.listRobotParts(robotId)).firstWhere((element) => element.mainPart);
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        _goToIntroScreenOne(context, viam, robot, mainPart);
      }
    } catch (e) {
      debugPrint('Error initializing Viam: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _robotName = null;
      });
    }
  }

  void _goToIntroScreenOne(BuildContext context, Viam viam, Robot robot, RobotPart mainPart) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ConnectHotspotPrefixScreen(
        robot: robot,
        mode: ProvisioningMode.newMachine,
        viam: viam,
        mainPart: mainPart,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Provisioning'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_robotName != null) Text('Provisioning machine named: $_robotName'),
            if (_robotName != null) const SizedBox(height: 16),
            FilledButton(
              onPressed: _createRobot,
              child: _isLoading ? const CircularProgressIndicator.adaptive(backgroundColor: Colors.white) : const Text('Start Flow'),
            ),
          ],
        ),
      ),
    );
  }
}
