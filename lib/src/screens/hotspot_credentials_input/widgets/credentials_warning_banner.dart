part of '../../../../viam_flutter_hotspot_provisioning_widget.dart';

class CredentialsWarningBanner extends StatelessWidget {
  final bool prefixConfigured;
  final bool passwordConfigured;

  const CredentialsWarningBanner({
    super.key,
    required this.prefixConfigured,
    required this.passwordConfigured,
  });

  String get _warningMessage {
    if (prefixConfigured && passwordConfigured) {
      return 'Initial hotspot prefix and password credentialswere provided earlier but will be overridden by the values you enter here.';
    } else if (prefixConfigured) {
      return 'Initial hotspot prefix credential was provided earlier but will be overridden by the value you enter here.';
    } else if (passwordConfigured) {
      return 'Initial hotspot password credential was provided earlier but will be overridden by the value you enter here.';
    } else {
      return 'Initial hotspot credentials were provided earlier but will be overridden by the values you enter here.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _warningMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
