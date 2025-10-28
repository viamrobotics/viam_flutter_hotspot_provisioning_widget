import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../mocks/generate_mocks.mocks.dart';


void main() {
  late MockPluginWifiConnectService mockPluginWifiConnectService;

  setUp(() {
    mockPluginWifiConnectService = MockPluginWifiConnectService();
  });

  group('getCurrentSSID', () {
    test('should return the current SSID', () async {
      when(mockPluginWifiConnectService.getCurrentSSID()).thenAnswer((_) async => 'test-ssid');

      final response = await mockPluginWifiConnectService.getCurrentSSID();

      expect(response, isA<String>());
      expect(response, 'test-ssid');
      verify(mockPluginWifiConnectService.getCurrentSSID()).called(1);
    });

    test('should throw an exception if the getCurrentSSID call fails', () async {
      when(mockPluginWifiConnectService.getCurrentSSID()).thenAnswer((_) async => throw Exception('Failed to get current SSID'));

      expect(() => mockPluginWifiConnectService.getCurrentSSID(), throwsA(isA<Exception>()));
    });
  });

  group('connectToSecureNetworkByPrefix', () {
    test('should return true if the network is connected', () async {
      when(mockPluginWifiConnectService.connectToSecureNetworkByPrefix(prefix: 'test-prefix', password: 'test-password', isWep: false, isWpa3: false, saveNetwork: false)).thenAnswer((_) async => true);

      final response = await mockPluginWifiConnectService.connectToSecureNetworkByPrefix(prefix: 'test-prefix', password: 'test-password', isWep: false, isWpa3: false, saveNetwork: false);

      expect(response, isA<bool>());
      expect(response, true);
    });
    test('should return false if the network is not connected', () async {
      when(mockPluginWifiConnectService.connectToSecureNetworkByPrefix(prefix: 'test-prefix', password: 'test-password', isWep: false, isWpa3: false, saveNetwork: false)).thenAnswer((_) async => false);

      final response = await mockPluginWifiConnectService.connectToSecureNetworkByPrefix(prefix: 'test-prefix', password: 'test-password', isWep: false, isWpa3: false, saveNetwork: false);

      expect(response, isA<bool>());
      expect(response, false);
    });
    test('should throw an exception if the connectToSecureNetworkByPrefix call fails', () async {
      when(mockPluginWifiConnectService.connectToSecureNetworkByPrefix(prefix: 'test-prefix', password: 'test-password', isWep: false, isWpa3: false, saveNetwork: false)).thenAnswer((_) async => throw Exception('Failed to connect to secure network by prefix'));

      expect(() => mockPluginWifiConnectService.connectToSecureNetworkByPrefix(prefix: 'test-prefix', password: 'test-password', isWep: false, isWpa3: false, saveNetwork: false), throwsA(isA<Exception>()));
    });
  });

  group('disconnect', () {
    test('should return true if the network is disconnected', () async {
      when(mockPluginWifiConnectService.disconnect()).thenAnswer((_) async => true);

      final response = await mockPluginWifiConnectService.disconnect();

      expect(response, isA<bool>());
      expect(response, true);
    });
  });
  test('should return false if the network is not disconnected', () async {
    when(mockPluginWifiConnectService.disconnect()).thenAnswer((_) async => false);

    final response = await mockPluginWifiConnectService.disconnect();

    expect(response, isA<bool>());
    expect(response, false);
  });

  test('should throw an exception if the disconnect call fails', () async {
    when(mockPluginWifiConnectService.disconnect()).thenAnswer((_) async => throw Exception('Failed to disconnect'));

    expect(() => mockPluginWifiConnectService.disconnect(), throwsA(isA<Exception>()));
  });
}
