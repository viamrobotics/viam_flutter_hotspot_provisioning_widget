part of '../../viam_flutter_hotspot_provisioning_widget.dart';

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
      style: OutlinedButton.styleFrom(backgroundColor: Colors.black),
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
              style: TextStyle(fontWeight: FontWeight.w500, color: onPressed != null ? Colors.white : Color(0x80F7F7F8)),
            ),
    );
  }
}
