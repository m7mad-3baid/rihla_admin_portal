import 'package:flutter/material.dart';

import '../themes/admin_theme.dart';

typedef SaveUserCallback =
    Future<void> Function({
      required int id,
      required String name,
      required String email,
      required String password,
      required bool isStudent,
    });

class EditUserDialog extends StatefulWidget {
  const EditUserDialog({super.key, required this.user, required this.onSave});

  final Map<String, dynamic>? user;
  final SaveUserCallback onSave;

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  final TextEditingController passwordController = TextEditingController();
  late bool isStudent;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.user?['name'].toString() ?? '',
    );
    emailController = TextEditingController(
      text: widget.user?['email'].toString() ?? '',
    );
    isStudent = widget.user?['is_student'].toString() == '1';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit User Information'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                DropdownMenuItem(value: 'Student', child: Text('Student')),
                DropdownMenuItem(value: 'Regular', child: Text('Regular')),
              ],
              onChanged: (value) {
                setState(() {
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
          onPressed: () async {
            int id = int.tryParse(widget.user?['id'].toString() ?? '') ?? 0;
            Navigator.pop(context);
            await widget.onSave(
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
            backgroundColor: AdminTheme.teal,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
