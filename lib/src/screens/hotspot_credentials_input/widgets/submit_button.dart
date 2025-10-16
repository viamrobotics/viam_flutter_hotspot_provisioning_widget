part of '../../../../viam_flutter_hotspot_provisioning_widget.dart';

class CredentialsSubmitButton extends StatelessWidget {
  final HotspotCredentialsInputViewModel viewModel;
  final VoidCallback onPressed;

  const CredentialsSubmitButton({
    super.key,
    required this.viewModel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            onPressed: viewModel.isSubmitting ? null : onPressed,
            text: viewModel.isSubmitting ? 'Connecting...' : 'Continue',
          ),
        );
      },
    );
  }
}
