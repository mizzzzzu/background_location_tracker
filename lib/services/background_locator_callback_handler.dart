import 'dart:async';

import 'package:background_location_tracker/services/background_locator_service.dart';
import 'package:background_locator_2/location_dto.dart';

 // callback handler to use the service from native part

@pragma('vm:entry-point')
class LocationCallbackHandler {
  @pragma('vm:entry-point')
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    BackgroundLocatorServices myLocationCallbackRepository =
        BackgroundLocatorServices();
    await myLocationCallbackRepository.init(params);
  }

  @pragma('vm:entry-point')
  static Future<void> disposeCallback() async {
    BackgroundLocatorServices myLocationCallbackRepository =
        BackgroundLocatorServices();
    await myLocationCallbackRepository.dispose();
  }

  @pragma('vm:entry-point')
  static Future<void> callback(LocationDto locationDto) async {
    BackgroundLocatorServices myLocationCallbackRepository =
        BackgroundLocatorServices();
    await myLocationCallbackRepository.callback(locationDto);
  }

  @pragma('vm:entry-point')
  static Future<void> notificationCallback() async {
    print('***notificationCallback');
  }
}
