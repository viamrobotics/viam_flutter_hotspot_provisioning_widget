part of '../../../../viam_flutter_hotspot_provisioning_widget.dart';

class HotspotCredentialsInputViewModel extends ChangeNotifier {
  final Function(String prefix, String password) onCredentialsSubmitted;

  HotspotCredentialsInputViewModel({
    required this.onCredentialsSubmitted,
  });

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  void submitCredentials(String prefix, String password) {
    _isSubmitting = true;
    notifyListeners();
    onCredentialsSubmitted(prefix, password);
  }
}
