import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plugin_wifi_connect/plugin_wifi_connect.dart';
import 'package:provider/provider.dart';
import 'package:viam_sdk/protos/app/app.dart';
import 'package:viam_sdk/viam_sdk.dart';

import 'package:permission_handler/permission_handler.dart' as ph;

import 'package:pub_semver/pub_semver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

export 'package:viam_sdk/viam_sdk.dart' hide Permission;
export 'package:viam_sdk/protos/app/app.dart';

// views
part 'src/screens/confirmation.dart/widgets/confirmation_screen.dart';
part 'src/screens/connect_hotspot_prefix.dart/widgets/connect_hotspot_prefix_screen.dart';
part 'src/screens/hotspot_credentials_input.dart/widgets/hotspot_credentials_input_screen.dart';
part 'src/flow/hotspot_provisioning_flow.dart';
part 'src/screens/network_selection.dart/widgets/network_selection_screen.dart';
part 'src/screens/password_input.dart/widgets/password_input_screen.dart';
part 'src/screens/network_selection.dart/view_model/network_selection_view_model.dart';
part 'src/screens/password_input.dart/view_model/password_input_view_model.dart';
part 'src/screens/connect_hotspot_prefix.dart/view_model/connect_hotspot_prefix_view_model.dart';
part 'src/screens/confirmation.dart/view_model/confirmation_view_model.dart';
part 'src/utils/hotspot_provisioning_result.dart';

// Repository pattern implementation
part 'src/data/repositories/hotspot_provisioning_repository.dart';

// widgets
part 'src/screens/shared_widgets/no_content_widget.dart';
part 'src/screens/shared_widgets/pill_button.dart';
part 'src/screens/shared_widgets/primary_button.dart';
part 'src/screens/network_selection.dart/widgets/provisioning_list_item.dart';
part 'src/screens/confirmation.dart/widgets/robot_loading_widget.dart';
part 'src/screens/network_selection.dart/widgets/troubleshooting_dialog.dart';
