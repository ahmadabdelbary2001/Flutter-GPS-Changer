import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MockLocationService {
  final StreamController<LocationData> _locationStreamController = StreamController<LocationData>.broadcast();
  Timer? _mockTimer;
  bool serviceEnabled = false;

  Stream<LocationData> get locationStream => _locationStreamController.stream;

  void startMockingLocation({required LatLng mockLatLng, int intervalMillis = 1000}) {
    serviceEnabled = true;
    _mockTimer = Timer.periodic(Duration(milliseconds: intervalMillis), (timer) {
      _locationStreamController.add(LocationData.fromMap({
        'latitude': mockLatLng.latitude,
        'longitude': mockLatLng.longitude,
        'accuracy': 10.0,
        'altitude': 5.0,
        'speed': 0.0,
        'speed_accuracy': 0.0,
        'heading': 0.0,
        'time': DateTime.now().millisecondsSinceEpoch,
        'isMock': true,
      }));
    });
  }

  void stopMockingLocation() {
    _mockTimer?.cancel();
    _locationStreamController.close();
    serviceEnabled = false;
  }

  dispose() {
    stopMockingLocation();
  }
}
