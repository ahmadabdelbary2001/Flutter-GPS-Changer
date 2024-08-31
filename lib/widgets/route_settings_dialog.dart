import 'package:flutter/material.dart';
import 'package:google_maps/route.dart';
import 'package:provider/provider.dart';
import '../services/mock_location_service.dart';
import '../provider/shared_state.dart';

class RouteSettingsDialog extends StatefulWidget {
  final double initialSpeed;
  final Function(double) onSpeedChanged;
  final double initialInaccuracy;
  final Function(double) onInaccuracyChanged;
  final String? loopMode;
  final ValueChanged<String?> onLoopModeChanged;
  final MyRoute route;

  const RouteSettingsDialog({
    super.key,
    required this.initialSpeed,
    required this.onSpeedChanged,
    required this.initialInaccuracy,
    required this.onInaccuracyChanged,
    required this.loopMode,
    required this.onLoopModeChanged,
    required this.route,
  });

  @override
  RouteSettingsDialogState createState() => RouteSettingsDialogState();
}

class RouteSettingsDialogState extends State<RouteSettingsDialog> {
  late double speed;
  late double inaccuracy;
  late String? selectedLoopMode;
  late MyRoute route;
  bool isWalking = true;
  bool isCycling = false;
  bool isDriving = false;

  @override
  void initState() {
    super.initState();
    speed = widget.initialSpeed;
    inaccuracy = widget.initialInaccuracy;
    selectedLoopMode = widget.loopMode;  // Initialize with the current loop mode
    route = widget.route;
  }

  void _updateIconState(double newSpeed) {
    setState(() {
      isWalking = newSpeed <= 10.0;
      isCycling = newSpeed > 10.0 && newSpeed <= 25.0;
      isDriving = newSpeed > 25.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      title: const Text('Play Route'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Speed: ${speed.toStringAsFixed(2)} mps'),
                GestureDetector(
                  onTap: () {},
                  child: const Text('Tap to edit',
                      style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: screenWidth * 0.08),
                Icon(Icons.directions_walk, color: isWalking? Colors.green.shade700 : Colors.grey.shade300,),
                SizedBox(width: screenWidth * 0.08),
                Icon(Icons.directions_bike, color: isCycling? Colors.green.shade700 : Colors.grey.shade300,),
                SizedBox(width: screenWidth * 0.1),
                Icon(Icons.directions_car_filled_outlined, color: isDriving? Colors.green.shade700 : Colors.grey.shade300,),
              ],
            ),
            Slider(
              value: speed,
              min: 0.5,
              max: 50,
              divisions: 198,
              label: speed.toStringAsFixed(2),
              onChanged: (newSpeed) {
                setState(() {
                  speed = newSpeed;
                });
                _updateIconState(newSpeed); // Update the icon states
                widget.onSpeedChanged(newSpeed);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Inaccuracy: ${inaccuracy.toStringAsFixed(2)} m'),
                GestureDetector(
                  onTap: () {},
                  child: const Text('Tap to edit',
                      style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            Slider(
              value: inaccuracy,
              min: 0.0,
              max: speed,
              divisions: (speed * 4).toInt(),
              label: inaccuracy.toStringAsFixed(2),
              onChanged: (newInaccuracy) {
                setState(() {
                  inaccuracy = newInaccuracy;
                });
                widget.onInaccuracyChanged(newInaccuracy);
              },
            ),
            const Row(
              children: [
                Text('Loop mode'),
              ],
            ),
            ListTile(
              title: const Text('Stop'),
              leading: Radio<String>(
                value: 'stop',
                groupValue: selectedLoopMode,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLoopMode = newValue;
                  });
                  widget.onLoopModeChanged(newValue);
                },
              ),
            ),
            ListTile(
              title: const Text('Reverse'),
              leading: Radio<String>(
                value: 'reverse',
                groupValue: selectedLoopMode,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLoopMode = newValue;
                  });
                  widget.onLoopModeChanged(newValue);
                },
              ),
            ),
            ListTile(
              title: const Text('Restart'),
              leading: Radio<String>(
                value: 'restart',
                groupValue: selectedLoopMode,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLoopMode = newValue;
                  });
                  widget.onLoopModeChanged(newValue);
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            final sharedState = Provider.of<SharedState>(context, listen: false);
            sharedState.setSpeed(speed);
            sharedState.setInaccuracy(inaccuracy);
            sharedState.setLoopMode(selectedLoopMode!);
            MockLocationService().fakeMovingLocation(context, route);
            Navigator.of(context).pop();
          },
          child: const Text('PLAY'),
        ),
      ],
    );
  }
}

void showRouteSettings(BuildContext context, MyRoute route) {
  double initialSpeed = 0.5; // Default speed
  double initialInaccuracy = 0.0; // Default inaccuracy
  String? loopMode = 'stop'; // Default loop mode

  showDialog(
    context: context,
    builder: (context) {
      return RouteSettingsDialog(
        initialSpeed: initialSpeed,
        onSpeedChanged: (newSpeed) {
          initialSpeed = newSpeed;
        },
        initialInaccuracy: initialInaccuracy,
        onInaccuracyChanged: (newInaccuracy) {
          initialInaccuracy = newInaccuracy;
        },
        loopMode: loopMode,
        onLoopModeChanged: (newMode) {
          loopMode = newMode;
        },
        route: route,
      );
    },
  );
}
