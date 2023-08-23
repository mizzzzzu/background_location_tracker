import 'package:background_location/background_location.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as location;
import 'package:location/location.dart';

class LocationService {
  final BackgroundLocation _backgroundLocation = BackgroundLocation();
  final location.Location _location = location.Location();

  LatLng mapper(event) => LatLng(event.latitude, event.longitude);
  dynamic get locationStream =>
      BackgroundLocation.getLocationUpdates((location) {
        print(location.latitude);
        return mapper(location);
      });

  void init() async {
    final serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) await _location.requestService();

    var permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
    }

    if (permissionStatus == PermissionStatus.granted) {
      await await BackgroundLocation.startLocationService();

      await BackgroundLocation.setAndroidNotification(
        title: 'Background service is running',
        message: 'Background location in progress',
        icon: '@mipmap/ic_launcher',
      );
    }
  }

  Future<bool> isServiceEnabled() async {
    return _location.serviceEnabled();
  }
}
