part of '../../../viam_flutter_hotspot_provisioning_widget.dart';

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
      style: OutlinedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator.adaptive(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: onPressed != null ? Theme.of(context).colorScheme.onPrimary : Colors.grey.shade500,
              ),
            ),
    );
  }
}
