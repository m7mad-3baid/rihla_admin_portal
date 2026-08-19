import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../themes/admin_theme.dart';
import '../widgets/admin_card.dart';

class AdminPreferencesScreen extends StatefulWidget {
  const AdminPreferencesScreen({super.key, required this.admin});

  final Map<String, dynamic> admin;

  @override
  State<AdminPreferencesScreen> createState() => _AdminPreferencesScreenState();
}

class _AdminPreferencesScreenState extends State<AdminPreferencesScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.admin['name']?.toString() ?? '';
    emailController.text = widget.admin['email']?.toString() ?? '';
  }

  Future<void> updateProfile() async {
    try {
      final data = await ApiService.updateAdminProfile(
        id: widget.admin['id'].toString(),
        name: nameController.text.trim(),
        email: emailController.text.trim(),
      );

      if (!mounted) return;

      showMessage(
        data['message'] ?? 'Profile updated',
        data['success'] == true ? Colors.green : Colors.red,
      );
    } catch (_) {
      if (!mounted) return;
      showMessage('Could not connect to the server', Colors.red);
    }
  }

  Future<void> changePassword() async {
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

      if (!mounted) return;

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
    nameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: SizedBox(
        width: 600,
        child: Column(
          children: [
            AdminCard(
              title: 'Admin Account',
              subtitle: 'Manage your administrator account information.',
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFFE1F0F2),
                        child: Icon(Icons.person, color: AdminTheme.teal),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.admin['name']?.toString() ?? 'Admin',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.admin['email']?.toString() ?? '',
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                          const Text(
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: updateProfile,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminTheme.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AdminCard(
              title: 'Change Password',
              subtitle: 'Use your current password to set a new password.',
              child: Column(
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: changePassword,
                      icon: const Icon(Icons.lock_reset),
                      label: const Text('Update Password'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminTheme.teal,
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
}
