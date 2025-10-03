part of '../../../viam_flutter_hotspot_provisioning_widget.dart';

class PillButton extends StatelessWidget {
  final IconData? iconData;
  final String buttonString;
  final VoidCallback? onPressed;
  final bool? enabled;

  const PillButton({
    super.key,
    this.iconData,
    required this.buttonString,
    this.onPressed,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
        backgroundColor: WidgetStatePropertyAll(enabled == null || !enabled! ? Theme.of(context).disabledColor : Theme.of(context).colorScheme.primary),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: iconData != null ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconData != null) SizedBox(width: 19.0),
          if (iconData != null)
            Icon(
              iconData,
              size: 18.0,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          if (iconData != null) SizedBox(width: 8.0),
          Text(
            buttonString,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (iconData != null) SizedBox(width: 24.0),
        ],
      ),
    );
  }
}
