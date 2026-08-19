import 'package:flutter/material.dart';

class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({super.key, required this.selectedPage});

  final String selectedPage;

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

  @override
  Widget build(BuildContext context) {
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
}
