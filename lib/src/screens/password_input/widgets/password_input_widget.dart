part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class PasswordInputWidget extends StatelessWidget {
  final PasswordInputViewModel viewModel;
  final VoidCallback onSubmit;

  const PasswordInputWidget({
    super.key,
    required this.viewModel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            obscureText: viewModel.obscureText,
            controller: viewModel.passwordController,
            autocorrect: false,
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 3.0)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 3.0)),
              border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 3.0)),
              suffixIcon: IconButton(
                icon: Icon(
                  viewModel.obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => viewModel.toggleObscureText(),
              ),
            ),
            onSubmitted: (String value) {
              if (viewModel.areNetworkCredentialsValid) {
                onSubmit();
              }
            },
          ),
        ),
      ],
    );
  }
}
