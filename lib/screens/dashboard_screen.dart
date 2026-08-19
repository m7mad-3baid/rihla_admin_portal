import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/admin_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String metroLine = 'Red';
  String metroStatus = 'Normal';
  Map<String, String> metroStatuses = {};

  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadMetroStatuses();
  }

  Future<void> loadMetroStatuses() async {
    try {
      final data = await ApiService.getMetroStatuses();
      if (!mounted) return;

      setState(() {
        metroStatuses = {
          for (final item in data)
            item['line_name'].toString(): item['status'].toString(),
        };
        metroStatus = metroStatuses[metroLine] ?? 'Normal';
      });
    } catch (_) {}
  }

  Future<void> updateMetroStatus() async {
    try {
      final data = await ApiService.updateMetroStatus(
        lineName: metroLine,
        status: metroStatus,
      );

      if (!mounted) return;

      if (data['success'] == true) {
        setState(() => metroStatuses[metroLine] = metroStatus);
      }

      showMessage(
        data['message'] ?? 'Status updated',
        data['success'] == true ? Colors.green : Colors.red,
      );
    } catch (_) {
      if (!mounted) return;
      showMessage('Could not connect to the server', Colors.red);
    }
  }

  Future<void> sendNotification() async {
    String title = titleController.text.trim();
    String message = messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      showMessage('Enter both title and message', Colors.red);
      return;
    }

    try {
      final data = await ApiService.sendGlobalNotification(
        title: title,
        message: message,
      );

      if (!mounted) return;

      if (data['success'] == true) {
        titleController.clear();
        messageController.clear();
        showMessage('Notification sent successfully', Colors.green);
      } else {
        showMessage(
          data['message'] ?? 'Could not send notification',
          Colors.red,
        );
      }
    } catch (_) {
      if (!mounted) return;
      showMessage('Could not connect to the server', Colors.red);
    }
  }

  void showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage notifications and metro operations.',
              style: TextStyle(color: Colors.blueGrey, fontSize: 16),
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AdminCard(
                    title: 'Global Metro Status',
                    subtitle: 'Update the current status for each metro line.',
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: metroLine,
                          decoration: const InputDecoration(
                            labelText: 'Metro Line',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Red',
                              child: Text('Red Line'),
                            ),
                            DropdownMenuItem(
                              value: 'Green',
                              child: Text('Green Line'),
                            ),
                            DropdownMenuItem(
                              value: 'Blue',
                              child: Text('Blue Line'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              metroLine = value!;
                              metroStatus =
                                  metroStatuses[metroLine] ?? 'Normal';
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: metroStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Normal',
                              child: Text('Normal'),
                            ),
                            DropdownMenuItem(
                              value: 'Delayed',
                              child: Text('Delayed'),
                            ),
                            DropdownMenuItem(
                              value: 'Closed',
                              child: Text('Closed'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => metroStatus = value!);
                          },
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: updateMetroStatus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005E66),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Update Status'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: AdminCard(
                    title: 'Send Global Notification',
                    subtitle: 'Send a message to every Rihla user.',
                    child: Column(
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            hintText: 'e.g. Service Update',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: messageController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            hintText: 'Write your message here...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: sendNotification,
                            icon: const Icon(Icons.send),
                            label: const Text('Send Notification'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005E66),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
