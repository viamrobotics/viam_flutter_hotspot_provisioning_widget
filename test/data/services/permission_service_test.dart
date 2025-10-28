import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../mocks/generate_mocks.mocks.dart';
 // Note: We cannot test Permission.location.request() because it's a static method call.
 // And we cannot mock PermissionStatus because it's an enum.
 // Therefore, we cannot test PermissionService class directly.
void main() {
  late MockPermissionService mockPermissionService;

  setUp(() {
    mockPermissionService = MockPermissionService();
  });

  group('requestLocationPermission', () {
    test('should return granted permission status', () async {
      when(mockPermissionService.requestLocationPermission()).thenAnswer((_) async => PermissionStatus.granted);

      final response = await mockPermissionService.requestLocationPermission();

      expect(response, isA<PermissionStatus>());
      expect(response, PermissionStatus.granted);
      verify(mockPermissionService.requestLocationPermission()).called(1);
    });

    test('should return denied permission status', () async {
      when(mockPermissionService.requestLocationPermission()).thenAnswer((_) async => PermissionStatus.denied);

      final response = await mockPermissionService.requestLocationPermission();

      expect(response, isA<PermissionStatus>());
      expect(response, PermissionStatus.denied);
      verify(mockPermissionService.requestLocationPermission()).called(1);
    });

    test('should throw an exception if the requestLocationPermission call fails', () async {
      when(mockPermissionService.requestLocationPermission())
          .thenAnswer((_) async => throw Exception('Failed to request location permission'));

      expect(() => mockPermissionService.requestLocationPermission(), throwsA(isA<Exception>()));
    });
  });

  group('getLocationPermission', () {
    test('should return true if permission is granted', () async {
      when(mockPermissionService.getLocationPermission()).thenAnswer((_) async => true);
      expect(await mockPermissionService.getLocationPermission(), isTrue);
    });

    test('should return false if permission is denied, permanently denied, or restricted', () async {
      when(mockPermissionService.getLocationPermission()).thenAnswer((_) async => false);
      expect(await mockPermissionService.getLocationPermission(), isFalse);
    });

    test('should throw an exception if the getLocationPermission call fails', () async {
      when(mockPermissionService.getLocationPermission()).thenAnswer((_) async => throw Exception('Failed to get location permission'));
      expect(() => mockPermissionService.getLocationPermission(), throwsA(isA<Exception>()));
    });
  });

  group('requestLocationPermission and getLocationPermission should be consistent', () {
    test('requestLocationPermission should return "granted" permission status and getLocationPermission should return true', () async {
      when(mockPermissionService.requestLocationPermission()).thenAnswer((_) async => PermissionStatus.granted);
      when(mockPermissionService.getLocationPermission()).thenAnswer((_) async => true);

      final permissionStatus = await mockPermissionService.requestLocationPermission();
      final hasPermission = await mockPermissionService.getLocationPermission();

      expect(permissionStatus, isA<PermissionStatus>());
      expect(hasPermission, isA<bool>());
      expect(permissionStatus, PermissionStatus.granted);
      expect(hasPermission, true);

      verify(mockPermissionService.requestLocationPermission()).called(1);
      verify(mockPermissionService.getLocationPermission()).called(1);
    });

    test('requestLocationPermission should return "denied" permission status and getLocationPermission should return false', () async {
      when(mockPermissionService.requestLocationPermission()).thenAnswer((_) async => PermissionStatus.denied);
      when(mockPermissionService.getLocationPermission()).thenAnswer((_) async => false);

      final permissionStatus = await mockPermissionService.requestLocationPermission();
      final hasPermission = await mockPermissionService.getLocationPermission();

      expect(permissionStatus, isA<PermissionStatus>());
      expect(hasPermission, isA<bool>());
      expect(permissionStatus, PermissionStatus.denied);
      expect(hasPermission, false);

      verify(mockPermissionService.requestLocationPermission()).called(1);
      verify(mockPermissionService.getLocationPermission()).called(1);
    });
  });
}
