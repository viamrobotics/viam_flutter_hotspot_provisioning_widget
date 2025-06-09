part of '../../viam_flutter_hotspot_provisioning_widget.dart';

class PasswordInputScreen extends StatelessWidget {
  const PasswordInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PasswordInputViewModel>();
    final bool canSubmit = viewModel.network != null || viewModel.ssidController.text.isNotEmpty;

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
                helperText: "If your network has no password, leave this field blank.",
                helperMaxLines: 2,
                helperStyle: const TextStyle(fontSize: 14.0, color: Colors.black),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 3.0)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 3.0)),
                border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 3.0)),
                suffixIcon: IconButton(
                  icon: Icon(viewModel.obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.black),
                  onPressed: () => context.read<PasswordInputViewModel>().toggleObscureText(),
                ),
              ),
              onSubmitted: (String value) {
                if (canSubmit) {
                  context.read<PasswordInputViewModel>().submitPassword(context);
                }
              },
            ),
          ),
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
