part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class SSIDInputWidget extends StatelessWidget {
  final PasswordInputViewModel viewModel;
  final NetworkInfo? network;

  const SSIDInputWidget({
    super.key,
    required this.viewModel,
    this.network,
  });

  @override
  Widget build(BuildContext context) {
    // If we have a network, display it
    if (network != null) {
      return Padding(
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
              network!.ssid,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    // Otherwise, show the manual input field
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
            controller: viewModel.ssidController,
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
