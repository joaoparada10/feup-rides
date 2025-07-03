import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

Future<LatLng> getCurrentLocation() async {
    PermissionStatus status = await Permission.location.status;
    if (status.isPermanentlyDenied) {
      // The user opted to never see the permission request dialog again.
      // The only way to request the permission again is to direct
      // the user to the system settings, where they can grant the
      // permission to this app.
      openAppSettings();
    } else if (status.isDenied) {
      // The permission has not been granted yet, request it.
      status = await Permission.location.request();
    }

    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } else {
      return const LatLng(41.1780, -8.5980);
    }
  }