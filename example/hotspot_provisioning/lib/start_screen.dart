import 'dart:math';

import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart' hide Consts;
import 'package:flutter/material.dart';

import 'consts.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  String? _robotName;
  bool _isLoading = false;
  late Viam viam;
  late Robot robot;
  late RobotPart mainPart;

  @override
  void initState() {
    super.initState();
    _initViam();
  }

  Future<void> _initViam() async {
    viam = await Viam.withApiKey(Consts.apiKeyId, Consts.apiKey);
  }

  Future<void> _createRobot() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final location = await viam.appClient.createLocation(Consts.organizationId, 'test-location-${Random().nextInt(1000)}');
      final String robotName = "tester-${Random().nextInt(1000)}";
      setState(() {
        _robotName = robotName;
      });
      debugPrint('robotName: $robotName, locationId: ${location.name}');
      final robotId = await viam.appClient.newMachine(robotName, location.id);
      robot = await viam.appClient.getRobot(robotId);
      await _getMainPart();
      await Future.delayed(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Error creating robot: $e');
      setState(() {
        _robotName = null;
      });
      rethrow;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getMainPart() async {
    mainPart = (await viam.appClient.listRobotParts(robot.id)).firstWhere((element) => element.mainPart);
  }

  void _startFlow() async {
    try {
      await _createRobot();
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => HotspotProvisioningFlow(
            robot: robot,
            viam: viam,
            mainPart: mainPart,
            hotspotPrefix: Consts.hotspotPrefix,
            hotspotPassword: Consts.hotspotPassword,
          ),
        ));
      }
    } catch (e) {
      debugPrint('Failed to start flow: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Hotspot Provisioning', style: TextStyle(color: Colors.black)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_robotName != null) Text('Provisioning machine named: $_robotName'),
            if (_robotName != null) const SizedBox(height: 16),
            PrimaryButton(
              onPressed: _startFlow,
              text: _isLoading ? 'Loading...' : 'Start Flow',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
