import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:viam_sdk/viam_sdk.dart';
import 'package:viam_sdk/protos/app/app.dart';

import 'consts.dart';
import 'confirmation_screen.dart';

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
      final robot = await _setSmartMachineCredentials();
      await _setNetworkCredentials();
      _retryCount = 0;
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConfirmationScreen(robot: robot)),
        );
      }
    } catch (exception) {
      if (_retryCount < 1) {
        _retryCount++;
        await Future.delayed(const Duration(seconds: 2));
        await _submitPassword();
      } else {
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

  Future<Robot> _setSmartMachineCredentials() async {
    // TODO: only create if you haven't
    final viam = await Viam.withApiKey(Consts.viamApiKeyId, Consts.viamApiKey);
    final location = await viam.appClient.createLocation(Consts.organizationId, _controller.text);
    final robots = await viam.appClient.listRobots(location.id);
    final String robotName = "specter-ai-${robots.length}";
    final robotId = await viam.appClient.newMachine(robotName, location.id);
    final robot = await viam.appClient.getRobot(robotId);
    final mainPart = (await viam.appClient.listRobotParts(robotId)).firstWhere((element) => element.mainPart);
    await viam.provisioningClient.setSmartMachineCredentials(id: mainPart.id, secret: mainPart.secret);
    return robot;
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
