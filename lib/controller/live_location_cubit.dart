import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../mock/mock_location_service.dart';
import '../services/current_location_service.dart';
import 'package:location/location.dart';

class LiveLocationCubit extends Cubit<LocationData?> {
  LiveLocationCubit() : super(null);
  LocationData? currentLocation;
  List<LocationData> locations = [];
  CurrentLocationService currentLocationService = CurrentLocationService();

  MockLocationService? mockLocationService; // Add the mock location service
  bool isMocking = false;

  Future<bool> startService() async {
    if (!currentLocationService.serviceEnabled) {
      return await currentLocationService.startService();
    } else {
      return true;
    }
  }

  Future<bool> startMockService(
      {bool useMock = false, LatLng? mockLocation}) async {
    if (useMock && mockLocation != null) {
      // Start the mock location service
      mockLocationService = MockLocationService();
      mockLocationService?.startMockingLocation(mockLatLng: mockLocation);
      mockLocationService?.locationStream.listen(updateUserLocation);
      isMocking = true;
      return true;
    }
    return false;
  }

  closeService() => currentLocationService.dispose();

  closeMockService() => mockLocationService?.dispose();

  updateUserLocation(LocationData? currentLocation) {
    if (currentLocation != null) {
      locations.add(currentLocation);
      this.currentLocation = currentLocation;
      emit(this.currentLocation);
    }
  }
}
