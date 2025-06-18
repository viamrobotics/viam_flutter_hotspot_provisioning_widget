import 'dart:math';

import 'package:flutter/material.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';
import 'offline_screen.dart';
import 'online_screen.dart';
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
        debugPrint('Starting flow');

        // the result is a robot, and a robot status
        final result = await HotspotProvisioningFlow.show(
          context,
          robot: robot,
          viam: viam,
          mainPart: mainPart,
          hotspotPrefix: Consts.hotspotPrefix,
          hotspotPassword: Consts.hotspotPassword,
        );

        if (result != null) {
          // HotspotProvisioningFlow completed and returned a result
          debugPrint('Provisioning Result: Robot ${result.robot.name}, Status: ${result.status}');
          if (result.status == RobotStatus.online) {
            if (mounted) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => OnlineScreen(onPressed: () => Navigator.of(context).pop())));
            }
          } else {
            // if the robot is offline or the provisioning timed out, we should show the offline screen
            if (mounted) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => OfflineScreen(onPressed: () => Navigator.of(context).pop())));
            }
          }
        } else {
          // User cancelled the provisioning flow
          debugPrint('Hotspot provisioning cancelled.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hotspot provisioning cancelled.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to start flow: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
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
