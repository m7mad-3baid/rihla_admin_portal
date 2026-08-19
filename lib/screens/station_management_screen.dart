import 'package:flutter/material.dart';

import '../helpers/admin_formatters.dart';
import '../themes/admin_theme.dart';
import '../widgets/admin_card.dart';

class StationManagementScreen extends StatelessWidget {
  const StationManagementScreen({
    super.key,
    required this.selectedLine,
    required this.managedStations,
    required this.newStationController,
    required this.latitudeController,
    required this.longitudeController,
    required this.onLineSelected,
    required this.onEditStation,
    required this.onDeleteStation,
    required this.onAddStation,
  });

  final String selectedLine;
  final List<dynamic> managedStations;
  final TextEditingController newStationController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final ValueChanged<String> onLineSelected;
  final ValueChanged<Map<String, dynamic>> onEditStation;
  final ValueChanged<String> onDeleteStation;
  final VoidCallback onAddStation;

  Widget lineButton(String lineName, Color color) {
    bool isSelected = selectedLine == lineName;

    return ElevatedButton(
      onPressed: () => onLineSelected(lineName),
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
  Widget build(BuildContext context) {
    List<dynamic> stations = managedStations
        .where((station) => station['line'].toString() == selectedLine)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: SizedBox(
          width: 900,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    ...List.generate(stations.length, (index) {
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
                                  stations[index]['name'].toString(),
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ),
                              IconButton(
                                onPressed: () => onEditStation(
                                  Map<String, dynamic>.from(stations[index]),
                                ),
                                icon: const Icon(Icons.edit_outlined),
                                color: AdminTheme.teal,
                              ),
                              IconButton(
                                onPressed: () => onDeleteStation(
                                  stations[index]['id'].toString(),
                                ),
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                              ),
                            ],
                          ),
                          if (index != stations.length - 1) const Divider(),
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
                      controller: newStationController,
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
                            keyboardType: const TextInputType.numberWithOptions(
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
                            keyboardType: const TextInputType.numberWithOptions(
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
                        onPressed: onAddStation,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Station'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.teal,
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
    );
  }
}
