import 'package:flutter/material.dart';

import '../helpers/admin_formatters.dart';
import '../services/api_service.dart';
import '../widgets/admin_card.dart';

class StationManagementScreen extends StatefulWidget {
  const StationManagementScreen({super.key});

  @override
  State<StationManagementScreen> createState() =>
      _StationManagementScreenState();
}

class _StationManagementScreenState extends State<StationManagementScreen> {
  String selectedLine = 'Red';
  List<dynamic> stations = [];

  final TextEditingController stationController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStations();
  }

  Future<void> loadStations() async {
    try {
      final data = await ApiService.getStations();
      if (!mounted) return;

      if (data['success'] == true) {
        setState(() => stations = List<dynamic>.from(data['data']));
      }
    } catch (_) {}
  }

  Future<void> stationAction(Map<String, String> body) async {
    try {
      final data = await ApiService.stationAction(body);
      if (!mounted) return;

      if (data['success'] == true) {
        await loadStations();
        if (!mounted) return;
        showMessage('Station updated successfully', Colors.green);
      } else {
        showMessage(data['message'] ?? 'Could not update station', Colors.red);
      }
    } catch (_) {
      if (!mounted) return;
      showMessage('Could not connect to the server', Colors.red);
    }
  }

  Future<void> addStation() async {
    String name = stationController.text.trim();

    if (name.isEmpty) {
      showMessage('Enter a station name', Colors.red);
      return;
    }

    int stationCount = stations
        .where((station) => station['line'].toString() == selectedLine)
        .length;

    await stationAction({
      'action': 'add',
      'name': name,
      'line': selectedLine,
      'position': (stationCount + 1).toString(),
      'latitude': latitudeController.text.trim(),
      'longitude': longitudeController.text.trim(),
    });

    stationController.clear();
    latitudeController.clear();
    longitudeController.clear();
  }

  Future<void> editStation(Map<String, dynamic> station) async {
    final controller = TextEditingController(text: station['name'].toString());

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Station Name'),
          content: TextField(
            controller: controller,
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
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005E66),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName == null) return;

    await stationAction({
      'action': 'update',
      'id': station['id'].toString(),
      'name': newName,
      'position': station['position'].toString(),
    });
  }

  Future<void> deleteStation(String stationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete station?'),
          content: const Text(
            'This will also remove the station from saved stations.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await stationAction({'action': 'delete', 'id': stationId});
    }
  }

  void showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Widget lineButton(String lineName, Color color) {
    bool isSelected = selectedLine == lineName;

    return ElevatedButton(
      onPressed: () => setState(() => selectedLine = lineName),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.white,
        foregroundColor: isSelected ? Colors.white : color,
        elevation: 0,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      child: Text(
        lineName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  void dispose() {
    stationController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> lineStations = stations
        .where((station) => station['line'].toString() == selectedLine)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Station Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: SizedBox(
            width: 900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add, edit, or remove stations on each metro line.',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    lineButton('Red', Colors.red),
                    const SizedBox(width: 12),
                    lineButton('Green', Colors.green),
                    const SizedBox(width: 12),
                    lineButton('Blue', Colors.blue),
                  ],
                ),
                const SizedBox(height: 24),
                AdminCard(
                  title: '$selectedLine Stations',
                  subtitle: 'Add, edit, or remove stations on this metro line.',
                  child: Column(
                    children: [
                      ...List.generate(lineStations.length, (index) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: metroLineColor(
                                    selectedLine,
                                  ).withOpacity(0.15),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: metroLineColor(selectedLine),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    lineStations[index]['name'].toString(),
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    editStation(
                                      Map<String, dynamic>.from(
                                        lineStations[index],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                  color: const Color(0xFF005E66),
                                ),
                                IconButton(
                                  onPressed: () {
                                    deleteStation(
                                      lineStations[index]['id'].toString(),
                                    );
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                            if (index != lineStations.length - 1)
                              const Divider(),
                          ],
                        );
                      }),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ADD STATION',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: stationController,
                        decoration: const InputDecoration(
                          hintText: 'Station name, e.g. Burri Junction',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: latitudeController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                hintText: 'Latitude (optional)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: longitudeController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                hintText: 'Longitude (optional)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: addStation,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Station'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005E66),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
