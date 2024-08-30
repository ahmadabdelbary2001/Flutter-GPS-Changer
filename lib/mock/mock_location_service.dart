import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../provider/shared_state.dart';
import '../widgets/google_maps_widget.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class MockLocationService {

  static const platform = MethodChannel(
      'fake_location'); // MethodChannel for interacting with native code.
  Timer? _timer; // Timer object to periodically send location updates.

  List<LatLng> allCoordinates = [];

  // Method to start faking the GPS location.
  Future<void> fakeLocation() async {
    try {
      // Get the current latitude and longitude from the GoogleMapsWidget.
      double latitude = GoogleMapsWidgetState.lat;
      double longitude = GoogleMapsWidgetState.lng;
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

  Future<void> fakeMovingLocation(BuildContext context) async {
    try {
      final sharedState = Provider.of<SharedState>(context, listen: false);
      double speed = sharedState.speed;
      double inaccuracy = sharedState.inaccuracy;
      String loopMood = sharedState.loopMode;

      findAllRouteCoordinates(speed);

      // Initialize the step index
      int stepIndex = 1;

      // Set up a timer to periodically update the fake location every 1 second.
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
        if (loopMood == 'stop') {
          _updateLocation(t, stepIndex, speed, inaccuracy, () {
            stopFakeLocation(); // Stop fake location when all steps are completed
            t.cancel(); // Cancel the timer
          });
          stepIndex++;
        } else if (loopMood == 'restart') {
          _updateLocation(t, stepIndex, speed, inaccuracy, () {
            stepIndex = 0; // Restart the loop
          });
          stepIndex++;
        } else {
          _updateLocation(t, stepIndex, speed, inaccuracy, () {
            stepIndex = 0;
            allCoordinates = allCoordinates.reversed
                .toList(); // Reverse the coordinates list
          });
          stepIndex++;
        }
      });
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
      print("Failed to stop faking location: '${e
          .message}'."); // Handle any errors.
    }
  }

  // Method to calculate the distance between two coordinates in meters
  double _calculateDistance(double lat1, double lon1, double lat2,
      double lon2) {
    const double earthRadius = 6371000; // meters
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void findAllRouteCoordinates(double speed) {
    // Lists to hold results
    List<double> distances = [];
    List<double> latitudeDifferences = [];
    List<double> longitudeDifferences = [];
    List<double> latitudeSteps = [];
    List<double> longitudeSteps = [];
    List<double> stepsNumber = [];

    // Populate the lists
    for (int i = 0; i <
        GoogleMapsWidgetState.polylineCoordinates.length - 1; i++) {
      LatLng point1 = GoogleMapsWidgetState.polylineCoordinates[i];
      LatLng point2 = GoogleMapsWidgetState.polylineCoordinates[i + 1];

      // Calculate distance and add to the distances list
      double distance = _calculateDistance(
          point1.latitude, point1.longitude, point2.latitude, point2.longitude);
      distances.add(distance);

      // Calculate latitude difference and add to the list
      double latDiff = point2.latitude - point1.latitude;
      latitudeDifferences.add(latDiff);

      // Calculate longitude difference and add to the list
      double lonDiff = point2.longitude - point1.longitude;
      longitudeDifferences.add(lonDiff);
    }

    for (int i = 0; i < distances.length; i++) {
      latitudeSteps.add((speed / distances[i]) * latitudeDifferences[i]);
      longitudeSteps.add((speed / distances[i]) * longitudeDifferences[i]);
      stepsNumber.add(distances[i] / speed);
    }

    double latitude = GoogleMapsWidgetState.polylineCoordinates[0].latitude;
    double longitude = GoogleMapsWidgetState.polylineCoordinates[0].longitude;
    allCoordinates.add(LatLng(latitude, longitude));
    for (int i = 0; i < stepsNumber.length; i++) {
      for (int j = 0; j < stepsNumber[i].toInt(); j++) {
        latitude += latitudeSteps[i];
        longitude += longitudeSteps[i];
        allCoordinates.add(LatLng(latitude, longitude));
      }
    }
  }

  LatLng randomInaccuracy(double speed, double inaccuracy, int stepIndex) {
    if (stepIndex >= allCoordinates.length - 1) {
      // If stepIndex is the last or out of bounds, return the current coordinate with no inaccuracy.
      return LatLng(0.0, 0.0);
    }

    Random random = Random();
    double randomInacc = random.nextDouble() * (2 * inaccuracy) - inaccuracy; // Generates a random double between [-inaccuracy, inaccuracy]
    randomInacc = double.parse(randomInacc.toStringAsFixed(2)); // Rounds to two decimal places
    double distance = speed;

    double latDiff = allCoordinates[stepIndex + 1].latitude -
        allCoordinates[stepIndex].latitude;
    double lonDiff = allCoordinates[stepIndex + 1].longitude -
        allCoordinates[stepIndex].longitude;

    double inaccLatitude = (latDiff / distance) * randomInacc;
    double inaccLongitude = (lonDiff / distance) * randomInacc;

    return LatLng(inaccLatitude, inaccLongitude);
  }

  void _updateLocation(Timer t, int stepIndex,double speed, double inaccuracy, Function onComplete) async {
    if (stepIndex < allCoordinates.length) {
      LatLng inaccuracyLatLng = randomInaccuracy(speed, inaccuracy, stepIndex);
      // Calculate new latitude and longitude based on steps
      double latitude = allCoordinates[stepIndex].latitude + inaccuracyLatLng.latitude;
      double longitude = allCoordinates[stepIndex].longitude + inaccuracyLatLng.longitude;

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