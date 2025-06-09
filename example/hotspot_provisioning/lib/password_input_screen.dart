import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:viam_sdk/viam_sdk.dart';
import 'package:viam_sdk/protos/app/app.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'confirmation_screen.dart';

class PasswordInputScreen extends StatefulWidget {
  final NetworkInfo? network;
  final Viam viam;
  final Robot robot;
  final RobotPart mainPart;

  const PasswordInputScreen({
    super.key,
    this.network,
    required this.viam,
    required this.robot,
    required this.mainPart,
  });

  @override
  State<PasswordInputScreen> createState() => _PasswordInputScreenState();
}

class _PasswordInputScreenState extends State<PasswordInputScreen> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _ssidController = TextEditingController();

  bool obscureText = true;
  bool loading = false;

  // int _retryCount = 0;

  @override
  void dispose() {
    _passwordController.dispose();
    _ssidController.dispose();
    super.dispose();
  }

  // Future<void> _submitPassword() async {
  //   setState(() {
  //     loading = true;
  //   });
  //   try {
  //     await _setSmartMachineCredentials();
  //     _setNetworkCredentials(); // not awaiting
  //     _retryCount = 0;
  //     if (mounted) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => ConfirmationScreen(robot: widget.robot, viam: widget.viam, hotspotSsid: widget.hotspotSsid),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (_retryCount < 1) {
  //       _retryCount++;
  //       await Future.delayed(const Duration(seconds: 2));
  //       await _submitPassword();
  //     } else {
  //       debugPrint('Failed to provision machine: ${e.toString()}');
  //       _retryCount = 0;
  //     }
  //     if (mounted) {
  //       setState(() {
  //         loading = false;
  //       });
  //     }
  //   }
  // }
  Future<void> _submitPassword() async {
    setState(() {
      loading = true;
    });
    try {
      // For v.0.16.0 of viam-agent, we expect machineCreds to be sent first, and then networkCreds.
      // This is why we are NOT sending them at the same time.
      final response = await getSmartMachineStatus();
      if (!response.hasSmartMachineCredentials) {
        await _setSmartMachineCredentials();
      }
      // We are not awaiting setNetworkCredentials because it takes a unknown, but long amount of time to complete, or times out.
      // If the user has gotten this far, we've validated that this is their machine, so we can just set the network credentials.
      _setNetworkCredentials(widget.network?.ssid.trim() ?? _ssidController.text.trim(), _passwordController.text.trim());

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmationScreen(robot: widget.robot, viam: widget.viam, mainPart: widget.mainPart),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog(
          context,
          title: 'Failed to connect to Wi-Fi',
          error: 'Please try again.',
        );
      }
      setState(() {
        loading = false;
      });
    }
  }

// TODO: this needs to be in a view model as well
  Future<GetSmartMachineStatusResponse> getSmartMachineStatus() async {
    return await widget.viam.provisioningClient.getSmartMachineStatus();
  }

// TODO:this is why we need to pass the main part all the way through the screens. since we need it here.
  Future<void> _setSmartMachineCredentials() async {
    await widget.viam.provisioningClient.setSmartMachineCredentials(
      id: widget.mainPart.id,
      secret: widget.mainPart.secret,
    );
  }

  Future<void> _setNetworkCredentials(String ssid, String psk) async {
    await widget.viam.provisioningClient.setNetworkCredentials(
      type: NetworkType.wifi,
      ssid: ssid,
      psk: psk,
    );
    // TOOD: include provisioning attempts like we have in gost??
  }

  /// Show an error dialog with one action: OK, which simply dismisses the dialog
  Future<void> showErrorDialog(BuildContext context, {String title = 'An Error Occurred', String? error}) {
    return showAdaptiveDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
              title: Text(title),
              content: error == null ? null : Text(error),
              actions: [
                PlatformDialogAction(
                  onPressed: Navigator.of(context).pop,
                  child: Text('OK'),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = widget.network != null || _ssidController.text.isNotEmpty;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Connect to Wi-Fi'),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: GestureDetector(
                  onTap: canSubmit ? _submitPassword : null,
                  child: loading
                      ? const CupertinoActivityIndicator()
                      : Text(
                          "Done",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: canSubmit ? Color(0xFF0EB4CE) : Colors.grey,
                          ),
                        ),
                ),
              ),
            ),
          ],
          // pop: true, TODO: do we need pop? what cannot we not do without it?
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.network != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 18.0, 0.0, 8.0),
                  child: Row(
                    children: [
                      Text(
                        "Wi-Fi network: ",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.network!.ssid,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                )
              else
                _manuallyEnterSSIDInput(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 12.0),
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
                  obscureText: obscureText,
                  controller: _passwordController,
                  autocorrect: false,
                  decoration: InputDecoration(
                    helperText: "If your network has no password, leave this field blank.",
                    helperMaxLines: 2,
                    helperStyle: TextStyle(fontSize: 14.0, color: Colors.black),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 3.0)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 3.0)),
                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 3.0)),
                    suffixIcon: IconButton(
                      icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.black),
                      onPressed: () => setState(() => obscureText = !obscureText),
                    ),
                  ),
                  onSubmitted: (String value) {
                    if (canSubmit) {
                      _submitPassword();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _manuallyEnterSSIDInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 12.0),
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
            controller: _ssidController,
            autocorrect: false,
            decoration: InputDecoration(
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
