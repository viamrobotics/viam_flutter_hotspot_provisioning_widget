import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:viam_sdk/protos/provisioning/provisioning.dart';
import 'package:viam_sdk/viam_sdk.dart';

import 'consts.dart';

class PasswordInputScreen extends StatefulWidget {
  final NetworkInfo network;

  const PasswordInputScreen({super.key, required this.network});

  @override
  State<PasswordInputScreen> createState() => _PasswordInputScreenState();
}

class _PasswordInputScreenState extends State<PasswordInputScreen> {
  final TextEditingController _controller = TextEditingController();
  bool obscureText = true;
  bool loading = false;
  int _retryCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitPassword() async {
    setState(() {
      loading = true;
    });
    try {
      // For v.0.16.0 of viam-agent, we expect machineCreds to be sent first, and then networkCreds.
      // This is why we are NOT sending them at the same time.
      await _setSmartMachineCredentials();
      // I am not awaiting setNetworkCredentials because it takes a unknown, but long amount of time to complete.
      await _setNetworkCredentials();
      _retryCount = 0;
      // TODO: NEXT/FINAL
      // if (mounted) {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => ConfirmationScreen()),
      //   );
      // }
    } catch (exception) {
      if (_retryCount < 1) {
        _retryCount++;
        await Future.delayed(const Duration(seconds: 2));
        await _submitPassword();
      } else {
        // if (mounted) {
        //   showErrorDialog(
        //     context,
        //     title: 'Failed to connect to Wi-Fi',
        //     error: 'Please try again.',
        //   );
        // }
        debugPrint('Failed to connect to Wi-Fi');
        _retryCount = 0;
      }
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _setSmartMachineCredentials() async {
    final viam = await Viam.withApiKey(Consts.viamApiKeyId, Consts.viamApiKey);
    // TODO: create the machine here too and get these
    await viam.provisioningClient.setSmartMachineCredentials(id: '', secret: '');
  }

  Future<void> _setNetworkCredentials() async {
    final viam = await Viam.withApiKey(Consts.viamApiKeyId, Consts.viamApiKey);
    await viam.provisioningClient.setNetworkCredentials(
      type: NetworkType.wifi,
      ssid: widget.network.ssid,
      psk: _controller.text,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  onTap: _submitPassword,
                  child: loading
                      ? const CupertinoActivityIndicator()
                      : Text(
                          "Done",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 18.0, 0.0, 8.0),
                child: Row(
                  children: [
                    Text(
                      "Wi-Fi network: ",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      widget.network.ssid,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 12.0),
                child: Text(
                  "Password",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  obscureText: obscureText,
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: "Leave blank if network has no password.",
                    labelStyle: TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic, color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 3.0)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 3.0)),
                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 3.0)),
                    suffixIcon: IconButton(
                      icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white),
                      onPressed: () => setState(() => obscureText = !obscureText),
                    ),
                  ),
                  onSubmitted: (String value) => _submitPassword(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
