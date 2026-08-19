import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/admin_page_header.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/edit_station_dialog.dart';
import '../widgets/edit_user_dialog.dart';
import 'admin_preferences_screen.dart';
import 'dashboard_screen.dart';
import 'station_management_screen.dart';
import 'ticket_pricing_screen.dart';
import 'user_management_screen.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key, required this.admin});

  final Map<String, dynamic> admin;

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
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
      final data = await ApiService.getStations();
      if (data['success'] == true && mounted) {
        setState(() => managedStations = List<dynamic>.from(data['data']));
      }
    } catch (_) {}
  }

  Future<void> stationAction(Map<String, String> body) async {
    try {
      final data = await ApiService.stationAction(body);
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

  Future<void> addStation() async {
    String name = newStationController.text.trim();
    if (name.isEmpty) {
      showMessage('Enter a station name', Colors.red);
      return;
    }

    int stationCount = managedStations
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
    newStationController.clear();
    latitudeController.clear();
    longitudeController.clear();
  }

  Future<void> saveTicketPrices() async {
    try {
      final data = await ApiService.saveTicketPrices(
        twoHoursPrice: twoHoursPriceController.text,
        sevenDaysPrice: sevenDaysPriceController.text,
      );
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
      final data = await ApiService.getMetroStatuses();
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
      final data = await ApiService.getTicketPrices();
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
      final data = await ApiService.updateAdminProfile(
        id: widget.admin['id'].toString(),
        name: adminNameController.text.trim(),
        email: adminEmailController.text.trim(),
      );
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
      final data = await ApiService.changeAdminPassword(
        id: widget.admin['id'].toString(),
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );
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
      final data = await ApiService.updateMetroStatus(
        lineName: metroLine,
        status: metroStatus,
      );
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
      final data = await ApiService.getUsers();

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
      final data = await ApiService.getUserDetails(user['id'].toString());

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

  Future<void> confirmRemoveSavedStation(String stationId) async {
    final userId = selectedUser?['id']?.toString();

    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove saved station?'),
          content: const Text(
            'This station will be removed from this user’s saved stations.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
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
          selectedStations.removeWhere(
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
    } catch (error) {
      if (!mounted) return;

      showMessage('Could not connect to the server', Colors.red);
    }
  }

  Future<void> confirmRemoveUser() async {
    final userId = selectedUser?['id']?.toString();

    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove user?'),
          content: const Text(
            'The user’s information will remain in the database, but the account will be disabled.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
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
          selectedStations = [];
          selectedTickets = [];
        });

        await loadUsers();
      }

      if (!mounted) return;

      showMessage(
        data['message'] ?? 'User removed',
        data['success'] == true ? Colors.green : Colors.red,
      );
    } catch (error) {
      if (!mounted) return;

      showMessage('Could not connect to the server', Colors.red);
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
      final data = await ApiService.sendGlobalNotification(
        title: title,
        message: message,
      );

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
    showDialog(
      context: context,
      builder: (context) =>
          EditUserDialog(user: selectedUser, onSave: updateUser),
    );
  }

  void showEditStationDialog(Map<String, dynamic> station) {
    showDialog(
      context: context,
      builder: (context) => EditStationDialog(
        station: station,
        onSave: (name) => stationAction({
          'action': 'update',
          'id': station['id'].toString(),
          'name': name,
          'position': station['position'].toString(),
        }),
      ),
    );
  }

  void showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void selectPage(String page) {
    setState(() {
      selectedPage = page;
      showingUserDetails = false;
    });
  }

  void signOut() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Widget buildPageContent() {
    if (selectedPage == 'Dashboard') {
      return DashboardScreen(
        filteredUsers: filteredUsers,
        isUsersLoading: isUsersLoading,
        onSearchChanged: (value) => setState(() => userSearch = value),
        onUserSelected: loadUserDetails,
        metroLine: metroLine,
        metroStatus: metroStatus,
        onMetroLineChanged: (value) => setState(() {
          metroLine = value;
          metroStatus = metroStatuses[metroLine] ?? 'Normal';
        }),
        onMetroStatusChanged: (value) => setState(() => metroStatus = value),
        onUpdateMetroStatus: updateMetroStatus,
        globalTitleController: globalTitleController,
        globalMessageController: globalMessageController,
        onSendNotification: sendNotification,
      );
    }

    if (selectedPage == 'Users') {
      return UserManagementScreen(
        showingUserDetails: showingUserDetails,
        isUsersLoading: isUsersLoading,
        usersError: usersError,
        filteredUsers: filteredUsers,
        onSearchChanged: (value) => setState(() => userSearch = value),
        onUserSelected: loadUserDetails,
        selectedUser: selectedUser,
        selectedStations: selectedStations,
        selectedTickets: selectedTickets,
        isUserDetailsLoading: isUserDetailsLoading,
        userDetailsError: userDetailsError,
        onBackToUsers: () => setState(() => showingUserDetails = false),
        onEditUser: showEditUserDialog,
        onRemoveUser: confirmRemoveUser,
        onRemoveSavedStation: confirmRemoveSavedStation,
      );
    }

    if (selectedPage == 'Station Management') {
      return StationManagementScreen(
        selectedLine: selectedLine,
        managedStations: managedStations,
        newStationController: newStationController,
        latitudeController: latitudeController,
        longitudeController: longitudeController,
        onLineSelected: (value) => setState(() => selectedLine = value),
        onEditStation: showEditStationDialog,
        onDeleteStation: confirmDeleteStation,
        onAddStation: addStation,
      );
    }

    if (selectedPage == 'Ticket Pricing') {
      return TicketPricingScreen(
        twoHoursPriceController: twoHoursPriceController,
        sevenDaysPriceController: sevenDaysPriceController,
        onSavePrices: saveTicketPrices,
      );
    }

    return AdminPreferencesScreen(
      admin: widget.admin,
      adminNameController: adminNameController,
      adminEmailController: adminEmailController,
      currentPasswordController: currentPasswordController,
      newPasswordController: newPasswordController,
      confirmPasswordController: confirmPasswordController,
      onUpdateAdminProfile: updateAdminProfile,
      onChangeAdminPassword: changeAdminPassword,
    );
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
          AdminSidebar(
            selectedPage: selectedPage,
            onPageSelected: selectPage,
            onSignOut: signOut,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminPageHeader(selectedPage: selectedPage),
                Expanded(child: buildPageContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
