import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: (isLoading || onPressed == null) ? null : onPressed,
      style: FilledButton.styleFrom(backgroundColor: Colors.white),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              ),
            )
          : Text(
              text,
              style: TextStyle(fontWeight: FontWeight.w500, color: onPressed != null ? Colors.black : Color(0x80F7F7F8)),
            ),
    );
  }
}
