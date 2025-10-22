part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class PermissionService {
  Future<ph.PermissionStatus> requestLocationPermission() async {
    return await ph.Permission.location.request();
  }

  Future<bool> getLocationPermission() async {
    final status = await ph.Permission.location.request();
    switch (status) {
      case ph.PermissionStatus.granted:
        return true;
      case ph.PermissionStatus.denied:
      case ph.PermissionStatus.permanentlyDenied:
      case ph.PermissionStatus.restricted:
        return false;
      case ph.PermissionStatus.limited:
      case ph.PermissionStatus.provisional:
        assert(false, 'Statuses on iOS only');
        return false;
    }
  }
}
