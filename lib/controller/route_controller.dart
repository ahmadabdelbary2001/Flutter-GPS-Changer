import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class RouteController {
  final List<LatLng> coordinates;

  RouteController({required this.coordinates});

  get isNotEmpty => coordinates.isNotEmpty;
  get isEmpty => coordinates.isEmpty;
  get first => coordinates.first;
  get last => coordinates.last;

  void initState() {

  }

  void add(LatLng point){
    coordinates.add(point);
  }

  void clear(){
    coordinates.clear;
  }

  void removeLast() {
    coordinates.removeLast();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
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

  List<LatLng> findSubCoordinatesWithOffser(double speed, double inaccuracy) {
    List<LatLng> subCoordinates = findSubCoordinates(speed);
    addOffset(subCoordinates, inaccuracy);

    return subCoordinates;
  }

  List<LatLng> findSubCoordinates(double speed) {
    // Lists to hold results
    List<double> distances = [];
    List<double> latitudeDifferences = [];
    List<double> longitudeDifferences = [];
    List<double> latitudeSteps = [];
    List<double> longitudeSteps = [];
    List<double> stepsNumber = [];
    List<LatLng> subCoordinates = [];

    // Populate the lists
    for (int i = 0; i < coordinates.length - 1; i++) {
      LatLng point1 = coordinates[i];
      LatLng point2 = coordinates[i + 1];

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

    double latitude = coordinates[0].latitude;
    double longitude = coordinates[0].longitude;
    subCoordinates.add(LatLng(latitude, longitude));

    for (int i = 0; i < stepsNumber.length; i++) {
      for (int j = 0; j < stepsNumber[i].toInt(); j++) {
        if (j == stepsNumber[i].toInt() - 1) {
          latitude = coordinates[i + 1].latitude;
          longitude = coordinates[i + 1].longitude;
        }
        else {
          latitude += latitudeSteps[i];
          longitude += longitudeSteps[i];
        }
        subCoordinates.add(LatLng(latitude, longitude));
      }
    }

    return subCoordinates;
  }

  void addOffset (List<LatLng> subCoordinates, double inaccuracy) {
    if (inaccuracy == 0.0) {
      return;
    }

    Random random = Random();
    for (int i = 1; i < subCoordinates.length; i++) {

      double randomOffset = (random.nextDouble() * (2 * inaccuracy)) - inaccuracy; // Generates a random double between [-inaccuracy, inaccuracy]
      randomOffset = double.parse(randomOffset.toStringAsFixed(2)); // Rounds to two decimal places

      // Apply offsets
      double randomLatOffset = randomOffset / 111320; // Convert meters to degrees latitude
      double randomLngOffset = randomOffset / (111320 * cos(subCoordinates[i].latitude * pi / 180)); // Convert meters to degrees longitude

      double newLatitude = subCoordinates[i].latitude + randomLatOffset;
      double newLongitude = subCoordinates[i].longitude + randomLngOffset;

      subCoordinates[i] = LatLng(newLatitude, newLongitude);
    }
  }
}
