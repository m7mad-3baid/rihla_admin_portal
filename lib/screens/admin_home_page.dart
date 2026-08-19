import 'package:flutter/material.dart';

import '../widgets/admin_sidebar.dart';
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
  Map<String, dynamic>? userOpenedFromDashboard;
  int usersPageVersion = 0;

  void selectPage(String page) {
    setState(() {
      selectedPage = page;
      userOpenedFromDashboard = null;
      if (page == 'Users') usersPageVersion++;
    });
  }

  void openUserFromDashboard(Map<String, dynamic> user) {
    setState(() {
      selectedPage = 'Users';
      userOpenedFromDashboard = user;
      usersPageVersion++;
    });
  }

  void signOut() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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

  Widget buildPage() {
    if (selectedPage == 'Dashboard') {
      return DashboardScreen(onUserSelected: openUserFromDashboard);
    }

    if (selectedPage == 'Users') {
      return UserManagementScreen(
        key: ValueKey(usersPageVersion),
        initialUser: userOpenedFromDashboard,
      );
    }

    if (selectedPage == 'Station Management') {
      return const StationManagementScreen();
    }

    if (selectedPage == 'Ticket Pricing') {
      return const TicketPricingScreen();
    }

    return AdminPreferencesScreen(admin: widget.admin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(
            adminName: widget.admin['name']?.toString() ?? 'Admin',
            selectedPage: selectedPage,
            onPageSelected: selectPage,
            onSignOut: signOut,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(40, 25, 40, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedPage,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        pageSubtitle(),
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: buildPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
