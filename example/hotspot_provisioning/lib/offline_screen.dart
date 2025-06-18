import 'package:flutter/material.dart';

class OfflineScreen extends StatelessWidget {
  final void Function() onPressed;
  const OfflineScreen({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Could not connect to the robot. The robot may be offline or the provisioning timed out.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPressed,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
