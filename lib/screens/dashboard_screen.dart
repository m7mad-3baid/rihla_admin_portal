import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../themes/admin_theme.dart';
import '../widgets/admin_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.onUserSelected});

  final Function(Map<String, dynamic>) onUserSelected;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  String search = '';

  String metroLine = 'Red';
  String metroStatus = 'Normal';
  Map<String, String> metroStatuses = {};

  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUsers();
    loadMetroStatuses();
  }

  Future<void> loadUsers() async {
    try {
      final data = await ApiService.getUsers();
      if (!mounted) return;

      setState(() {
        if (data['success'] == true) {
          users = List<dynamic>.from(data['data']);
        }
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
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

  List<dynamic> get filteredUsers {
    if (search.isEmpty) return users;

    return users.where((user) {
      String name = user['name'].toString().toLowerCase();
      String email = user['email'].toString().toLowerCase();
      String studentId = user['student_id'].toString().toLowerCase();

      return name.contains(search) ||
          email.contains(search) ||
          studentId.contains(search);
    }).toList();
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (value) {
              setState(() => search = value.trim().toLowerCase());
            },
            decoration: InputDecoration(
              hintText: 'Search by name, email, or user ID',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 22),
          AdminCard(
            title: 'All Users',
            subtitle: 'Registered Rihla users',
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : filteredUsers.isEmpty
                ? const Text('No users found.')
                : Column(
                    children: [
                      const Row(
                        children: [
                          Expanded(flex: 3, child: Text('User')),
                          Expanded(flex: 3, child: Text('Email')),
                          Expanded(flex: 2, child: Text('Status')),
                          Expanded(child: Text('Stations')),
                          Expanded(child: Text('Tickets')),
                        ],
                      ),
                      const Divider(),
                      ...filteredUsers.take(5).map((user) {
                        bool isStudent = user['is_student'].toString() == '1';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextButton(
                                  onPressed: () {
                                    widget.onUserSelected(
                                      Map<String, dynamic>.from(user),
                                    );
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(user['name'].toString()),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(user['email'].toString()),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(isStudent ? 'Student' : 'Regular'),
                              ),
                              Expanded(
                                child: Text(
                                  user['saved_stations_count'].toString(),
                                ),
                              ),
                              Expanded(
                                child: Text(user['tickets_count'].toString()),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
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
                            metroStatus = metroStatuses[metroLine] ?? 'Normal';
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
                            backgroundColor: AdminTheme.teal,
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
                            backgroundColor: AdminTheme.teal,
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
    );
  }
}
