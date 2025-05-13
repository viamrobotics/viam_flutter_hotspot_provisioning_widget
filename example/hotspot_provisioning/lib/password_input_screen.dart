import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:viam_sdk/viam_sdk.dart';
import 'package:viam_sdk/protos/app/app.dart';

import 'confirmation_screen.dart';

class PasswordInputScreen extends StatefulWidget {
  final NetworkInfo network;
  final Viam viam;
  final Robot robot;
  final RobotPart mainPart;

  const PasswordInputScreen({
    super.key,
    required this.network,
    required this.viam,
    required this.robot,
    required this.mainPart,
  });

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
      await _setSmartMachineCredentials();
      _setNetworkCredentials(); // not awaiting
      _retryCount = 0;
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmationScreen(robot: widget.robot, viam: widget.viam),
          ),
        );
      }
    } catch (e) {
      if (_retryCount < 1) {
        _retryCount++;
        await Future.delayed(const Duration(seconds: 2));
        await _submitPassword();
      } else {
        debugPrint('Failed to provision machine: ${e.toString()}');
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
    await widget.viam.provisioningClient.setSmartMachineCredentials(
      id: widget.mainPart.id,
      secret: widget.mainPart.secret,
    );
  }

  Future<void> _setNetworkCredentials() async {
    await widget.viam.provisioningClient.setNetworkCredentials(
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
