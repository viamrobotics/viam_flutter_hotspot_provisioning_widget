part of '../../viam_flutter_hotspot_provisioning_widget.dart';

class HotspotProvisioningFlow extends StatefulWidget {
  final Robot robot;
  final Viam viam;
  final RobotPart mainPart;
  final String? hotspotPrefix;
  final String? hotspotPassword;
  final String? fragmentId;
  final bool isNewMachine;
  final bool promptForCredentials;

  const HotspotProvisioningFlow({
    super.key,
    required this.robot,
    required this.viam,
    required this.mainPart,
    this.hotspotPrefix,
    this.hotspotPassword,
    this.fragmentId,
    required this.isNewMachine,
    this.promptForCredentials = false,
  });

// Static method to push this flow and get a result
  static Future<HotspotProvisioningResult?> show(
    BuildContext context, {
    required Robot robot,
    required Viam viam,
    required RobotPart mainPart,
    String? hotspotPrefix,
    String? hotspotPassword,
    String? fragmentId,
    bool promptForCredentials = false,
    required bool isNewMachine,
  }) {
    return Navigator.of(context).push<HotspotProvisioningResult?>(
      MaterialPageRoute(
        builder: (context) => HotspotProvisioningFlow(
          robot: robot,
          viam: viam,
          mainPart: mainPart,
          hotspotPrefix: hotspotPrefix,
          hotspotPassword: hotspotPassword,
          fragmentId: fragmentId,
          promptForCredentials: promptForCredentials,
          isNewMachine: isNewMachine,
        ),
      ),
    );
  }

  @override
  State<HotspotProvisioningFlow> createState() => _HotspotProvisioningFlowState();
}

class _HotspotProvisioningFlowState extends State<HotspotProvisioningFlow> {
  late final PageController _pageController;
  late final NetworkSelectionViewModel _networkSelectionViewModel;
  late final PasswordInputViewModel _passwordInputViewModel;
  int _currentPage = 0;
  String? _determinedFragmentId;
  String? _userProvidedHotspotPrefix;
  String? _userProvidedHotspotPassword;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _networkSelectionViewModel = NetworkSelectionViewModel(viam: widget.viam);
    _passwordInputViewModel = PasswordInputViewModel(
      viam: widget.viam,
      mainPart: widget.mainPart,
      fragmentId: widget.fragmentId,
      onPasswordSubmitted: (fragmentId) {
        setState(() {
          _determinedFragmentId = fragmentId;
        });
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      },
      showErrorDialog: (context, {required title, String? error}) => showAdaptiveDialog(
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

  // when the confirmation screen determines the status, we want to pop this flow and return the result to the caller of HotspotProvisioningFlow.show()
  void onConfirmationStatusDetermined(Robot robot, RobotStatus status) {
    if (mounted) {
      Navigator.of(context).pop(HotspotProvisioningResult(robot: robot, status: status));
    }
  }

  void _onCredentialsSubmitted(String prefix, String password) {
    setState(() {
      _userProvidedHotspotPrefix = prefix;
      _userProvidedHotspotPassword = password;
    });
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  // If the user accidentally passes in hardcoded credentials, and enters in credentials via the input screen, the user-provided credentials will be used.
  String get _finalHotspotPrefix => _userProvidedHotspotPrefix ?? widget.hotspotPrefix ?? '';
  String get _finalHotspotPassword => _userProvidedHotspotPassword ?? widget.hotspotPassword ?? '';

  AppBar _buildAppBar(BuildContext context) {
    final passwordInputViewModel = context.watch<PasswordInputViewModel>();
    final networkSelectionViewModel = context.watch<NetworkSelectionViewModel>();
    String title = "";
    List<Widget> actions = [];

    switch (_currentPage) {
      case 0:
        if (widget.promptForCredentials) {
          title = "Enter Hotspot Credentials";
        } else {
          title = "Connect to Device Hotspot";
        }
        break;
      case 1:
        title = "Connect to Device Hotspot";
        break;
      case 2:
        title = "Connect to your vessel's Wi-Fi";
        actions = [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.onSurface, size: 24.0),
            onPressed: () => networkSelectionViewModel.getNetworks(refresh: true),
          )
        ];
        break;
      case 3:
        title = 'Connect to Wi-Fi';
        final canSubmit = passwordInputViewModel.areNetworkCredentialsValid;
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
      case 4:
        return AppBar(backgroundColor: Theme.of(context).colorScheme.surface, elevation: 0, automaticallyImplyLeading: false);
    }

    return AppBar(
      title: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18.0, fontWeight: FontWeight.w500)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      actions: actions,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: 24, color: Theme.of(context).colorScheme.onSurface),
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                if (widget.promptForCredentials)
                  HotspotCredentialsInputScreen(
                    onCredentialsSubmitted: _onCredentialsSubmitted,
                  ),
                ConnectHotspotPrefixScreen(
                  robot: widget.robot,
                  viam: widget.viam,
                  mainPart: widget.mainPart,
                  onNavigateToNetworkSelection: () =>
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                  hotspotPassword: _finalHotspotPassword,
                  hotspotPrefix: _finalHotspotPrefix,
                ),
                NetworkSelectionScreen(
                  viam: widget.viam,
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
                  onStatusDetermined: onConfirmationStatusDetermined,
                  fragmentId: _determinedFragmentId,
                  isNewMachine: widget.isNewMachine,
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
