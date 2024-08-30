import 'package:bloc/bloc.dart';
import '../services/current_location_service.dart';
import 'package:location/location.dart';

/// Cubit class to manage live location updates
class LiveLocationCubit extends Cubit<LocationData?> {
  LiveLocationCubit() : super(null);
  LocationData? currentLocation;
  List<LocationData> locations = []; // List to store the history of location updates
  CurrentLocationService currentLocationService = CurrentLocationService();

  /// Method to start the location service
  Future<bool> startService() async {
    if (!currentLocationService.serviceEnabled) {
      return await currentLocationService.startService();
    } else {
      return true;
    }
  }

  /// Method to stop the location service
  closeService() => currentLocationService.dispose();

  /// Method to update the user's location
  updateUserLocation(LocationData? currentLocation) {
    if (currentLocation != null) {
      locations.add(currentLocation);
      this.currentLocation = currentLocation;
      emit(this.currentLocation);  // Emit the new location as the state
    }
  }
}