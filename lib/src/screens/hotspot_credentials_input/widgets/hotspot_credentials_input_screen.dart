part of '../../../../viam_flutter_hotspot_provisioning_widget.dart';

class HotspotCredentialsInputScreen extends StatefulWidget {
  final HotspotCredentialsInputViewModel viewModel;
  final VoidCallback onBack;

  const HotspotCredentialsInputScreen({
    super.key,
    required this.viewModel,
    required this.onBack,
  });

  @override
  State<HotspotCredentialsInputScreen> createState() => _HotspotCredentialsInputScreenState();
}

class _HotspotCredentialsInputScreenState extends State<HotspotCredentialsInputScreen> {
  final _prefixController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _prefixController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitCredentials() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      widget.viewModel.submitCredentials(
        _prefixController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Enter Hotspot Credentials",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18.0, fontWeight: FontWeight.w500)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24, color: Theme.of(context).colorScheme.onSurface),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (widget.viewModel.hasConfiguredPrefix || widget.viewModel.hasConfiguredPassword)
                  CredentialsWarningBanner(
                    prefixConfigured: widget.viewModel.hasConfiguredPrefix,
                    passwordConfigured: widget.viewModel.hasConfiguredPassword,
                  ),
                const Spacer(),
                CredentialsTextField(
                  controller: _prefixController,
                  label: 'Hotspot Prefix',
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
                CredentialsTextField(
                  controller: _passwordController,
                  label: 'Hotspot Password',
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
                CredentialsSubmitButton(
                  viewModel: widget.viewModel,
                  onPressed: _submitCredentials,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
