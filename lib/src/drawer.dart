import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/google_maps_widget.dart';

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
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search'),
            onTap: () {
              _showSearchDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Go to'),
            onTap: () {
              _showLocationDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text('Select Speed'),
            onTap: () {
              // Handle the FAQ action
            },
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search for'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(hintText: 'Street or City'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                String input = controller.text;
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the drawer
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

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
                Navigator.of(context).pop(); //Close the drawer
                setState(() {
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
