part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class PasswordInputScreen extends StatefulWidget {
  final PasswordInputViewModel viewModel;
  final VoidCallback onBack;

  const PasswordInputScreen({
    super.key,
    required this.viewModel,
    required this.onBack,
  });

  @override
  State<PasswordInputScreen> createState() => _PasswordInputScreenState();
}

class _PasswordInputScreenState extends State<PasswordInputScreen> {
  @override
  void initState() {
    super.initState();
    // Clear password when screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.viewModel.clearPassword();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isPublicNetwork = widget.viewModel.network != null && widget.viewModel.isPublicNetwork(widget.viewModel.network!);
    final canSubmit = widget.viewModel.areNetworkCredentialsValid;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
          title: Text("Connect to Wi-Fi",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18.0, fontWeight: FontWeight.w500)),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 24, color: Theme.of(context).colorScheme.onSurface),
            onPressed: widget.onBack,
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: GestureDetector(
                  onTap: canSubmit ? () => _handleSubmit(context) : null,
                  child: widget.viewModel.loading
                      ? const CupertinoActivityIndicator()
                      : Text(
                          "Done",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: canSubmit ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                          ),
                        ),
                ),
              ),
            ),
          ]),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, child) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SSIDFieldWidget(
                    viewModel: widget.viewModel,
                    network: widget.viewModel.network,
                  ),
                  if (!isPublicNetwork)
                    PasswordFieldWidget(
                      viewModel: widget.viewModel,
                      onSubmit: () => _handleSubmit(context),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    FocusScope.of(context).unfocus();

    try {
      await widget.viewModel.submitPassword();
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          'Failed to connect to Wi-Fi',
          'Please try again.',
        );
      }
    }
  }

  void _showErrorDialog(BuildContext context, String title, String? message) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          PlatformDialogAction(
            onPressed: Navigator.of(context).pop,
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
