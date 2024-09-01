import 'package:flutter/material.dart';
import 'package:google_maps/controller/route_controller.dart';
import 'package:provider/provider.dart';
import '../services/mock_location_service.dart';
import '../provider/shared_state.dart';
import '../controller/route_settings_controller.dart';

class RouteSettingsDialog extends StatefulWidget {
  final double initialSpeed;
  final Function(double) onSpeedChanged;
  final double initialInaccuracy;
  final Function(double) onInaccuracyChanged;
  final String? loopMode;
  final ValueChanged<String?> onLoopModeChanged;
  final RouteController route;

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
  late RouteSettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RouteSettingsController(
      speed: widget.initialSpeed,
      inaccuracy: widget.initialInaccuracy,
      selectedLoopMode: widget.loopMode,
    );
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
            _buildSpeedRow(),
            _buildIconsRow(screenWidth),
            _buildSpeedSlider(),
            _buildInaccuracyRow(),
            _buildInaccuracySlider(),
            _buildLoopModeSection(),
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
            sharedState.setSpeed(_controller.speed);
            sharedState.setInaccuracy(_controller.inaccuracy);
            sharedState.setLoopMode(_controller.selectedLoopMode!);
            MockLocationService().fakeMovingLocation(context, widget.route);
            Navigator.of(context).pop();
          },
          child: const Text('PLAY'),
        ),
      ],
    );
  }

  Widget _buildSpeedRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Speed: ${_controller.speed.toStringAsFixed(2)} mps'),
        GestureDetector(
          onTap: () {},
          child: const Text('Tap to edit',
              style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  Widget _buildIconsRow(double screenWidth) {
    return Row(
      children: [
        SizedBox(width: screenWidth * 0.08),
        Icon(Icons.directions_walk, color: _controller.isWalking ? Colors.green.shade700 : Colors.grey.shade300),
        SizedBox(width: screenWidth * 0.08),
        Icon(Icons.directions_bike, color: _controller.isCycling ? Colors.green.shade700 : Colors.grey.shade300),
        SizedBox(width: screenWidth * 0.1),
        Icon(Icons.directions_car_filled_outlined, color: _controller.isDriving ? Colors.green.shade700 : Colors.grey.shade300),
      ],
    );
  }

  Widget _buildSpeedSlider() {
    return Slider(
      value: _controller.speed,
      min: 0.5,
      max: 50,
      divisions: 198,
      label: _controller.speed.toStringAsFixed(2),
      onChanged: (newSpeed) {
        setState(() {
          _controller.updateSpeed(newSpeed);
          widget.onSpeedChanged(newSpeed);
        });
      },
    );
  }

  Widget _buildInaccuracyRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Inaccuracy: ${_controller.inaccuracy.toStringAsFixed(2)} m'),
        GestureDetector(
          onTap: () {},
          child: const Text('Tap to edit',
              style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  Widget _buildInaccuracySlider() {
    return Slider(
      value: _controller.inaccuracy,
      min: 0.0,
      max: _controller.speed,
      divisions: (_controller.speed * 4).toInt(),
      label: _controller.inaccuracy.toStringAsFixed(2),
      onChanged: (newInaccuracy) {
        setState(() {
          _controller.updateInaccuracy(newInaccuracy);
          widget.onInaccuracyChanged(newInaccuracy);
        });
      },
    );
  }

  Widget _buildLoopModeSection() {
    return Column(
      children: [
        const Row(
          children: [
            Text('Loop mode'),
          ],
        ),
        ListTile(
          title: const Text('Stop'),
          leading: Radio<String>(
            value: 'stop',
            groupValue: _controller.selectedLoopMode,
            onChanged: (String? newValue) {
              setState(() {
                _controller.updateLoopMode(newValue);
                widget.onLoopModeChanged(newValue);
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Reverse'),
          leading: Radio<String>(
            value: 'reverse',
            groupValue: _controller.selectedLoopMode,
            onChanged: (String? newValue) {
              setState(() {
                _controller.updateLoopMode(newValue);
                widget.onLoopModeChanged(newValue);
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Restart'),
          leading: Radio<String>(
            value: 'restart',
            groupValue: _controller.selectedLoopMode,
            onChanged: (String? newValue) {
              setState(() {
                _controller.updateLoopMode(newValue);
                widget.onLoopModeChanged(newValue);
              });
            },
          ),
        ),
      ],
    );
  }
}

void showRouteSettings(BuildContext context, RouteController route) {
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
