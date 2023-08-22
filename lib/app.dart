// import 'dart:async';

// import 'package:background_location_tracker/services/background_locator_callback_handler.dart';
// import 'package:background_location_tracker/services/location_service.dart';
// import 'package:background_locator_2/background_locator.dart';
// import 'package:background_locator_2/settings/android_settings.dart';
// import 'package:background_locator_2/settings/ios_settings.dart';
// import 'package:background_locator_2/settings/locator_settings.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'background tracker'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final _locationClient = LocationService();
//   final _mapController = MapController();
//   final _points = <LatLng>[];
//   LatLng? _currPosition;
//   bool _isServiceRunning = false;

//   @override
//   void initState() {
//     super.initState();
//     _locationClient.init();
//     _listenLocation();
//     Timer.periodic(const Duration(seconds: 3), (_) => _listenLocation());
//   }

//   void _listenLocation() async {
//     if (!_isServiceRunning && await _locationClient.isServiceEnabled()) {
//       _isServiceRunning = true;
//       _locationClient.locationStream.listen((event) {
//         setState(() => _currPosition = event);
//         _points.add(_currPosition!);
//       });
//     } else {
//       _isServiceRunning = false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: LayoutBuilder(
//           builder: (context, _) {
//             return _currPosition == null
//                 ? const CircularProgressIndicator()
//                 : FlutterMap(
//                     mapController: _mapController,
//                     options: MapOptions(
//                       center: _currPosition,
//                     ),
//                     children: [
//                       TileLayer(
//                         urlTemplate:
//                             "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
//                         userAgentPackageName: 'com.geolocation.app',
//                       ),
//                       PolylineLayer(
//                         polylineCulling: false,
//                         polylines: [
//                           Polyline(
//                             points: _points,
//                             color: Colors.blue,
//                             strokeWidth: 4,
//                           ),
//                         ],
//                       ),
//                       if (_currPosition != null)
//                         MarkerLayer(
//                           markers: [
//                             Marker(
//                               point: _currPosition!,
//                               builder: (context) =>
//                                   const Icon(Icons.location_on),
//                             ),
//                           ],
//                         ),
//                     ],
//                   );
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () =>
//             _mapController.move(_currPosition!, _mapController.zoom),
//         child: const Icon(Icons.location_on),
//       ),
//     );
//   }

//   Future<void> _startLocator() async {
//     Map<String, dynamic> data = {'countInit': 1};
//     return await BackgroundLocator.registerLocationUpdate(
//         LocationCallbackHandler.callback,
//         initCallback: LocationCallbackHandler.initCallback,
//         initDataCallback: data,
//         disposeCallback: LocationCallbackHandler.disposeCallback,
//         iosSettings: const IOSSettings(
//             accuracy: LocationAccuracy.NAVIGATION,
//             distanceFilter: 0,
//             stopWithTerminate: false),
//         autoStop: false,
//         androidSettings: const AndroidSettings(
//             accuracy: LocationAccuracy.NAVIGATION,
//             interval: 5,
//             distanceFilter: 0,
//             client: LocationClient.google,
//             androidNotificationSettings: AndroidNotificationSettings(
//                 notificationChannelName: 'Location tracking',
//                 notificationTitle: 'Start Location Tracking',
//                 notificationMsg: 'Track location in background',
//                 notificationBigMsg:
//                     'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
//                 notificationIconColor: Colors.grey,
//                 notificationTapCallback:
//                     LocationCallbackHandler.notificationCallback)));
//   }
// }

import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_location_tracker/file_manager/file_manager.dart';
import 'package:background_location_tracker/services/background_locator_callback_handler.dart';
import 'package:background_location_tracker/services/background_locator_service.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
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
  ReceivePort port = ReceivePort();

  // final _locationClient = LocationService();
  final _mapController = MapController();
  final _points = <LatLng>[];
  LatLng? _currPosition;
  bool _isServiceRunning = false;

  @override
  void initState() {
    super.initState();
    // looking for port which is created for background
    if (IsolateNameServer.lookupPortByName(
            BackgroundLocatorServices.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          BackgroundLocatorServices.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, BackgroundLocatorServices.isolateName);
    // listening to port for location data
    _listenLocation();

    initPlatformState();
    // Timer.periodic(const Duration(seconds: 3), (_) => _listenLocation());
  }

  Future<void> initPlatformState() async {
    print('Initializing...');
    await BackgroundLocator.initialize();
    final logStr = await FileManager.readLogFile();
    print('Initialization done');
    final isRunning = await BackgroundLocator.isServiceRunning();
    setState(() {
      _isServiceRunning = isRunning;
    });

    if (await BackgroundLocatorServices.checkLocationPermission()) {
      await _startLocator();
    }

    print('Running ${isRunning.toString()}');
  }

  void _listenLocation() async {
    if (!_isServiceRunning && await BackgroundLocator.isServiceRunning()) {
      _isServiceRunning = true;
      port.listen((event) async {
        print(event);
        final coordinates = event ?? LocationDto as LocationDto;

        setState(() => _currPosition =
            LatLng(coordinates.latitude, coordinates.longitude));
        _points.add(_currPosition!);
      });
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

  Future<void> _startLocator() async {
    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(
        LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: const IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            distanceFilter: 0,
            stopWithTerminate: false),
        autoStop: false,
        androidSettings: const AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 5,
            distanceFilter: 0,
            client: LocationClient.google,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                    'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }
}
