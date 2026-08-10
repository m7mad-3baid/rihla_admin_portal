import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const RihlaAdminApp());
}

class RihlaAdminApp extends StatelessWidget {
  const RihlaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rihla Admin',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F8F8),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// ===================== LOGIN PAGE =====================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color teal = Color(0xFF005E66);
  static const Color gold = Color(0xFF7C5700);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost/Rihla_BackEnd/api/admin_login.php'),
        body: {
          'email': emailController.text.trim(),
          'password': passwordController.text,
        },
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AdminHomePage(admin: Map<String, dynamic>.from(data['data'])),
          ),
        );
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Login failed';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Could not connect to the server';
      });
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: 460,
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: teal,
                    child: Icon(
                      Icons.train_outlined,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Rihla Admin',
                    style: TextStyle(
                      color: teal,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(width: 130, height: 3, color: gold),
                  const SizedBox(height: 14),
                  const Text(
                    'Metro operations management portal',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 32),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Admin Email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'admin@rihla.sd',
                      filled: true,
                      fillColor: Color(0xFFF7F8F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    onSubmitted: (value) {
                      login();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter your password',
                      filled: true,
                      fillColor: Color(0xFFF7F8F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== ADMIN HOME =====================

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key, required this.admin});

  final Map<String, dynamic> admin;

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final Color teal = const Color(0xFF005E66);
  final Color gold = const Color(0xFF7C5700);

  String selectedPage = 'Dashboard';
  String selectedLine = 'Red';
  bool showingUserDetails = false;
  List<dynamic> managedStations = [];
  final TextEditingController newStationController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController twoHoursPriceController = TextEditingController(
    text: '200',
  );
  final TextEditingController sevenDaysPriceController = TextEditingController(
    text: '2000',
  );

  List<dynamic> users = [];
  bool isUsersLoading = true;
  String usersError = '';
  String userSearch = '';

  Map<String, dynamic>? selectedUser;
  List<dynamic> selectedStations = [];
  List<dynamic> selectedTickets = [];
  bool isUserDetailsLoading = false;
  String userDetailsError = '';

  final TextEditingController globalTitleController = TextEditingController();
  final TextEditingController globalMessageController = TextEditingController();
  final TextEditingController adminNameController = TextEditingController();
  final TextEditingController adminEmailController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String metroLine = 'Red';
  String metroStatus = 'Normal';
  Map<String, String> metroStatuses = {};

  @override
  void initState() {
    super.initState();
    loadUsers();
    loadStations();
    loadTicketPrices();
    loadMetroStatuses();
    adminNameController.text = widget.admin['name']?.toString() ?? '';
    adminEmailController.text = widget.admin['email']?.toString() ?? '';
  }

  Future<void> loadStations() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost/Rihla_BackEnd/api/admin_stations.php?action=list',
        ),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && mounted) {
        setState(() => managedStations = List<dynamic>.from(data['data']));
      }
    } catch (_) {}
  }

  Future<void> stationAction(Map<String, String> body) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/Rihla_BackEnd/api/admin_stations.php'),
        body: body,
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        await loadStations();
        showMessage('Station updated successfully', Colors.green);
      } else {
        showMessage(data['message'] ?? 'Could not update station', Colors.red);
      }
    } catch (_) {
      showMessage('Could not connect to the server', Colors.red);
    }
  }

  Future<void> confirmDeleteStation(String stationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
    if (confirmed == true) {
      await stationAction({'action': 'delete', 'id': stationId});
    }
  }

  Future<void> saveTicketPrices() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/Rihla_BackEnd/api/admin_ticket_prices.php'),
        body: {
          'two_hours_price': twoHoursPriceController.text,
          'seven_days_price': sevenDaysPriceController.text,
        },
      );
      final data = jsonDecode(response.body);
      showMessage(
        data['message'] ??
            (data['success'] == true
                ? 'Ticket prices updated'
                : 'Could not update prices'),
        data['success'] == true ? Colors.green : Colors.red,
      );
    } catch (_) {
      showMessage('Could not connect to the server', Colors.red);
    }
  }

  Future<void> loadMetroStatuses() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/Rihla_BackEnd/api/get_metroStatus.php'),
      );
      final data = jsonDecode(response.body) as List<dynamic>;
      if (mounted) {
        setState(() {
          metroStatuses = {
            for (final item in data)
              item['line_name'].toString(): item['status'].toString(),
          };
          metroStatus = metroStatuses[metroLine] ?? 'Normal';
        });
      }
    } catch (_) {}
  }

  Future<void> loadTicketPrices() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/Rihla_BackEnd/api/admin_ticket_prices.php'),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        for (final ticket in data['data']) {
          if (ticket['ticket_name'] == '2-Hours Ticket') {
            twoHoursPriceController.text = ticket['price'].toString();
          }
          if (ticket['ticket_name'] == '7-Days Ticket') {
            sevenDaysPriceController.text = ticket['price'].toString();
          }
        }
      }
    } catch (_) {}
  }

  Future<void> updateAdminProfile() async {
    try {
      final response = await http.post(
        Uri.parse(
          'http://localhost/Rihla_BackEnd/api/admin_update_profile.php',
        ),
        body: {
          'id': widget.admin['id'].toString(),
          'name': adminNameController.text.trim(),
          'email': adminEmailController.text.trim(),
        },
      );
      final data = jsonDecode(response.body);
      showMessage(
        data['message'] ?? 'Profile updated',
        data['success'] == true ? Colors.green : Colors.red,
      );
    } catch (_) {
      showMessage('Could not connect to the server', Colors.red);
    }
  }

  Future<void> changeAdminPassword() async {
    if (newPasswordController.text.isEmpty ||
        newPasswordController.text != confirmPasswordController.text) {
      showMessage('Enter matching new passwords', Colors.red);
      return;
    }
    try {
      final response = await http.post(
        Uri.parse(
          'http://localhost/Rihla_BackEnd/api/admin_change_password.php',
        ),
        body: {
          'id': widget.admin['id'].toString(),
          'current_password': currentPasswordController.text,
          'new_password': newPasswordController.text,
        },
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      }
      showMessage(
        data['message'] ?? 'Password updated',
        data['success'] == true ? Colors.green : Colors.red,
      );
    } catch (_) {
      showMessage('Could not connect to the server', Colors.red);
    }
  }

  Future<void> updateMetroStatus() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/Rihla_BackEnd/api/update_metroStatus.php'),
        body: {'line_name': metroLine, 'status': metroStatus},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && mounted) {
        setState(() => metroStatuses[metroLine] = metroStatus);
      }
      showMessage(
        data['message'] ?? 'Status updated',
        data['success'] == true ? Colors.green : Colors.red,
      );
    } catch (_) {
      showMessage('Could not connect to the server', Colors.red);
    }
  }

  Future<void> loadUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/Rihla_BackEnd/api/getUsers.php'),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          users = List<dynamic>.from(data['data']);
          isUsersLoading = false;
        });
      } else {
        setState(() {
          usersError = data['message'] ?? 'Could not load users';
          isUsersLoading = false;
        });
      }
    } catch (error) {
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
      isUserDetailsLoading = true;
      userDetailsError = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost/Rihla_BackEnd/api/admin_get_user_details.php?user_id=${user['id']}',
        ),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          selectedUser = Map<String, dynamic>.from(data['data']['user']);
          selectedStations = List<dynamic>.from(data['data']['stations']);
          selectedTickets = List<dynamic>.from(data['data']['tickets']);
          isUserDetailsLoading = false;
        });
      } else {
        setState(() {
          userDetailsError = data['message'] ?? 'Could not load user details';
          isUserDetailsLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        userDetailsError = 'Could not connect to the server';
        isUserDetailsLoading = false;
      });
    }
  }

  Future<void> sendNotification() async {
    String title = globalTitleController.text.trim();
    String message = globalMessageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      showMessage('Enter both title and message', Colors.red);
      return;
    }

    try {
      Map<String, String> body = {'title': title, 'message': message};

      final response = await http.post(
        Uri.parse('http://localhost/Rihla_BackEnd/api/add_notifications.php'),
        body: body,
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        globalTitleController.clear();
        globalMessageController.clear();

        showMessage('Notification sent successfully', Colors.green);
      } else {
        showMessage(
          data['message'] ?? 'Could not send notification',
          Colors.red,
        );
      }
    } catch (error) {
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
    globalTitleController.dispose();
    globalMessageController.dispose();
    newStationController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    twoHoursPriceController.dispose();
    sevenDaysPriceController.dispose();
    adminNameController.dispose();
    adminEmailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          buildSidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildPageHeader(),
                Expanded(child: buildPageContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSidebar() {
    return Container(
      width: 240,
      color: teal,
      child: Column(
        children: [
          Container(
            height: 105,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFF317780),
                  child: Icon(Icons.train_outlined, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rihla',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ADMIN',
                      style: TextStyle(
                        color: gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          sidebarItem(Icons.dashboard_outlined, 'Dashboard'),
          sidebarItem(Icons.people_outline, 'Users'),
          sidebarItem(Icons.location_on_outlined, 'Station Management'),
          sidebarItem(Icons.confirmation_number_outlined, 'Ticket Pricing'),
          sidebarItem(Icons.settings_outlined, 'Preferences'),
          const Spacer(),
          const Divider(color: Colors.white24, height: 1),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF317780),
                  child: Text(
                    'MK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mohammed Khalil',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Super Admin',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.white70),
            label: const Text(
              'Sign out',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget sidebarItem(IconData icon, String title) {
    bool isSelected = selectedPage == title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: isSelected,
        selectedTileColor: const Color(0xFF317780),
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          setState(() {
            selectedPage = title;
            showingUserDetails = false;
          });
        },
      ),
    );
  }

  Widget buildPageHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(40, 25, 40, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedPage,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            pageSubtitle(),
            style: const TextStyle(color: Colors.blueGrey, fontSize: 15),
          ),
        ],
      ),
    );
  }

  String pageSubtitle() {
    if (selectedPage == 'Dashboard') {
      return 'Manage Rihla users, notifications, and metro operations.';
    }

    if (selectedPage == 'Users') {
      return 'View and manage registered Rihla users.';
    }

    if (selectedPage == 'Station Management') {
      return 'Add, edit, or remove stations on each metro line.';
    }

    if (selectedPage == 'Ticket Pricing') {
      return 'Manage the prices of available Rihla tickets.';
    }

    return 'Manage your administrator account and password.';
  }

  Widget buildPageContent() {
    if (selectedPage == 'Dashboard') {
      return buildDashboardPage();
    }

    if (selectedPage == 'Users') {
      if (showingUserDetails) {
        return buildUserDetailsPage();
      }

      return buildUsersPage();
    }

    if (selectedPage == 'Station Management') {
      return buildStationManagementPage();
    }

    if (selectedPage == 'Ticket Pricing') {
      return buildTicketPricingPage();
    }

    return buildPreferencesPage();
  }

  // ===================== DASHBOARD =====================

  Widget buildDashboardPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (value) =>
                setState(() => userSearch = value.trim().toLowerCase()),
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
          dashboardCard(
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
                                  onPressed: () => loadUserDetails(
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

  Widget buildMetroStatusCard() {
    return dashboardCard(
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
            onChanged: (value) => setState(() {
              metroLine = value!;
              metroStatus = metroStatuses[metroLine] ?? 'Normal';
            }),
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
            onChanged: (value) => setState(() => metroStatus = value!),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: updateMetroStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: teal,
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
    return dashboardCard(
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
              onPressed: () {
                sendNotification();
              },
              icon: const Icon(Icons.send),
              label: const Text('Send Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: teal,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== USERS PAGE =====================

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
                    setState(() => userSearch = value.trim().toLowerCase()),
                decoration: InputDecoration(
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
                  color: isStudent ? gold : Colors.blueGrey,
                ),
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(balance)),
          Expanded(child: Text(stations)),
          Expanded(child: Text(tickets)),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                loadUserDetails(user);
              },
              child: const Text('View'),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== USER DETAILS =====================

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
                onPressed: () {
                  setState(() {
                    showingUserDetails = false;
                  });
                },
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
                                color: isStudent ? gold : Colors.blueGrey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: showEditUserDialog,
                            child: const Text('Edit User'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              dashboardCard(
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
                                  color: lineColor(line),
                                ),
                                title: Text(station['name'].toString()),
                                subtitle: Text(line),
                              ),
                              const Divider(),
                            ],
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 20),
              dashboardCard(
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

  // ===================== USER EDIT DIALOG =====================

  Future<void> updateUser({
    required int id,
    required String name,
    required String email,
    required String password,
    required bool isStudent,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/Rihla_BackEnd/api/admin_update_user.php'),
        body: {
          'id': id.toString(),
          'name': name,
          'email': email,
          'password': password,
          'is_student': isStudent ? '1' : '0',
        },
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        await loadUsers();
        await loadUserDetails({'id': id});
        showMessage('User updated successfully', Colors.green);
      } else {
        showMessage(data['message'] ?? 'Could not update user', Colors.red);
      }
    } catch (error) {
      showMessage('Could not connect to the server', Colors.red);
    }
  }

  List<dynamic> get filteredUsers {
    if (userSearch.isEmpty) return users;
    return users.where((user) {
      String name = user['name'].toString().toLowerCase();
      String email = user['email'].toString().toLowerCase();
      String studentId = user['student_id'].toString().toLowerCase();
      return name.contains(userSearch) ||
          email.contains(userSearch) ||
          studentId.contains(userSearch);
    }).toList();
  }

  void showEditUserDialog() {
    TextEditingController nameController = TextEditingController(
      text: selectedUser?['name'].toString() ?? '',
    );

    TextEditingController emailController = TextEditingController(
      text: selectedUser?['email'].toString() ?? '',
    );

    bool isStudent = selectedUser?['is_student'].toString() == '1';
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
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
                    decoration: InputDecoration(
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
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  int id =
                      int.tryParse(selectedUser?['id'].toString() ?? '') ?? 0;
                  Navigator.pop(dialogContext);
                  await updateUser(
                    id: id,
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    password: passwordController.text,
                    isStudent: isStudent,
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===================== STATION MANAGEMENT =====================

  Widget buildStationManagementPage() {
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
              dashboardCard(
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
                                backgroundColor: lineColor(
                                  selectedLine,
                                ).withOpacity(0.15),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: lineColor(selectedLine),
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
                                onPressed: () {
                                  showEditStationDialog(stations[index]);
                                },
                                icon: const Icon(Icons.edit_outlined),
                                color: teal,
                              ),
                              IconButton(
                                onPressed: () => confirmDeleteStation(
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
                        onPressed: () async {
                          String name = newStationController.text.trim();
                          if (name.isEmpty) {
                            showMessage('Enter a station name', Colors.red);
                            return;
                          }
                          await stationAction({
                            'action': 'add',
                            'name': name,
                            'line': selectedLine,
                            'position': (stations.length + 1).toString(),
                            'latitude': latitudeController.text.trim(),
                            'longitude': longitudeController.text.trim(),
                          });
                          newStationController.clear();
                          latitudeController.clear();
                          longitudeController.clear();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Station'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: teal,
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

  Widget lineButton(String lineName, Color color) {
    bool isSelected = selectedLine == lineName;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedLine = lineName;
        });
      },
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

  void showEditStationDialog(Map<String, dynamic> station) {
    TextEditingController stationController = TextEditingController(
      text: station['name'].toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
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
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await stationAction({
                  'action': 'update',
                  'id': station['id'].toString(),
                  'name': stationController.text.trim(),
                  'position': station['position'].toString(),
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ===================== TICKET PRICING =====================

  Widget buildTicketPricingPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: SizedBox(
          width: 700,
          child: dashboardCard(
            title: 'Ticket Pricing',
            subtitle:
                'Set the base price for each ticket type in Sudanese Pounds.',
            child: Column(
              children: [
                pricingRow(
                  title: '2-Hours Ticket',
                  description: 'Valid for two hours after purchase.',
                  currentPrice: '200',
                  controller: twoHoursPriceController,
                ),
                const Divider(height: 32),
                pricingRow(
                  title: '7-Days Ticket',
                  description: 'Valid for seven days after purchase.',
                  currentPrice: '2000',
                  controller: sevenDaysPriceController,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: saveTicketPrices,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Prices'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget pricingRow({
    required String title,
    required String description,
    required String currentPrice,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 150,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              suffixText: 'SDG',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  // ===================== PREFERENCES =====================

  Widget buildPreferencesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: SizedBox(
        width: 600,
        child: Column(
          children: [
            dashboardCard(
              title: 'Admin Account',
              subtitle: 'Manage your administrator account information.',
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFFE1F0F2),
                        child: Text(
                          'MK',
                          style: TextStyle(
                            color: Color(0xFF005E66),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.admin['name']?.toString() ?? 'Admin',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.admin['email']?.toString() ?? '',
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                          Text(
                            'Super Admin',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: adminNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: adminEmailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: updateAdminProfile,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            dashboardCard(
              title: 'Change Password',
              subtitle: 'Use your current password to set a new password.',
              child: Column(
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: changeAdminPassword,
                      icon: const Icon(Icons.lock_reset),
                      label: const Text('Update Password'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: teal,
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
    );
  }

  // ===================== SHARED HELPERS =====================

  Widget dashboardCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }

  Color lineColor(String line) {
    String lowerLine = line.toLowerCase();

    if (lowerLine.contains('red')) {
      return Colors.red;
    }

    if (lowerLine.contains('green')) {
      return Colors.green;
    }

    return Colors.blue;
  }

  String dateOnly(String date) {
    if (date.contains(' ')) {
      return date.split(' ').first;
    }

    return date;
  }
}
