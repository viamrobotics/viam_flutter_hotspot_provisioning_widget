# Viam Flutter Hotspot Provisioning Widget

A Flutter package for provisioning Viam robots using hotspot connections. This widget provides a complete flow for connecting (or reconnecting) to a robot's hotspot, selecting a network, and provisioning the robot with network credentials.

<img src="/screenshots/provisioning_demo.gif" width="250" alt="Provisioning Flow">

## Installation
`flutter pub add viam_flutter_hotspot_provisioning_widget`

## Prerequisites

### Machine Setup

Before using this widget, you must flash your device with the Viam defaults configuration:

1. **Flash your Device**: Use the Viam CLI to flash your device: 
   For more instructions on device, see the [Viam Documentation](https://docs.viam.com/installation/prepare/rpi-setup) for an example on flashing a Raspberry Pi.

2. **Configure provisioning defaults.**: Create a provisioning configuration file (`viam-defaults.json`), by specifying at least the following info:

   > **Important**: The `hotspot_prefix` must be at least 3 characters long.

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
    For more instructions on setting up the config, see the [Viam Documentation](https://docs.viam.com/manage/fleet/provision/setup/#configure-defaults).

3. **Install viam-agent**: Run the pre-install script and pass in the location of your viam-defaults.json. This way your machine will know the hotspot prefix and password:
   ```bash
   sudo ./preinstall.sh
   ```
   
   For more instructions on running the pre-install script, see the [Viam Documentation](https://docs.viam.com/manage/fleet/provision/setup/#install-viam-agent).

## Platform Requirements

### iOS

Add the following to your `Entitlements`:

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

Add the following to your `Info.plist`:

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

// Option 1: Use hardcoded credentials
final result = await HotspotProvisioningFlow.show(
  context,
  robot: robot,
  viam: viam,
  mainPart: mainPart,
  hotspotPrefix: 'your-hotspot-prefix',  // Must match viam-defaults.json & must be at least 3 characters long 
  hotspotPassword: 'your-hotspot-password', // Must match viam-defaults.json
  fragmentId: 'your-fragment-id', // Optional, if null, the fragmentId will be read from the device.
  promptForCredentials: false, // Use hardcoded credentials
  overrideFragment: true, // Set to true if you want to override the fragment, common for new machines. 
  replaceHardware: false, // Set to true when replacing hardware and want to apply saved robot config
  robotConfig: null, // Optional, pass saved robot config when replaceHardware is true
);

// Option 2: Prompt user for credentials
final result = await HotspotProvisioningFlow.show(
  context,
  robot: robot,
  viam: viam,
  mainPart: mainPart,
  hotspotPrefix: null,
  hotspotPassword: null
  fragmentId: 'your-fragment-id',
  promptForCredentials: true, // This will show a credential input screen
  overrideFragment: true, // Set to true if you want to override the fragment, common for new machines.
  replaceHardware: false, // Set to true when replacing hardware and want to apply saved robot config
  robotConfig: null, // Optional, pass saved robot config when replaceHardware is true
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

## Credential Input Options

The `HotspotProvisioningFlow` now supports two ways to provide hotspot credentials:

### Option 1: Hardcoded Credentials
Pass the credentials directly as parameters.

```dart
final result = await HotspotProvisioningFlow.show(
  context,
  robot: robot,
  viam: viam,
  mainPart: mainPart,
  hotspotPrefix: 'your-prefix',
  hotspotPassword: 'your-password',
  fragmentId: 'your-fragment-id',
  promptForCredentials: false, // Use hardcoded credentials
  overrideFragment: true, // Set to true if you want to override the fragment, common for new machines.
  replaceHardware: false, // Set to true when replacing hardware and want to apply saved robot config
  robotConfig: null, // Optional, pass saved robot config when replaceHardware is true
);
```

### Option 2: User Input Credentials
Prompt the user to enter credentials through a simple input screen.

```dart
final result = await HotspotProvisioningFlow.show(
  context,
  robot: robot,
  viam: viam,
  mainPart: mainPart,
  hotspotPrefix: null,
  hotspotPassword: null,
  fragmentId: 'your-fragment-id',
  promptForCredentials: true, // This will show a credential input screen
  overrideFragment: true, // Set to true if you want to override the fragment, common for new machines.
  replaceHardware: false, // Set to true when replacing hardware and want to apply saved robot config
  robotConfig: null, // Optional, pass saved robot config when replaceHardware is true
);
```

When `promptForCredentials` is `true`, the `hotspotPrefix` and `hotspotPassword` parameters are optional and will be ignored.

## Hardware Replacement

To use hardware replacement mode, set `replaceHardware: true` and pass the saved robot configuration to `robotConfig`. This provisions a new machine that will inherit the configuration from an existing machine, allowing it to come online with the same components, services, and settings as the old machine, effectively acting as its replacement.

**Why `robotConfig` is required**: Without `robotConfig`, the new machine will come online with an empty configuration, defeating the purpose of hardware replacement.

**Important**: To replace hardware, you need to:
1. Create a new robot instance for the replacement hardware
2. Save the configuration from the old robot's main part
3. **Required**: Pass the saved configuration to `robotConfig` when setting `replaceHardware: true`

```dart
// Get the saved robot configuration from the old robot
final savedRobotConfig = oldRobotPart.robotConfig.toMap();

// Provision the new machine with the old machine's configuration
final result = await HotspotProvisioningFlow.show(
  context,
  robot: newRobot, // Pass in the new replacement robot
  viam: viam,
  mainPart: newMainPart, // Pass in the new replacement mainPart
  hotspotPrefix: 'your-hotspot-prefix',
  hotspotPassword: 'your-hotspot-password',
  fragmentId: 'your-fragment-id',
  promptForCredentials: false,
  overrideFragment: false,
  replaceHardware: true, // Enable hardware replacement mode
  robotConfig: savedRobotConfig, // Required: Pass the saved configuration from the old robot
);
```

## HotspotProvisioningFlow Widget
The main widget that handles the entire provisioning flow.

### Constructor Parameters:
What you need to pass into the widget:
- `robot`: The Viam robot to provision
- `viam`: The Viam SDK instance
- `mainPart`: The main robot part
- `fragmentId`: The optional fragment ID you want to configure this robot with.
- `hotspotPrefix`: The SSID prefix for the robot's hotspot. This prefix **must match** the prefix you set in the viam-defaults.json. **The hotspot prefix must be at least 3 characters long.** (Optional when `promptForCredentials` is true)
- `hotspotPassword`: The password for the robot's hotspot. This password **must match** the password you set in the viam-defaults.json. (Optional when `promptForCredentials` is true)
- `promptForCredentials`: Whether to show a credential input screen for the user to enter hotspot prefix and password. When true, `hotspotPrefix` and `hotspotPassword` are optional.
- `overrideFragment`: Whether this is a new machine being provisioned for the first time. Set to `true` for new machines, `false` for reconnecting existing machines. When `true`, the fragment override will be performed after successful provisioning.
- `replaceHardware`: Whether you are replacing hardware and want to apply a saved robot configuration. Set to `true` when replacing hardware, `false` otherwise.
- `robotConfig`: Optional saved robot configuration to apply when `replaceHardware` is `true`. Pass the configuration from the old robot that you want to apply to the new robot. Can be omitted when `replaceHardware` is `false`.  

### HotspotProvisioningResult
Contains the result of the provisioning attempt:
- `robot`: The robot that was provisioned
- `status`: The robot's status (online/offline)

### Additional Features
- **Manual Network Entry**: Fallback option to manually enter network credentials when automatic detection fails
- **Error Handling**: User-friendly error messages for common issues like incorrect hotspot password.
- **Network Type Indicators**: Icons to distinguish between public and private Wi-Fi networks
- **Public Network Support**: Connect to public networks that don't require a password


### Dependencies
This package depends on:
- `plugin_wifi_connect`: For Wi-Fi connection functionality
- `viam_sdk`: For Viam robot communication
- `permission_handler`: For platform permissions
- `flutter_platform_widgets`: For platform-specific UI
- `provider`: For state management

### Looking for a complete example?
See the [`example/hotspot_provisioning`](example/hotspot_provisioning) directory for a complete working example app that allows you to provision Viam devices.

## Important Notes

- **Do not connect manually**: Users should not connect to the hotspot through their device's Wi-Fi settings. The app will prompt them to connect when ready.
- **Hotspot credentials**: The hotspot prefix and password must match what's configured in your `viam-defaults.json` file.

## Troubleshooting

1. **Cannot connect to hotspot**: Ensure the hotspot prefix and password match your `viam-defaults.json` configuration.

2. **Permission errors**: Make sure you've added the required iOS entitlements and permissions.

3. **Robot not appearing**: Verify your robot is properly flashed with the Viam image and `viam-defaults.json`.

4. **Network not found**: Ensure your robot's hotspot is active and broadcasting.

## Publishing a New Release

To publish a new version of this package:

1. **Bump the version**: Update the version number in `pubspec.yaml` following [semantic versioning](https://semver.org/).

2. **Update the changelog**: Document your changes in `CHANGELOG.md` with the new version number and release date.

3. **Create and push a tag**: Create a git tag matching the version number and push it:
   ```bash
   git tag v1.0.0  # Replace with your version number
   git push origin v1.0.0
   ```

This will automatically trigger a GitHub release and publish the package to [pub.dev](https://pub.dev).

## License

See the [LICENSE](LICENSE) file for license rights and limitations.