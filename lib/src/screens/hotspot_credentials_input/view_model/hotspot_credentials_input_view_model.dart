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

  bool get hasConfiguredCredentials =>
      (configuredHotspotPrefix != null && configuredHotspotPrefix!.isNotEmpty) ||
      (configuredHotspotPassword != null && configuredHotspotPassword!.isNotEmpty);

  void submitCredentials(String prefix, String password) {
    _isSubmitting = true;
    notifyListeners();
    onCredentialsSubmitted(prefix, password);
  }
}
