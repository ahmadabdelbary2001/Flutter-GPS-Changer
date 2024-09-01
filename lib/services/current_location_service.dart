import 'dart:async';
import '../provider/app_bloc.dart';
import 'package:location/location.dart';

/// This service uses the `location` package to check permissions,
/// enable location services, and stream location updates.
class CurrentLocationService {
  Location location = Location();
  late StreamSubscription<LocationData> currentLocationStream; // StreamSubscription to manage the location data stream
  bool serviceEnabled = false; // Boolean to track if the location service is enabled

  /// Starts the location service and begins listening to location updates.
  Future<bool> startService() async {
    // Check if the location service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // Request to enable the service if not already enabled
      serviceEnabled = await location.requestService();
    }

    // Check if location permissions are granted
    final permissionGranted = await checkLocationPermission();
    if (permissionGranted) {
      try {
        // Start listening to location updates and pass them to the LiveLocationCubit for state management
        currentLocationStream =
            location.onLocationChanged.listen((LocationData currentLocation) {
              return AppBloc.liveLocationCubit.updateUserLocation(currentLocation);
            });
      } catch (e) {
        print(e); // Print any errors that occur while setting up the location stream
      }
    }
    return permissionGranted; // Return whether the permissions are granted
  }

  /// Checks if the app has permission to access location services.
  Future<bool> checkLocationPermission() async {
    PermissionStatus isGranted = await location.hasPermission();
    if (isGranted == PermissionStatus.granted) {
      return true; // Permission already granted
    } else {
      // Request permission if not already granted
      PermissionStatus requestResult = await location.requestPermission();
      if (requestResult == PermissionStatus.granted) return true; // Permission granted after request
      return false; // Permission denied
    }
  }

  /// Disposes of the location service and cancels the location stream.
  dispose() {
    serviceEnabled = false; // Mark the service as disabled
    currentLocationStream.cancel(); // Cancel the location data stream subscription
  }
}
