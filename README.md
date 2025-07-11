# viam_flutter_hotspot_provisioning_widget

A Flutter package for provisioning Viam robots using hotspot connections. This widget provides a complete flow for connecting (or reconnecting) to a robot's hotspot, selecting a network, and provisioning the robot with network credentials.

![Provisioning Flow](/screenshots/provisioning_demo.gif)

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  viam_flutter_hotspot_provisioning_widget:
    git:
      url: https://github.com/viamrobotics/viam_flutter_hotspot_provisioning_widget.git
      ref: 0.0.7
```
## Prerequisites

### Machine Setup

Before using this widget, you must flash your Raspberry Pi with the Viam defaults configuration:

1. **Flash the Pi**: Use the Viam CLI to flash your Raspberry Pi: 
   For detailed instructions, see the [Viam Documentation](https://docs.viam.com/installation/prepare/rpi-setup).

2. **Configure provisioning defaults.**: Create a provisioning configuration file (viam-defaults.json), by specifying at least the following info:
   ```json
   {
     "network_configuration": {
       "hotspot_prefix": "your-hotspot-prefix",
       "disable_captive_portal_redirect": true,
       "hotspot_password": "your-hotspot-password",
       "fragment_id": "your-fragment-id",
     }
   }
   
   ```
    For detailed instructions, see the [Viam Documentation](https://docs.viam.com/manage/fleet/provision/setup/#configure-defaults).

3. **Install viam-agent**: Run the preinstall script and pass in the location of your viam-defaults.json. This way your machine will know the hotspot prefix and password:
   ```bash
   sudo ./preinstall.sh
   ```
   
   For detailed instructions, see the [Viam Documentation](https://docs.viam.com/manage/fleet/provision/setup/#install-viam-agent).

## Platform Requirements

### iOS

Add the following to your `ios/Runner/Runner.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.networking.HotspotConfiguration</key>
    <true/>
    <key>com.apple.developer.networking.wifi-info</key>
    <true/>
</dict>
</plist>
```

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Finding and connecting nearby local bluetooth devices</string>
```

### Android

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE"/>
<uses-permission android:name="android.permission.WRITE_SETTINGS"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

## Usage

### Viam Setup

Before starting the provisioning flow, you need to:

1. **Initialize Viam instance**: Create a Viam instance with your API credentials
2. **Create or get a robot**: Either create a new robot or retrieve an existing one from your Viam organization
3. **Get the main part**: Retrieve the main robot part that will be provisioned

These steps are required because the widget needs a valid robot and Viam instance to communicate with the Viam cloud and provision the robot.

### Basic Example

```dart
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

// 1. Initialize a Viam instance with your API credentials
final viam = await Viam.withApiKey(apiKeyId, apiKey);

// 2. Create a new robot or get an existing one
final robot = await viam.appClient.getRobot(robotId);
// OR create a new robot:
// final robotId = await viam.appClient.newMachine(robotName, locationId);
// final robot = await viam.appClient.getRobot(robotId);

// 3. Get the main robot part
final mainPart = (await viam.appClient.listRobotParts(robot.id))
    .firstWhere((element) => element.mainPart);

// 4. Start the provisioning flow
final result = await HotspotProvisioningFlow.show(
  context,
  robot: robot,
  viam: viam,
  mainPart: mainPart,
  hotspotPrefix: 'your-hotspot-prefix',  // Must match viam-defaults.json
  hotspotPassword: 'your-hotspot-password', // Must match viam-defaults.json
);

// 5. Handle the result
if (result != null) {
  if (result.status == RobotStatus.online) {
    // Robot successfully provisioned. Robot is online
    print('Robot ${result.robot.name} is online!');
  } else {
    // Provisioning failed or timed out. Robot is offline
    print('Robot provisioning failed');
  }
}
```
## Additional Features
- **Manual Network Entry**: Fallback option to manually enter network credentials when automatic detection fails
- **Error Handling**: User-friendly error messages for common issues like incorrect hotspot password.
- **Network Type Indicators**: Icons to distinguish between public and private Wi-Fi networks

### Complete Example

See the `example/` directory for a complete working example.

## API Reference

### HotspotProvisioningFlow

The main widget that handles the entire provisioning flow.

**Constructor Parameters:**
- `robot`: The Viam robot to provision
- `viam`: The Viam SDK instance
- `mainPart`: The main robot part
- `hotspotPrefix`: The SSID prefix for the robot's hotspot
- `hotspotPassword`: The password for the robot's hotspot

### HotspotProvisioningResult

Contains the result of the provisioning attempt:
- `robot`: The robot that was provisioned
- `status`: The robot's status (online/offline)

## Dependencies

This package depends on:
- `plugin_wifi_connect`: For Wi-Fi connection functionality
- `viam_sdk`: For Viam robot communication
- `permission_handler`: For platform permissions
- `flutter_platform_widgets`: For platform-specific UI
- `provider`: For state management

### Important Notes

- **Do not connect manually**: Users should not connect to the hotspot through their device's Wi-Fi settings. The app will prompt them to connect when ready.
- **Hotspot credentials**: The hotspot prefix and password must match what's configured in your `viam-defaults.json` file.

## Troubleshooting

1. **Cannot connect to hotspot**: Ensure the hotspot prefix and password match your `viam-defaults.json` configuration.

2. **Permission errors**: Make sure you've added the required iOS entitlements and permissions.

3. **Robot not appearing**: Verify your robot is properly flashed with the Viam image and `viam-defaults.json`.

4. **Network not found**: Ensure your robot's hotspot is active and broadcasting.
