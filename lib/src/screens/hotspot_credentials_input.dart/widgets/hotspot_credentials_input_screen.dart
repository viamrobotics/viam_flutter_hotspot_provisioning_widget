part of '../../../../viam_flutter_hotspot_provisioning_widget.dart';

class HotspotCredentialsInputScreen extends StatefulWidget {
  final Function(String prefix, String password) onCredentialsSubmitted;

  const HotspotCredentialsInputScreen({
    super.key,
    required this.onCredentialsSubmitted,
  });

  @override
  State<HotspotCredentialsInputScreen> createState() => _HotspotCredentialsInputScreenState();
}

class _HotspotCredentialsInputScreenState extends State<HotspotCredentialsInputScreen> {
  final _prefixController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _prefixController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitCredentials() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() {
        _isSubmitting = true;
      });

      widget.onCredentialsSubmitted(
        _prefixController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Spacer(),
            TextFormField(
              controller: _prefixController,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Hotspot Prefix',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a hotspot prefix';
                }
                if (value.trim().length < 3) {
                  return 'Hotspot prefix must be at least 3 characters long';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Hotspot Password',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a hotspot password';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitCredentials(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: _isSubmitting ? null : _submitCredentials,
                text: _isSubmitting ? 'Connecting...' : 'Continue',
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
