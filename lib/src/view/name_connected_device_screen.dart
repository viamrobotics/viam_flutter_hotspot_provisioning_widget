part of '../../viam_flutter_provisioning_widget.dart';

class NameConnectedDeviceScreen extends StatefulWidget {
  const NameConnectedDeviceScreen({
    super.key,
    required this.connectedPeripheral,
    required this.ssid,
    required this.passkey,
  });

  final String? ssid;
  final String? passkey;
  final BluetoothDevice connectedPeripheral;

  @override
  State<NameConnectedDeviceScreen> createState() => _NameConnectedDeviceScreenState();
}

class _NameConnectedDeviceScreenState extends State<NameConnectedDeviceScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _writeConfig() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      // TODO: do pass in with robot or create one here (not the CR way though)
      // TODO: fragment stuff..? how would they customize.. after
      // do separately, and do network write first
      if (widget.ssid != null) {
        await widget.connectedPeripheral.writeNetworkConfig(
          ssid: widget.ssid!,
          pw: widget.passkey,
        );
      }
      // TODO:
      // await widget.connectedPeripheral.writeRobotPartConfig(
      //   partId: mainPart.id,
      //   secret: mainPart.secret,
      // );
      // can safely disconnect after writing config
      await widget.connectedPeripheral.disconnect();
      // if (mounted) {
      //   Navigator.of(context).push(CheckConnectedDeviceOnlineScreen.route(
      //     robot: robot,
      //     connectedPeripheral: widget.connectedPeripheral,
      //   ));
      // }
    } catch (e) {
      if (mounted) {
        //showErrorDialog(context, title: 'Error', error: 'Error configuring device');
      }
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBFC),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Name your vessel", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                autofocus: true,
                cursorColor: Colors.blue,
                decoration: InputDecoration(
                  label: Text("Name"),
                ),
                onSubmitted: (_) => _isLoading ? null : _writeConfig(),
                textInputAction: TextInputAction.done,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 32),
                child: Text(
                  "Name must contain a letter or number. Cannot start with '-' or '_'. Spaces are allowed.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isLoading ? null : _writeConfig,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator.adaptive(
                          backgroundColor: Colors.white,
                        ),
                      )
                    : const Text("Done"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
