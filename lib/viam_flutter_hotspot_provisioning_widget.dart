import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plugin_wifi_connect/plugin_wifi_connect.dart';
import 'package:provider/provider.dart';
import 'package:viam_sdk/protos/app/app.dart';
import 'package:viam_sdk/viam_sdk.dart';

import 'package:permission_handler/permission_handler.dart' as ph;

import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

export 'package:viam_sdk/viam_sdk.dart' hide Permission;
export 'package:viam_sdk/protos/app/app.dart';

// views
part 'src/confirmation_screen.dart';
part 'src/connect_hotspot_prefix_screen.dart';
part 'src/flow/hotspot_provisioning_flow.dart';
part 'src/network_selection_screen.dart';
part 'src/password_input_screen.dart';
part 'src/network_selection_view_model.dart';
part 'src/password_input_view_model.dart';

// widgets
part 'src/widgets/no_content_widget.dart';
part 'src/widgets/pill_button.dart';
part 'src/widgets/primary_button.dart';
part 'src/widgets/provisioning_list_item.dart';
part 'src/widgets/robot_online_widget.dart';
part 'src/widgets/robot_offline_widget.dart';
