import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../application.dart';
import '../models/api_result_model.dart';
import '../api/api.dart';

class MapRepository{
  Future<APIResultModel> getRouteCoordinates(LatLng l1, LatLng l2) {
    return API.getRouteCoordinates({
      'origin': '${l1.latitude},${l1.longitude}',
      'destination': '${l2.latitude},${l2.longitude}',
      'key': Application.GOOGLE_MAPS_API_KEY,
    });
  }
}