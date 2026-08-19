import 'package:flutter/material.dart';

import '../themes/admin_theme.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.selectedPage,
    required this.onPageSelected,
    required this.onSignOut,
  });

  final String selectedPage;
  final ValueChanged<String> onPageSelected;
  final VoidCallback onSignOut;

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
        onTap: () => onPageSelected(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AdminTheme.teal,
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
                    const Text(
                      'ADMIN',
                      style: TextStyle(
                        color: AdminTheme.gold,
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
            onPressed: onSignOut,
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
}
