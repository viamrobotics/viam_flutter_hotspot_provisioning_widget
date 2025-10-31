import 'package:flutter/widgets.dart';
import 'package:mockito/annotations.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';
import 'package:viam_sdk/src/app/app.dart';

@GenerateMocks([
  HotspotProvisioningRepository,
  Viam,
  ProvisioningClient,
  AppClient,
  PluginWifiConnectService,
  PermissionService,
  HotspotProvisioningFlowViewModel,
  PageController,
  HotspotCredentialsInputViewModel,
  NetworkSelectionViewModel,
  PasswordInputViewModel,
  ConfirmationViewModel,
])
void main() {}
