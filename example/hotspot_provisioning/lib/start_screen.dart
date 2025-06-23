
import 'package:flutter/material.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';
import 'reconnect_machines_screen.dart';
import 'provision_new_machine.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void _goToProvisionNewMachineFlow(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ProvisionNewMachineScreen(),
    ));
  }

  void _goToReconnectMachinesFlow(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ReconnectRobotsScreen(),
    ));
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
            PrimaryButton(
              onPressed: () => _goToProvisionNewMachineFlow(context),
              text: 'Provision New Machine',
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: () => _goToReconnectMachinesFlow(context),
              text: 'Reconnect Machine',
            ),
          ],
        ),
      ),
    );
  }
}
