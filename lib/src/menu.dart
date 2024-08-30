import 'package:flutter/material.dart';
import '../provider/shared_state.dart';
import '../widgets/google_maps_widget.dart';
import 'package:provider/provider.dart';


/// This widget uses a PopupMenuButton to offer a selection between "Fixed" and "Moving" track types.
class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  String _selectedTrackType = 'Fixed';  // Default selected track type

  /// Updates the selected track type and modifies the map behavior accordingly.
  void _onTrackTypeSelected(String value) {
    setState(() {
      _selectedTrackType = value;
    });
    // Update the map's isMoving state based on the selected track type
    final sharedState = Provider.of<SharedState>(context, listen: false);
    sharedState.setIsMoving(_selectedTrackType == 'Moving');
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: _onTrackTypeSelected,  // Handle the selection of a track type
      itemBuilder: (context) => [
        // Popup menu item for "Fixed" track type
        PopupMenuItem<String>(
          value: 'Fixed',
          child: Row(
            children: [
              Icon(
                _selectedTrackType == 'Fixed'
                    ? Icons.adjust_sharp
                    : Icons.circle_outlined,
                color:
                _selectedTrackType == 'Fixed' ? Colors.green : Colors.grey,
              ),
              const Icon(
                Icons.pin_drop,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              const Text('Fixed'),
            ],
          ),
        ),
        // Popup menu item for "Moving" track type
        PopupMenuItem<String>(
          value: 'Moving',
          child: Row(
            children: [
              Icon(
                _selectedTrackType == 'Moving'
                    ? Icons.adjust_sharp
                    : Icons.circle_outlined,
                color: _selectedTrackType == 'Moving'
                    ? Colors.green
                    : Colors.grey,
              ),
              const Icon(
                Icons.moving,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              const Text('Moving'),
            ],
          ),
        ),
      ],
      child: const ElevatedButton(
        onPressed: null,  // No action needed when the button is pressed
        child: Text('Track type'),
      ),
    );
  }
}