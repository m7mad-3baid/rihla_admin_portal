import 'package:flutter/material.dart';

import '../helpers/admin_formatters.dart';
import '../themes/admin_theme.dart';
import '../widgets/admin_card.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({
    super.key,
    required this.showingUserDetails,
    required this.isUsersLoading,
    required this.usersError,
    required this.filteredUsers,
    required this.onSearchChanged,
    required this.onUserSelected,
    required this.selectedUser,
    required this.selectedStations,
    required this.selectedTickets,
    required this.isUserDetailsLoading,
    required this.userDetailsError,
    required this.onBackToUsers,
    required this.onEditUser,
    required this.onRemoveUser,
    required this.onRemoveSavedStation,
  });

  final bool showingUserDetails;
  final bool isUsersLoading;
  final String usersError;
  final List<dynamic> filteredUsers;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Map<String, dynamic>> onUserSelected;
  final Map<String, dynamic>? selectedUser;
  final List<dynamic> selectedStations;
  final List<dynamic> selectedTickets;
  final bool isUserDetailsLoading;
  final String userDetailsError;
  final VoidCallback onBackToUsers;
  final VoidCallback onEditUser;
  final VoidCallback onRemoveUser;
  final ValueChanged<String> onRemoveSavedStation;

  Widget usersPageRow(Map<String, dynamic> user) {
    String name = user['name'].toString();
    String email = user['email'].toString();
    String balance = '${user['balance']} SDG';
    String stations = user['saved_stations_count'].toString();
    String tickets = user['tickets_count'].toString();
    bool isStudent = user['is_student'].toString() == '1';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 3, child: Text(email)),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isStudent
                    ? const Color(0xFFFFF1D6)
                    : const Color(0xFFEFF1F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isStudent ? 'Student' : 'Regular',
                style: TextStyle(
                  fontSize: 12,
                  color: isStudent ? AdminTheme.gold : Colors.blueGrey,
                ),
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(balance)),
          Expanded(child: Text(stations)),
          Expanded(child: Text(tickets)),
          Expanded(
            child: OutlinedButton(
              onPressed: () => onUserSelected(user),
              child: const Text('View'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUsersPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              TextField(
                onChanged: (value) =>
                    onSearchChanged(value.trim().toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Search by name, email, or user ID',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Color(0xFFF7F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(flex: 3, child: Text('User')),
                  Expanded(flex: 3, child: Text('Email')),
                  Expanded(flex: 2, child: Text('Status')),
                  Expanded(flex: 2, child: Text('Balance')),
                  Expanded(child: Text('Stations')),
                  Expanded(child: Text('Tickets')),
                  Expanded(child: Text('Action')),
                ],
              ),
              const Divider(),
              if (isUsersLoading)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                )
              else if (usersError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    usersError,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (filteredUsers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No users found.'),
                )
              else
                ...filteredUsers.map((user) {
                  return usersPageRow(Map<String, dynamic>.from(user));
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserDetailsPage() {
    if (isUserDetailsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userDetailsError.isNotEmpty) {
      return Center(
        child: Text(
          userDetailsError,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    String userName = selectedUser?['name'].toString() ?? 'Unknown User';
    String userEmail = selectedUser?['email'].toString() ?? '';
    String userId = selectedUser?['id'].toString() ?? '';
    String userBalance = selectedUser?['balance'].toString() ?? '0';
    String studentId = selectedUser?['student_id']?.toString() ?? '';
    bool isStudent = selectedUser?['is_student'].toString() == '1';

    String initials = userName
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0])
        .take(2)
        .join()
        .toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: SizedBox(
          width: 850,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: onBackToUsers,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Users'),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFFE1F0F2),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: AdminTheme.teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: const TextStyle(color: Colors.blueGrey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'User ID: $userId | Balance: $userBalance SDG',
                            ),
                            if (studentId.isNotEmpty)
                              Text('Student ID: $studentId'),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isStudent
                                  ? const Color(0xFFFFF1D6)
                                  : const Color(0xFFEFF1F3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isStudent ? 'Student' : 'Regular',
                              style: TextStyle(
                                color: isStudent
                                    ? AdminTheme.gold
                                    : Colors.blueGrey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: onEditUser,
                            child: const Text('Edit User'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: onRemoveUser,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            icon: const Icon(Icons.person_remove_outlined),
                            label: const Text('Remove User'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AdminCard(
                title: 'Saved Stations',
                subtitle: 'Stations saved by this user.',
                child: selectedStations.isEmpty
                    ? const Text(
                        'This user has no saved stations.',
                        style: TextStyle(color: Colors.blueGrey),
                      )
                    : Column(
                        children: selectedStations.map((station) {
                          String line =
                              station['line']?.toString() ?? 'Metro Line';

                          return Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.location_on,
                                  color: metroLineColor(line),
                                ),
                                title: Text(station['name'].toString()),
                                subtitle: Text(line),
                                trailing: IconButton(
                                  tooltip: 'Remove saved station',
                                  onPressed: () => onRemoveSavedStation(
                                    station['id'].toString(),
                                  ),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              const Divider(),
                            ],
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 20),
              AdminCard(
                title: 'Purchased Tickets',
                subtitle: 'Ticket information is read-only.',
                child: selectedTickets.isEmpty
                    ? const Text(
                        'This user has not purchased any tickets.',
                        style: TextStyle(color: Colors.blueGrey),
                      )
                    : Column(
                        children: [
                          const Row(
                            children: [
                              Expanded(flex: 2, child: Text('Ticket')),
                              Expanded(child: Text('Price')),
                              Expanded(flex: 2, child: Text('Purchased')),
                              Expanded(flex: 2, child: Text('Expires')),
                              Expanded(child: Text('Status')),
                            ],
                          ),
                          const Divider(),
                          ...selectedTickets.map((ticket) {
                            String expiresAt = ticket['expires_at'].toString();
                            bool isActive =
                                DateTime.tryParse(
                                  expiresAt,
                                )?.isAfter(DateTime.now()) ??
                                false;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      ticket['ticket_name']?.toString() ??
                                          'Ticket',
                                    ),
                                  ),
                                  Expanded(
                                    child: Text('${ticket['price']} SDG'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      dateOnly(
                                        ticket['purchased_at'].toString(),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(dateOnly(expiresAt)),
                                  ),
                                  Expanded(
                                    child: Text(
                                      isActive ? 'Active' : 'Expired',
                                      style: TextStyle(
                                        color: isActive
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showingUserDetails) {
      return buildUserDetailsPage();
    }

    return buildUsersPage();
  }
}
