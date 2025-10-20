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
                  onTap: canSubmit ? () => widget.viewModel.submitPassword(context) : null,
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
                  if (widget.viewModel.network != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 18.0, 0.0, 8.0),
                      child: Row(
                        children: [
                          Text(
                            "Wi-Fi network: ",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            widget.viewModel.network!.ssid,
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    _manuallyEnterSSIDInput(context),
                  if (!isPublicNetwork) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 12.0),
                      child: Text(
                        "Password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        obscureText: widget.viewModel.obscureText,
                        controller: widget.viewModel.passwordController,
                        autocorrect: false,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 3.0)),
                          focusedBorder:
                              OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 3.0)),
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 3.0)),
                          suffixIcon: IconButton(
                            icon: Icon(widget.viewModel.obscureText ? Icons.visibility_off : Icons.visibility,
                                color: Theme.of(context).colorScheme.onSurface),
                            onPressed: () => widget.viewModel.toggleObscureText(),
                          ),
                        ),
                        onSubmitted: (String value) {
                          if (widget.viewModel.areNetworkCredentialsValid) {
                            widget.viewModel.submitPassword(context);
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _manuallyEnterSSIDInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 12.0),
          child: Text(
            "Wi-Fi network name",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: widget.viewModel.ssidController,
            autocorrect: false,
            decoration: InputDecoration(
              labelStyle: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onSurface),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 3.0)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 3.0)),
              border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 3.0)),
            ),
          ),
        ),
      ],
    );
  }
}
