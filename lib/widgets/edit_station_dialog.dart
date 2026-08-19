import 'package:flutter/material.dart';

import '../themes/admin_theme.dart';

class EditStationDialog extends StatefulWidget {
  const EditStationDialog({
    super.key,
    required this.station,
    required this.onSave,
  });

  final Map<String, dynamic> station;
  final Future<void> Function(String name) onSave;

  @override
  State<EditStationDialog> createState() => _EditStationDialogState();
}

class _EditStationDialogState extends State<EditStationDialog> {
  late final TextEditingController stationController;

  @override
  void initState() {
    super.initState();
    stationController = TextEditingController(
      text: widget.station['name'].toString(),
    );
  }

  @override
  void dispose() {
    stationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Station Name'),
      content: TextField(
        controller: stationController,
        decoration: const InputDecoration(
          labelText: 'Station Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await widget.onSave(stationController.text.trim());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminTheme.teal,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
