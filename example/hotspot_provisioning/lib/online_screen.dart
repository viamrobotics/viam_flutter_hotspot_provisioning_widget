import 'package:flutter/material.dart';

class OnlineScreen extends StatelessWidget {
  final void Function() onPressed;
  const OnlineScreen({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Robot is online! I passed this screen in the onlineBuilder'),
            const SizedBox(height: 16),
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPressed,
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
