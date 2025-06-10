import 'package:flutter/material.dart';

class OfflineScreen extends StatelessWidget {
  final void Function() onPressed;
  const OfflineScreen({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Could not connect to the robot.'),
            const SizedBox(height: 16),
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
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
