import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_flutter_hotspot_provisioning_widget/viam_flutter_hotspot_provisioning_widget.dart';

void main() {
  Widget networkListWidget({
    required List<NetworkInfo> networks,
    required Future<void> Function(NetworkInfo) onSelectPublicNetwork,
    required void Function(NetworkInfo) onSelectPrivateNetwork,
    required IconData Function(int) signalToIcon,
    required IconData Function(String?) securityToIcon,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: NetworkList(
          networks: networks,
          onSelectPublicNetwork: onSelectPublicNetwork,
          onSelectPrivateNetwork: onSelectPrivateNetwork,
          signalToIcon: signalToIcon,
          securityToIcon: securityToIcon,
        ),
      ),
    );
  }

  IconData testSignalToIcon(int signal) {
    if (signal <= 40) return Icons.wifi_1_bar;
    if (signal <= 70) return Icons.wifi_2_bar;
    return Icons.wifi;
  }

  IconData testSecurityToIcon(String? security) {
    if (security == '-') return Icons.lock_open;
    return Icons.lock;
  }

  group('NetworkList', () {
    testWidgets('displays network SSID', (WidgetTester tester) async {
      final networks = [
        NetworkInfo(
          ssid: 'Test Network',
          security: 'WPA2',
          signal: 80,
        ),
      ];

      await tester.pumpWidget(
        networkListWidget(
          networks: networks,
          onSelectPublicNetwork: (_) async {},
          onSelectPrivateNetwork: (_) {},
          signalToIcon: testSignalToIcon,
          securityToIcon: testSecurityToIcon,
        ),
      );

      expect(find.text('Test Network'), findsOneWidget);
    });

    testWidgets('displays signal icon based on signal strength', (WidgetTester tester) async {
      final networks = [
        NetworkInfo(
          ssid: 'Weak Network',
          security: 'WPA2',
          signal: 30,
        ),
        NetworkInfo(
          ssid: 'Medium Network',
          security: 'WPA2',
          signal: 50,
        ),
        NetworkInfo(
          ssid: 'Strong Network',
          security: 'WPA2',
          signal: 90,
        ),
      ];

      await tester.pumpWidget(
        networkListWidget(
          networks: networks,
          onSelectPublicNetwork: (_) async {},
          onSelectPrivateNetwork: (_) {},
          signalToIcon: testSignalToIcon,
          securityToIcon: testSecurityToIcon,
        ),
      );

      expect(find.byIcon(Icons.wifi_1_bar), findsOneWidget);
      expect(find.byIcon(Icons.wifi_2_bar), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
    });

    testWidgets('displays lock icon for private network', (WidgetTester tester) async {
      final networks = [
        NetworkInfo(
          ssid: 'Private Network',
          security: 'WPA2',
          signal: 80,
        ),
      ];

      await tester.pumpWidget(
        networkListWidget(
          networks: networks,
          onSelectPublicNetwork: (_) async {},
          onSelectPrivateNetwork: (_) {},
          signalToIcon: testSignalToIcon,
          securityToIcon: testSecurityToIcon,
        ),
      );

      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.lock_open), findsNothing);
    });

    testWidgets('displays lock_open icon for public network', (WidgetTester tester) async {
      final networks = [
        NetworkInfo(
          ssid: 'Public Network',
          security: '-',
          signal: 80,
        ),
      ];

      await tester.pumpWidget(
        networkListWidget(
          networks: networks,
          onSelectPublicNetwork: (_) async {},
          onSelectPrivateNetwork: (_) {},
          signalToIcon: testSignalToIcon,
          securityToIcon: testSecurityToIcon,
        ),
      );

      expect(find.byIcon(Icons.lock_open), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNothing);
    });

    testWidgets('displays multiple networks', (WidgetTester tester) async {
      final networks = [
        NetworkInfo(
          ssid: 'Network 1',
          security: 'WPA2',
          signal: 80,
        ),
        NetworkInfo(
          ssid: 'Network 2',
          security: 'WPA3',
          signal: 70,
        ),
        NetworkInfo(
          ssid: 'Network 3',
          security: '-',
          signal: 60,
        ),
      ];

      await tester.pumpWidget(
        networkListWidget(
          networks: networks,
          onSelectPublicNetwork: (_) async {},
          onSelectPrivateNetwork: (_) {},
          signalToIcon: testSignalToIcon,
          securityToIcon: testSecurityToIcon,
        ),
      );

      expect(find.text('Network 1'), findsOneWidget);
      expect(find.text('Network 2'), findsOneWidget);
      expect(find.text('Network 3'), findsOneWidget);
    });

    testWidgets('calls onSelectPublicNetwork when public network is tapped', (WidgetTester tester) async {
      final publicNetwork = NetworkInfo(
        ssid: 'Public Network',
        security: '-',
        signal: 80,
      );

      NetworkInfo? selectedNetwork;
      Future<void> testOnSelectPublicNetwork(NetworkInfo network) async {
        selectedNetwork = network;
      }

      await tester.pumpWidget(
        networkListWidget(
          networks: [publicNetwork],
          onSelectPublicNetwork: testOnSelectPublicNetwork,
          onSelectPrivateNetwork: (_) {},
          signalToIcon: testSignalToIcon,
          securityToIcon: testSecurityToIcon,
        ),
      );

      await tester.tap(find.text('Public Network'));
      await tester.pump();

      expect(selectedNetwork, equals(publicNetwork));
    });

    testWidgets('calls onSelectPrivateNetwork when private network is tapped', (WidgetTester tester) async {
      final privateNetwork = NetworkInfo(
        ssid: 'Private Network',
        security: 'WPA2',
        signal: 80,
      );

      NetworkInfo? selectedNetwork;
      void testOnSelectPrivateNetwork(NetworkInfo network) {
        selectedNetwork = network;
      }

      await tester.pumpWidget(
        networkListWidget(
          networks: [privateNetwork],
          onSelectPublicNetwork: (_) async {},
          onSelectPrivateNetwork: testOnSelectPrivateNetwork,
          signalToIcon: testSignalToIcon,
          securityToIcon: testSecurityToIcon,
        ),
      );

      await tester.tap(find.text('Private Network'));
      await tester.pump();

      expect(selectedNetwork, equals(privateNetwork));
    });

    testWidgets('displays no networks when list is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        networkListWidget(
          networks: [],
          onSelectPublicNetwork: (_) async {},
          onSelectPrivateNetwork: (_) {},
          signalToIcon: testSignalToIcon,
          securityToIcon: testSecurityToIcon,
        ),
      );

      expect(find.byType(ProvisioningListItem), findsNothing);
    });
  });
}
