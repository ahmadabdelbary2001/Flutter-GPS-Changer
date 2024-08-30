import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/google_maps_widget.dart';

/// A Drawer widget that provides navigation options for the GPS Changer app.
class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'GPS Changer',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          // ListTile for Go to specific coordinates
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Go to'),
            onTap: () {
              _showLocationDialog(
                  context); // Show location input dialog when tapped
            },
          ),
          // ListTile for Map Type option (currently no functionality)
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('Map Type'),
            onTap: () {
              // Future implementation for map type change
            },
          ),
        ],
      ),
    );
  }

  /// Shows a dialog for entering specific coordinates to navigate to.
  void _showLocationDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Go to location'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'latitude, longitude'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                String input = controller.text;
                final requiredLocation = input.split(",");
                print('Location input: $requiredLocation');
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the drawer
                setState(() {
                  // Handle the map tap with the provided coordinates
                  GoogleMapsWidgetState().handleMapTap(LatLng(
                      double.parse(requiredLocation[0]),
                      double.parse(requiredLocation[1])));
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
