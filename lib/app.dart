import 'package:background_location/background_location.dart';
import 'package:background_location_tracker/file_manager/file_manager.dart';
import 'package:background_location_tracker/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'background tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _locationClient = LocationService();
  final _mapController = MapController();
  final _points = <LatLng>[];
  LatLng? _currPosition;
  bool _isServiceRunning = false;

  @override
  void initState() {
    super.initState();
    _locationClient.init();
    _listenLocation();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    BackgroundLocation.stopLocationService();
  }

  void _listenLocation() async {
    if (!_isServiceRunning && await _locationClient.isServiceEnabled()) {
      _isServiceRunning = true;
      BackgroundLocation.getLocationUpdates((location) {
        LatLng newLocation = LatLng(location.latitude!, location.longitude!);
        FileManager.writeToLogFile(
            "$newLocation\n timestamp: ${location.time}");
        setState(() => _currPosition = newLocation);
        _points.add(_currPosition!);
      });

      // _locationClient.locationStream((event) {
      //   setState(() => _currPosition = event);
      //   _points.add(_currPosition!);
      // });
    } else {
      _isServiceRunning = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, _) {
            return _currPosition == null
                ? const CircularProgressIndicator()
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: _currPosition,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.geolocation.app',
                      ),
                      PolylineLayer(
                        polylineCulling: false,
                        polylines: [
                          Polyline(
                            points: _points,
                            color: Colors.blue,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                      if (_currPosition != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currPosition!,
                              builder: (context) =>
                                  const Icon(Icons.location_on),
                            ),
                          ],
                        ),
                    ],
                  );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _mapController.move(_currPosition!, _mapController.zoom),
        child: const Icon(Icons.location_on),
      ),
    );
  }
}
