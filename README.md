# background_location_tracker

A new Flutter project.

## Getting Started

## ANDROID SETUP

Apps that target Android 9 (API level 28) or higher 
must add the FOREGROUND_SERVICE permission.

If the app targets Android 10 (API level 29) or higher,
we also need to check for the ACCESS_BACKGROUND_LOCATION permission.

added in Android Manifest 

``` 
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

Remember that to use the background location the user has to accept the 
location permission to Allow all the time. On Android 11 (API level 30) 
and higher, however, the system dialog doesn’t include the Allow all the 
time option. Instead, users must enable background location on a settings page.

Add location.requestPermission() or use permission_handler package


## IOS SETUP

We need to add the NSLocationWhenInUseUsageDescription key to the app's 
Info.plist file, to use location services in an iOS app.

If your app needs to access the user’s location information at all times, 
even when the app is not running, add the 
NSLocationAlwaysAndWhenInUseUsageDescription key.

``` 
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>The app needs it</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>The app needs it</string>
<key>UIBackgroundModes</key>
<array>
<string>location</string>
</array>
``` 


