import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../provider/shared_state.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../controller/route_controller.dart';

class MockLocationService {
  static const platform = MethodChannel(
      'fake_location'); // MethodChannel for interacting with native code.
  Timer? _timer; // Timer object to periodically send location updates.

  // Method to start faking the GPS location.
  Future<void> fakeLocation(LatLng myFakeLocation) async {
    try {
      // Get the current latitude and longitude from the GoogleMapsWidget.
      double latitude = myFakeLocation.latitude;
      double longitude = myFakeLocation.longitude;
      // Invoke the native method to fake the location.
      await platform.invokeMethod('fakeLocation', {
        'latitude': latitude,
        'longitude': longitude,
      });

      // Set up a timer to periodically update the fake location every 1 seconds.
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
        await platform.invokeMethod('fakeLocation', {
          'latitude': latitude,
          'longitude': longitude,
        });
      });
    } on PlatformException catch (e) {
      print("Failed to fake location: '${e.message}'."); // Handle any errors.
    }
  }

  Future<void> fakeMovingLocation(BuildContext context, RouteController route) async {
    try {
      final sharedState = Provider.of<SharedState>(context, listen: false);
      double speed = sharedState.speed;
      double inaccuracy = sharedState.inaccuracy;
      String loopMood = sharedState.loopMode;

      double latitude = route.first.latitude;
      double longitude = route.first.longitude;

      List<LatLng> subCoordinates = route.findSubCoordinatesWithOffser(speed, inaccuracy);

      // Initialize the step index
      int stepIndex = 1;

      // Invoke the native method to fake the location.
      await platform.invokeMethod('fakeLocation', {
        'latitude': latitude,
        'longitude': longitude,
      });

      // Set up a timer to periodically update the fake location every 1 second.
      if (loopMood == 'stop') {
        _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
          _updateLocation(t, subCoordinates, stepIndex, () {
            stopFakeLocation(); // Stop fake location when all steps are completed
            t.cancel(); // Cancel the timer
          });
          stepIndex++;
        });
      } else if (loopMood == 'restart') {
        _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
          _updateLocation(t, subCoordinates, stepIndex, () {
            stepIndex = 0; // Restart the loop
          });
          stepIndex++;
        });
      } else {
        _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
          _updateLocation(t, subCoordinates, stepIndex, () {
            stepIndex = 0;
            subCoordinates = subCoordinates.reversed
                .toList(); // Reverse the coordinates list
          });
          stepIndex++;
        });
      }

    } on PlatformException catch (e) {
      print("Failed to fake location: '${e.message}'."); // Handle any errors.
    }
  }

  // Method to stop faking the GPS location.
  Future<void> stopFakeLocation() async {
    try {
      // Invoke the native method to stop faking the location.
      await platform.invokeMethod('stopFakeLocation');
      _timer?.cancel(); // Cancel the timer.
    } on PlatformException catch (e) {
      print(
          "Failed to stop faking location: '${e.message}'."); // Handle any errors.
    }
  }

  void _updateLocation(Timer t, List<LatLng> subCoordinates, int stepIndex, Function onComplete) async {
    if (stepIndex < subCoordinates.length) {
      double latitude = subCoordinates[stepIndex].latitude;
      double longitude = subCoordinates[stepIndex].longitude;

      // Invoke the native method to fake the location.
      await platform.invokeMethod('fakeLocation', {
        'latitude': latitude,
        'longitude': longitude,
      });
    } else {
      onComplete();
    }
  }

  void dispose() {
    _timer?.cancel(); // Cancel the timer.
  }
}
