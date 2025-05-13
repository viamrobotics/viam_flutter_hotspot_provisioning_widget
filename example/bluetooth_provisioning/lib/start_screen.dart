import 'package:flutter/material.dart';

import 'package:viam_flutter_provisioning_widget/viam_flutter_provisioning_widget.dart';

// TODO: 2 paths eventually, hotspot and ble
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void _goToIntroScreenOne(BuildContext context) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => IntroScreenOne(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Provisioning'),
      ),
      body: Center(
        child: FilledButton(
          onPressed: () => _goToIntroScreenOne(context),
          child: const Text('Start'),
        ),
      ),
    );
  }
}
