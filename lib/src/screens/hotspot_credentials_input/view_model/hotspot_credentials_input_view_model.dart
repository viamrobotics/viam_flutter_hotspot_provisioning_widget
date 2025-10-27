part of '../../../../viam_flutter_hotspot_provisioning_widget.dart';

class HotspotCredentialsInputViewModel extends ChangeNotifier {
  final String? configuredHotspotPrefix;
  final String? configuredHotspotPassword;
  final Function(String prefix, String password) onCredentialsSubmitted;

  HotspotCredentialsInputViewModel({
    this.configuredHotspotPrefix,
    this.configuredHotspotPassword,
    required this.onCredentialsSubmitted,
  });

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool get hasConfiguredPrefix {
    return configuredHotspotPrefix != null && configuredHotspotPrefix!.trim().isNotEmpty;
  }

  bool get hasConfiguredPassword {
    return configuredHotspotPassword != null && configuredHotspotPassword!.trim().isNotEmpty;
  }

  void submitCredentials(String prefix, String password) {
    _isSubmitting = true;
    notifyListeners();
    onCredentialsSubmitted(prefix, password);
  }
}
