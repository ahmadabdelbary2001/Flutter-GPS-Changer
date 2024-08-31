import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../app_bloc.dart';
import '../controller/live_location_cubit.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../route.dart';
import '../services/mock_location_service.dart';
import '../provider/shared_state.dart';
import 'route_settings_dialog.dart';

class GoogleMapsWidget extends StatefulWidget {
  const GoogleMapsWidget({super.key});

  @override
  GoogleMapsWidgetState createState() => GoogleMapsWidgetState();
}

class GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  final Completer<GoogleMapController> _controller =
      Completer(); // Controller for Google Maps.

  late double lat; // Initial latitude value.
  late double lng; // Initial longitude value.
  LatLng? currentPoint;
  LatLng? previousPoint;

  MyRoute route = MyRoute(coordinates: []);

  final Set<Marker> markers = <Marker>{}; // Set to hold map markers.
  static Set<Polyline> polylines = {}; // Set to hold polylines for routes.

  bool mapDarkMode = false; // Flag to track dark mode for the map.
  bool isChanged = false;
  bool isPlaying = false; // Boolean to track whether location faking is active.

  late String _darkMapStyle; // Variable to hold the dark map style JSON.
  late String _lightMapStyle; // Variable to hold the light map style JSON.

  @override
  void initState() {
    _loadMapStyles(); // Load map styles (dark and light modes).
    super.initState();
  }

  // Method to load map styles from assets.
  Future _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/map_style/dark.json');
    _lightMapStyle = await rootBundle.loadString('assets/map_style/light.json');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _setMapStyle(); // Apply the appropriate map style based on the theme.
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHight = MediaQuery.of(context).size.height;
    return Consumer<SharedState>(builder: (context, sharedState, child) {
      bool isMoving = sharedState.isMoving;
      if (isMoving && !isChanged) {
        isChanged = true;
        _clearMapData();
      } else if (!isMoving && isChanged) {
        isChanged = false;
        _clearMapData();
      }
      return Stack(children: [
        // BlocListener to listen for live location updates and update the user's marker accordingly.
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
            markers: markers,
            // Display markers on the map.
            polylines: polylines,
            // Display polylines on the map.
            initialCameraPosition: const CameraPosition(
              target: LatLng(35.0, 39.0),
              zoom: 6.2,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller); // Complete the map controller.
              _setMapStyle(); // Set the initial map style.
            },
            onTap: handleMapTap, // Handle map taps to add markers.
          ),
        ),
        // UI button to toggle between dark and light map modes.
        Container(
          height: screenHight * 0.045,
          width: screenWidth * 0.1,
          margin: EdgeInsets.only(
              top: screenHight * 0.015, left: screenWidth * 0.89),
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
            iconSize: screenHight * 0.0225,
            onPressed: () {
              setState(() {
                mapDarkMode = !mapDarkMode; // Toggle map dark mode.
                _setMapStyle(); // Apply the selected map style.
              });
            },
          ),
        ),
        // UI button to start the location service.
        Container(
          height: screenHight * 0.045,
          width: screenWidth * 0.1,
          margin: EdgeInsets.only(
              top: screenHight * 0.015, left: screenWidth * 0.02),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.grey, width: 1.5),
          ),
          child: IconButton(
            onPressed: () {
              AppBloc.liveLocationCubit
                  .startService(); // Start the location service.
            },
            icon: const Icon(Icons.gps_fixed),
            color: Theme.of(context).primaryColor,
            iconSize: screenHight * 0.0225,
          ),
        ),
        if ((!isMoving && currentPoint != null) || (isMoving && polylines.isNotEmpty)) ...[
          Container(
            height: screenHight * 0.065,
            width: screenWidth * 0.14,
            margin: EdgeInsets.only(
                top: screenHight * 0.835, left: screenWidth * 0.435),
            decoration: BoxDecoration(
              color: isPlaying ? Colors.red : Colors.green,
              // Change color based on isPlaying.,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: IconButton(
              //onPressed: () => showRouteSettings(context),
              onPressed: () {
                if (isMoving) {
                  isPlaying
                    ? MockLocationService().stopFakeLocation()
                    : showRouteSettings(context, route);
                } else {
                  // Toggle between starting and stopping the location faking.
                  isPlaying
                      ? MockLocationService().stopFakeLocation()
                      : MockLocationService().fakeLocation(currentPoint!);
                }

                setState(() {
                  isPlaying = !isPlaying; // Toggle the isPlaying state.
                });
              },
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              // Change icon based on isPlaying.
              color: Colors.white,
              iconSize: screenHight * 0.028,
            ),
          ),
        ],
        if (isMoving && currentPoint != null) ...[
          // UI button to toggle showing point types when the user selects a moving track.
          Container(
            height: screenHight * 0.05,
            width: screenWidth * 0.11,
            margin: EdgeInsets.only(
                top: screenHight * 0.84, left: screenWidth * 0.25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(color: Colors.grey, width: 1.5),
            ),
            child: IconButton(
              onPressed: () => _removeLastPoint(),
              icon: const Icon(Icons.remove),
              color: Colors.red.shade800,
              iconSize: screenHight * 0.028,
            ),
          ),
          Container(
            height: screenHight * 0.05,
            width: screenWidth * 0.11,
            margin: EdgeInsets.only(
                top: screenHight * 0.84, left: screenWidth * 0.64),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(color: Colors.grey, width: 1.5),
            ),
            child: IconButton(
              alignment: Alignment.topLeft,
              onPressed: () {
                setState(() {
                  _clearMapData();
                });
              },
              icon: const Icon(Icons.highlight_remove),
              color: Colors.red.shade800,
              iconSize: screenHight * 0.028,
            ),
          ),
          // UI button to toggle between car and walking speed.
        ],
      ]);
    });
  }

  // Method to handle map taps and add a marker at the tapped location.
  void handleMapTap(LatLng tappedPoint) {
    setState(() {
      lat = tappedPoint.latitude;
      lng = tappedPoint.longitude;
      currentPoint = LatLng(lat, lng);
      if (!Provider.of<SharedState>(context, listen: false).isMoving) {
        polylines.clear();
        markers.removeWhere((marker) => marker.markerId.value == 'user');
        markers.clear();
        markers.add(
          Marker(
            markerId: MarkerId(tappedPoint.toString()),
            position: tappedPoint, // Use the custom icon if needed
          ),
        );
      } else {
        route.add(LatLng(lat, lng));
        markers.add(
          Marker(
            markerId: MarkerId(tappedPoint.toString()),
            position: tappedPoint, // Use the custom icon if needed
          ),
        );
        // Calculating the distance between the start and the end positions with a straight path,
        // without considering any route
        if (previousPoint != null) {
          drawLine(previousPoint!, tappedPoint);
        }
        previousPoint = tappedPoint;
      }
    });
  }

  void drawLine(LatLng startPoint, LatLng endPoint) {
    final polyline = Polyline(
      polylineId: PolylineId('${startPoint.toString()}_${endPoint.toString()}'),
      visible: true,
      points: [startPoint, endPoint],
      color: Colors.green.shade700,
      width: 3, // Customize the width of the line
    );

    setState(() {
      polylines.add(polyline);
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

  // Method to set the map style based on dark mode.
  Future _setMapStyle() async {
    final controller = await _controller.future;
    if (mapDarkMode) {
      controller.setMapStyle(_darkMapStyle); // Apply dark map style.
    } else {
      controller.setMapStyle(_lightMapStyle); // Apply light map style.
    }
  }

  // Method to update the user's location marker on the map.
  _updateUserMarker(LocationData currentLocation) {
    if (AppBloc.liveLocationCubit.currentLocationService.serviceEnabled) {
      AppBloc.liveLocationCubit.closeService();
      AppBloc.liveLocationCubit.currentLocation = null;
    }

    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      markers.removeWhere((marker) => marker.markerId.value == 'user');
      markers.clear();
      lat = currentLocation.latitude!;
      lng = currentLocation.longitude!;
      _moveCamera();
      setState(
        () {
          markers.add(
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

  void _clearMapData() {
    markers.clear();
    polylines.clear();
    route.clear();
    previousPoint = null;
    currentPoint = null;
  }

  void _removeLastPoint() {
    setState(() {
      markers.remove(markers.last);
      route.removeLast();
      currentPoint = polylines.isNotEmpty ? route.last : null;
      previousPoint = polylines.isNotEmpty ? route.last : null;
      if (polylines.isNotEmpty) {
        polylines.remove(polylines.last);
      }
    });
  }
}
