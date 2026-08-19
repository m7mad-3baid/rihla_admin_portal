import 'package:flutter/material.dart';

import '../themes/admin_theme.dart';
import '../widgets/admin_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.filteredUsers,
    required this.isUsersLoading,
    required this.onSearchChanged,
    required this.onUserSelected,
    required this.metroLine,
    required this.metroStatus,
    required this.onMetroLineChanged,
    required this.onMetroStatusChanged,
    required this.onUpdateMetroStatus,
    required this.globalTitleController,
    required this.globalMessageController,
    required this.onSendNotification,
  });

  final List<dynamic> filteredUsers;
  final bool isUsersLoading;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Map<String, dynamic>> onUserSelected;
  final String metroLine;
  final String metroStatus;
  final ValueChanged<String> onMetroLineChanged;
  final ValueChanged<String> onMetroStatusChanged;
  final VoidCallback onUpdateMetroStatus;
  final TextEditingController globalTitleController;
  final TextEditingController globalMessageController;
  final VoidCallback onSendNotification;

  Widget buildMetroStatusCard() {
    return AdminCard(
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
              DropdownMenuItem(value: 'Red', child: Text('Red Line')),
              DropdownMenuItem(value: 'Green', child: Text('Green Line')),
              DropdownMenuItem(value: 'Blue', child: Text('Blue Line')),
            ],
            onChanged: (value) => onMetroLineChanged(value!),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: metroStatus,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Normal', child: Text('Normal')),
              DropdownMenuItem(value: 'Delayed', child: Text('Delayed')),
              DropdownMenuItem(value: 'Closed', child: Text('Closed')),
            ],
            onChanged: (value) => onMetroStatusChanged(value!),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: onUpdateMetroStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update Status'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGlobalNotificationCard() {
    return AdminCard(
      title: 'Send Global Notification',
      subtitle: 'Send a message to every Rihla user.',
      child: Column(
        children: [
          TextField(
            controller: globalTitleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Service Update',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: globalMessageController,
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
              onPressed: onSendNotification,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (value) => onSearchChanged(value.trim().toLowerCase()),
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
            child: isUsersLoading
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
                                  onPressed: () => onUserSelected(
                                    Map<String, dynamic>.from(user),
                                  ),
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
              Expanded(child: buildMetroStatusCard()),
              const SizedBox(width: 22),
              Expanded(child: buildGlobalNotificationCard()),
            ],
          ),
        ],
      ),
    );
  }
}
