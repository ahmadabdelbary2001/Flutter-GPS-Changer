import 'package:flutter/material.dart';
import '../widgets/google_maps_widget.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  String _selectedTrackType = 'Fixed';

  void _onTrackTypeSelected(String value) {
    setState(() {
      _selectedTrackType = value;
      GoogleMapsWidgetState.isMoving = _selectedTrackType != 'Fixed';
    });

    print('Track type: $value');
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: _onTrackTypeSelected,
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'Fixed',
          child: Row(
            children: [
              Icon(
                _selectedTrackType == 'Fixed'
                    ? Icons.check_box_outlined
                    : Icons.check_box_outline_blank_outlined,
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
        PopupMenuItem<String>(
          value: 'Moving ',
          child: Row(
            children: [
              Icon(
                _selectedTrackType == 'Moving '
                    ? Icons.check_box_outlined
                    : Icons.check_box_outline_blank_outlined,
                color: _selectedTrackType == 'Moving '
                    ? Colors.green
                    : Colors.grey,
              ),
              const Icon(
                Icons.moving,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              const Text('Moving '),
            ],
          ),
        ),
      ],
      child: const ElevatedButton(
        onPressed: null,
        child: Text('Track type'),
      ),
    );
  }
}
