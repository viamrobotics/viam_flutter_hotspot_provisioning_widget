part of '../../viam_flutter_hotspot_provisioning_widget.dart';

class HotspotProvisioningFlow extends StatefulWidget {
  final Robot robot;
  final Viam viam;
  final RobotPart mainPart;
  final String hotspotPrefix;
  final String hotspotPassword;
  final Widget Function(BuildContext context)? onlineBuilder;
  final Widget Function(BuildContext context)? offlineBuilder;

  const HotspotProvisioningFlow({
    super.key,
    required this.robot,
    required this.viam,
    required this.mainPart,
    required this.hotspotPrefix,
    required this.hotspotPassword,
    this.onlineBuilder,
    this.offlineBuilder,
  });

  @override
  State<HotspotProvisioningFlow> createState() => _HotspotProvisioningFlowState();
}

class _HotspotProvisioningFlowState extends State<HotspotProvisioningFlow> {
  late final PageController _pageController;
  late final NetworkSelectionViewModel _networkSelectionViewModel;
  late final PasswordInputViewModel _passwordInputViewModel;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _networkSelectionViewModel = NetworkSelectionViewModel(widget.viam);
    _passwordInputViewModel = PasswordInputViewModel(
      widget.viam,
      widget.mainPart,
      () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
      (context, {required title, String? error}) => showAdaptiveDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          title: Text(title),
          content: error == null ? null : Text(error),
          actions: [
            PlatformDialogAction(
              onPressed: Navigator.of(context).pop,
              child: const Text('OK'),
            )
          ],
        ),
      ),
    );

    _pageController.addListener(() {
      if (!mounted) return;
      final newPage = _pageController.page!.round();
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _networkSelectionViewModel.dispose();
    _passwordInputViewModel.dispose();
    super.dispose();
  }

  AppBar _buildAppBar(BuildContext context) {
    final passwordInputViewModel = context.watch<PasswordInputViewModel>();
    final networkSelectionViewModel = context.watch<NetworkSelectionViewModel>();
    String title = "";
    List<Widget> actions = [];

    switch (_currentPage) {
      case 0:
        title = "Connect to Device Hotspot";
        break;
      case 1:
        title = "Connect to your vessel's Wi-Fi";
        actions = [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black, size: 24.0),
            onPressed: () => networkSelectionViewModel.getNetworks(refresh: true),
          )
        ];
        break;
      case 2:
        title = 'Connect to Wi-Fi';
        final canSubmit = passwordInputViewModel.areCredentialsEntered;
        actions = [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: GestureDetector(
                onTap: canSubmit ? () => passwordInputViewModel.submitPassword(context) : null,
                child: passwordInputViewModel.loading
                    ? const CupertinoActivityIndicator()
                    : Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: canSubmit ? const Color(0xFF0EB4CE) : Colors.grey,
                        ),
                      ),
              ),
            ),
          ),
        ];
        break;
      case 3:
        return AppBar(backgroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false);
    }

    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: actions,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
        onPressed: () {
          FocusScope.of(context).unfocus();
          if (_pageController.page == 0) {
            Navigator.of(context).pop();
          } else {
            _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _networkSelectionViewModel),
        ChangeNotifierProvider.value(value: _passwordInputViewModel),
      ],
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ConnectHotspotPrefixScreen(
                  robot: widget.robot,
                  viam: widget.viam,
                  mainPart: widget.mainPart,
                  onNavigateToNetworkSelection: () =>
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                  hotspotPassword: widget.hotspotPassword,
                  hotspotPrefix: widget.hotspotPrefix,
                ),
                NetworkSelectionScreen(
                  onSelectNetwork: (network) {
                    _passwordInputViewModel.network = network;
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  onManualEntry: () {
                    _passwordInputViewModel.network = null;
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                ),
                const PasswordInputScreen(),
                ConfirmationScreen(
                  robot: widget.robot,
                  viam: widget.viam,
                  mainPart: widget.mainPart,
                  onlineBuilder: widget.onlineBuilder,
                  offlineBuilder: widget.offlineBuilder,
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
