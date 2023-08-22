import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  LatLng mapper(event) => LatLng(event.latitude!, event.longitude!);
  Stream<LatLng> get locationStream => _location.onLocationChanged.map(mapper);

  void init() async {
    final serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) await _location.requestService();

    var permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
    }

    if (permissionStatus == PermissionStatus.granted) {
      await _location.enableBackgroundMode();
      await _location.changeNotificationOptions(
        title: 'Geolocation',
        subtitle: 'Geolocation detection',
      );
    }
  }

  Future<bool> isServiceEnabled() async {
    return _location.serviceEnabled();
  }
}
