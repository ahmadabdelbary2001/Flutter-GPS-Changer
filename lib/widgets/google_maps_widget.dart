import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../mock/mock_location_service.dart';
import '../repositories/map_repository.dart';
import '../utils/map_utils.dart';
import '../app_bloc.dart';
import '../controller/live_location_cubit.dart';
import 'package:location/location.dart';

class GoogleMapsWidget extends StatefulWidget {
  const GoogleMapsWidget({super.key});

  @override
  GoogleMapsWidgetState createState() => GoogleMapsWidgetState();
}

class GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  static double lat = 35.0;
  static double lng = 39.0;
  LatLng? singlePoint;
  LatLng? initialLatLng;
  LatLng? destinationLatLng;

  final Set<Marker> _markers = <Marker>{};
  late BitmapDescriptor customIcon;
  late BitmapDescriptor blueMarkerIcon;
  late BitmapDescriptor redMarkerIcon;
  late BitmapDescriptor greenMarkerIcon;

  bool mapDarkMode = false;
  bool carSpeed = true;
  bool isBeginning = false;
  bool isEnd = false;
  static bool isMoving = false; //State variable to control visibility
  bool showPointsType = false;

  late String _darkMapStyle;
  late String _lightMapStyle;

  final Set<Polyline> _polyline = {};
  List<LatLng> polylineCoordinates = [];

  late MockLocationService _mockLocationService;

  @override
  void initState() {
    BitmapDescriptor.asset(const ImageConfiguration(size: Size(50, 50)),
            'assets/images/marker_car.png')
        .then((icon) {
      customIcon = icon;
    });
    BitmapDescriptor.asset(const ImageConfiguration(size: Size(50, 50)),
            'assets/images/marker_blue.png')
        .then((icon) {
      blueMarkerIcon = icon;
    });
    BitmapDescriptor.asset(const ImageConfiguration(size: Size(50, 50)),
            'assets/images/marker_red.png')
        .then((icon) {
      redMarkerIcon = icon;
    });
    BitmapDescriptor.asset(const ImageConfiguration(size: Size(50, 50)),
            'assets/images/marker_green.png')
        .then((icon) {
      greenMarkerIcon = icon;
    });
    _loadMapStyles();
    super.initState();
  }

  Future _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/map_style/dark.json');
    _lightMapStyle = await rootBundle.loadString('assets/map_style/light.json');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _setMapStyle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      BlocListener<LiveLocationCubit, LocationData?>(
        listener: (context, liveLocation) {
          if (liveLocation != null) {
            _updateUserMarker(liveLocation);
          }
        },
        child: GoogleMap(
          mapType: MapType.normal,
          rotateGesturesEnabled: true,
          zoomGesturesEnabled: true,
          trafficEnabled: false,
          tiltGesturesEnabled: false,
          scrollGesturesEnabled: true,
          compassEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          markers: _markers,
          polylines: _polyline,
          initialCameraPosition: const CameraPosition(
            target: LatLng(35.0, 39.0),
            zoom: 6.2,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            //_setMapPins([const LatLng(35, 39.0)]);
            _setMapStyle();
          },
          onTap: handleMapTap, // Handle map taps
        ),
      ),
      Container(
        height: 39,
        width: 39,
        margin: const EdgeInsets.only(top: 10.0, left: 350.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.grey, width: 1.5),
        ),
        child: IconButton(
          icon: Icon(
            mapDarkMode ? Icons.brightness_5_outlined : Icons.brightness_2,
            color: Theme.of(context).primaryColor,
          ),
          iconSize: 20.0,
          onPressed: () {
            setState(() {
              mapDarkMode = !mapDarkMode;
              _setMapStyle();
            });
          },
        ),
      ),
      Container(
        height: 39,
        width: 39,
        margin: const EdgeInsets.only(top: 10.0, left: 7.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.grey, width: 1.5),
        ),
        child: IconButton(
          onPressed: () {
            AppBloc.liveLocationCubit.startService();
          },
          icon: const Icon(Icons.gps_fixed),
          color: Theme.of(context).primaryColor,
          iconSize: 20.0,
        ),
      ),
      if (isMoving) ...[
        Container(
          height: 39,
          width: 39,
          margin: const EdgeInsets.only(top: 55.0, left: 7.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.grey, width: 1.5),
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                showPointsType = true;
              });
            },
            icon: const Icon(Icons.add),
            color: Colors.green,
            iconSize: 20.0,
          ),
        ),
        Container(
          height: 39,
          width: 39,
          margin: const EdgeInsets.only(top: 55.0, left: 350.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.grey, width: 1.5),
          ),
          child: IconButton(
            icon: Icon(
              carSpeed
                  ? Icons.directions_car_filled_outlined
                  : Icons.directions_walk,
              color: carSpeed ? Colors.red : Colors.green,
            ),
            iconSize: 20.0,
            onPressed: () {
              setState(() {
                carSpeed = !carSpeed;
                //
              });
            },
          ),
        ),
      ],
      if (isBeginning || isEnd) ...[
        Container(
          height: 39,
          width: 39,
          margin: const EdgeInsets.only(top: 100.0, left: 7.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.grey, width: 1.5),
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                if (isEnd) {
                  destinationLatLng = null;
                  isEnd = false;
                } else {
                  initialLatLng = null;
                  isBeginning = false;
                }
              });
            },
            icon: const Icon(Icons.remove),
            color: Colors.red,
            iconSize: 20.0,
          ),
        ),
      ],
      if (showPointsType && isMoving) ...[
        Container(
          height: 39,
          width: 39,
          margin: const EdgeInsets.only(top: 55.0, left: 52.5),
          decoration: BoxDecoration(
            color: isBeginning ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.grey, width: 1.5),
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                isBeginning = true;
                initialLatLng = LatLng(lat, lng);
              });
            },
            icon: const Icon(Icons.start),
            color: isBeginning ? Colors.green : Colors.deepPurple,
            iconSize: 20.0,
          ),
        ),
        Container(
          height: 39,
          width: 39,
          margin: const EdgeInsets.only(top: 55.0, left: 97.5),
          decoration: BoxDecoration(
            color: isEnd ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.grey, width: 1.5),
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                isEnd = true;
                destinationLatLng = LatLng(lat, lng);
              });
            },
            icon: const Icon(Icons.flag),
            color: isEnd ? Colors.red : Colors.deepPurple,
            iconSize: 20.0,
          ),
        ),
      ]
    ]);
  }

  void handleMapTap(LatLng tappedPoint) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'user');
      _markers.clear();
      lat = tappedPoint.latitude;
      lng = tappedPoint.longitude;
      if (!isMoving) {
        singlePoint = LatLng(lat, lng);
      }
      _markers.add(
        Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint, // Use the custom icon if needed
          //icon: blueMarkerIcon,
        ),
      );
    });
  }

  _moveCamera([double? zoom]) async {
    final CameraPosition myPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: zoom ?? 13.0,
    );
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(myPosition));
  }

  _setMapPins(List<LatLng> markersLocation) {
    _markers.clear();
    setState(() {
      for (var markerLocation in markersLocation) {
        _markers.add(Marker(
          markerId: MarkerId(markerLocation.toString()),
          position: markerLocation,
          icon: customIcon,
        ));
      }
    });
  }

  Future _setMapStyle() async {
    final controller = await _controller.future;
    if (mapDarkMode) {
      controller.setMapStyle(_darkMapStyle);
    } else {
      controller.setMapStyle(_lightMapStyle);
    }
  }

  /*
  _setPolyLine() async {
    final result = await MapRepository()
        .getRouteCoordinates(initialLatLng, destinationLatLng);
    final route = result.data["routes"][0]["overview_polyline"]["points"];
    setState(
      () {
        _polyline.add(Polyline(
            polylineId: const PolylineId("tripRoute"),
            width: 3,
            geodesic: true,
            points: MapUtils.convertToLatLng(MapUtils.decodePoly(route)),
            color: Theme.of(context).primaryColor));
      },
    );
  }
  */

  _updateUserMarker(LocationData currentLocation) {
    if (AppBloc.liveLocationCubit.currentLocationService.serviceEnabled) {
      AppBloc.liveLocationCubit.closeService();
      AppBloc.liveLocationCubit.currentLocation = null;
    }

    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      _markers.removeWhere((marker) => marker.markerId.value == 'user');
      _markers.clear();
      lat = currentLocation.latitude!;
      lng = currentLocation.longitude!;
      _moveCamera();
      setState(
        () {
          _markers.add(
            Marker(
              markerId: const MarkerId('user'),
              position:
                  LatLng(currentLocation.latitude!, currentLocation.longitude!),
            ),
          );
        },
      );
    }
  }
}
