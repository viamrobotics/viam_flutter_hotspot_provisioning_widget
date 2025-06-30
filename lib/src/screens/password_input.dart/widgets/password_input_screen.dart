part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class PasswordInputScreen extends StatefulWidget {
  const PasswordInputScreen({super.key});

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
        final viewModel = context.read<PasswordInputViewModel>();
        viewModel.clearPassword();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PasswordInputViewModel>();
    final bool isPublicNetwork = viewModel.network != null && viewModel.isPublicNetwork(viewModel.network!);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (viewModel.network != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 18.0, 0.0, 8.0),
              child: Row(
                children: [
                  const Text(
                    "Wi-Fi network: ",
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    viewModel.network!.ssid,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            )
          else
            _manuallyEnterSSIDInput(context),
          if (!isPublicNetwork) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 12.0),
              child: Text(
                "Password",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                obscureText: viewModel.obscureText,
                controller: viewModel.passwordController,
                autocorrect: false,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 3.0)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 3.0)),
                  border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 3.0)),
                  suffixIcon: IconButton(
                    icon: Icon(viewModel.obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.black),
                    onPressed: () => viewModel.toggleObscureText(),
                  ),
                ),
                onSubmitted: (String value) {
                  if (viewModel.areNetworkCredentialsValid) {
                    viewModel.submitPassword(context);
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _manuallyEnterSSIDInput(BuildContext context) {
    final viewModel = context.read<PasswordInputViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 12.0),
          child: Text(
            "Wi-Fi network name",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: viewModel.ssidController,
            autocorrect: false,
            decoration: const InputDecoration(
              labelStyle: TextStyle(fontSize: 14.0, color: Colors.black),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 3.0)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 3.0)),
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 3.0)),
            ),
          ),
        ),
      ],
    );
  }
}
