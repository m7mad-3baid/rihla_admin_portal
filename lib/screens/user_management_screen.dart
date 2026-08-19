import 'package:flutter/material.dart';

import '../helpers/admin_formatters.dart';
import '../services/api_service.dart';
import '../widgets/admin_card.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<dynamic> users = [];
  bool isUsersLoading = true;
  String usersError = '';

  bool showingUserDetails = false;
  Map<String, dynamic>? selectedUser;
  List<dynamic> savedStations = [];
  List<dynamic> purchasedTickets = [];
  bool isDetailsLoading = false;
  String detailsError = '';

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final data = await ApiService.getUsers();
      if (!mounted) return;

      setState(() {
        if (data['success'] == true) {
          users = List<dynamic>.from(data['data']);
          usersError = '';
        } else {
          usersError = data['message'] ?? 'Could not load users';
        }
        isUsersLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        usersError = 'Could not connect to the server';
        isUsersLoading = false;
      });
    }
  }

  Future<void> loadUserDetails(Map<String, dynamic> user) async {
    setState(() {
      selectedUser = user;
      showingUserDetails = true;
      isDetailsLoading = true;
      detailsError = '';
    });

    try {
      final data = await ApiService.getUserDetails(user['id'].toString());
      if (!mounted) return;

      if (data['success'] == true) {
        setState(() {
          selectedUser = Map<String, dynamic>.from(data['data']['user']);
          savedStations = List<dynamic>.from(data['data']['stations']);
          purchasedTickets = List<dynamic>.from(data['data']['tickets']);
          isDetailsLoading = false;
        });
      } else {
        setState(() {
          detailsError = data['message'] ?? 'Could not load user details';
          isDetailsLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        detailsError = 'Could not connect to the server';
        isDetailsLoading = false;
      });
    }
  }

  Future<void> updateUser({
    required int id,
    required String name,
    required String email,
    required String password,
    required bool isStudent,
  }) async {
    try {
      final data = await ApiService.updateUser(
        id: id,
        name: name,
        email: email,
        password: password,
        isStudent: isStudent,
      );

      if (!mounted) return;

      if (data['success'] == true) {
        await loadUsers();
        await loadUserDetails({'id': id});
        if (!mounted) return;
        showMessage('User updated successfully', Colors.green);
      } else {
        showMessage(data['message'] ?? 'Could not update user', Colors.red);
      }
    } catch (_) {
      if (!mounted) return;
      showMessage('Could not connect to the server', Colors.red);
    }
  }

  Future<void> editUser() async {
    if (selectedUser == null) return;

    final nameController = TextEditingController(
      text: selectedUser!['name'].toString(),
    );
    final emailController = TextEditingController(
      text: selectedUser!['email'].toString(),
    );
    final passwordController = TextEditingController();
    bool isStudent = selectedUser!['is_student'].toString() == '1';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit User Information'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Leave empty to keep current password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: isStudent ? 'Student' : 'Regular',
                      decoration: const InputDecoration(
                        labelText: 'Student Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Student',
                          child: Text('Student'),
                        ),
                        DropdownMenuItem(
                          value: 'Regular',
                          child: Text('Regular'),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          isStudent = value == 'Student';
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    int id = int.tryParse(selectedUser!['id'].toString()) ?? 0;
                    String name = nameController.text.trim();
                    String email = emailController.text.trim();
                    String password = passwordController.text;

                    Navigator.pop(context);
                    updateUser(
                      id: id,
                      name: name,
                      email: email,
                      password: password,
                      isStudent: isStudent,
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005E66),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> removeSavedStation(String stationId) async {
    String? userId = selectedUser?['id']?.toString();
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove saved station?'),
          content: const Text(
            'This station will be removed from this user’s saved stations.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final data = await ApiService.removeSavedStation(
        userId: userId,
        stationId: stationId,
      );

      if (!mounted) return;

      if (data['success'] == true) {
        setState(() {
          savedStations.removeWhere(
            (station) => station['id'].toString() == stationId,
          );
        });
        await loadUsers();
      }

      if (!mounted) return;
      showMessage(
        data['message'] ?? 'Saved station removed',
        data['success'] == true ? Colors.green : Colors.red,
      );
    } catch (_) {
      if (!mounted) return;
      showMessage('Could not connect to the server', Colors.red);
    }
  }

  Future<void> removeUser() async {
    String? userId = selectedUser?['id']?.toString();
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove user?'),
          content: const Text(
            'The user’s information will remain in the database, but the account will be disabled.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final data = await ApiService.removeUser(userId);
      if (!mounted) return;

      if (data['success'] == true) {
        setState(() {
          showingUserDetails = false;
          selectedUser = null;
          savedStations = [];
          purchasedTickets = [];
        });
        await loadUsers();
      }

      if (!mounted) return;
      showMessage(
        data['message'] ?? 'User removed',
        data['success'] == true ? Colors.green : Colors.red,
      );
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

  Widget userRow(Map<String, dynamic> user) {
    String name = user['name'].toString();
    String email = user['email'].toString();
    String balance = '${user['balance']} SDG';
    String stationCount = user['saved_stations_count'].toString();
    String ticketCount = user['tickets_count'].toString();
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
                  color: isStudent ? const Color(0xFF7C5700) : Colors.blueGrey,
                ),
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(balance)),
          Expanded(child: Text(stationCount)),
          Expanded(child: Text(ticketCount)),
          Expanded(
            child: OutlinedButton(
              onPressed: () => loadUserDetails(user),
              child: const Text('View'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUsersList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'View and manage all registered Rihla users.',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16),
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
              else if (users.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No users found.'),
                )
              else
                ...users.map((user) {
                  return userRow(Map<String, dynamic>.from(user));
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserDetails() {
    if (isDetailsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (detailsError.isNotEmpty) {
      return Center(
        child: Text(detailsError, style: const TextStyle(color: Colors.red)),
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
                onPressed: () => setState(() => showingUserDetails = false),
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
                            color: Color(0xFF005E66),
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
                                    ? const Color(0xFF7C5700)
                                    : Colors.blueGrey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: editUser,
                            child: const Text('Edit User'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: removeUser,
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
                child: savedStations.isEmpty
                    ? const Text(
                        'This user has no saved stations.',
                        style: TextStyle(color: Colors.blueGrey),
                      )
                    : Column(
                        children: savedStations.map((station) {
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
                                  onPressed: () {
                                    removeSavedStation(
                                      station['id'].toString(),
                                    );
                                  },
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
                child: purchasedTickets.isEmpty
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
                          ...purchasedTickets.map((ticket) {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F8),
      appBar: AppBar(backgroundColor: Colors.white, title: const Text('Users')),
      body: showingUserDetails ? buildUserDetails() : buildUsersList(),
    );
  }
}
