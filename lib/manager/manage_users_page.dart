import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hotel_app_bar.dart';
import '../models/app_user.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final ApiService apiService = ApiService();
  late Future<List<AppUser>> users;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    users = apiService.getAllUsers();
  }

  Future<void> _refresh() async {
    setState(() {
      users = apiService.getAllUsers();
    });
    await users;
  }

  Future<void> _openResetPasswordDialog(AppUser user) async {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscure = true;
    String? errorText;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Reset Password"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${user.fullName} · ${user.email}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setDialogState(() => obscure = !obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscure,
                    decoration: const InputDecoration(labelText: "Confirm Password"),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(errorText!, style: const TextStyle(color: AppColors.priorityHigh, fontSize: 12)),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (newPasswordController.text.length < 6) {
                      setDialogState(() => errorText = "Password must be at least 6 characters.");
                      return;
                    }
                    if (newPasswordController.text != confirmPasswordController.text) {
                      setDialogState(() => errorText = "Passwords don't match.");
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  child: const Text("Reset Password"),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    try {
      final success = await apiService.changeUserPassword(user.userId, newPasswordController.text);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Password reset for ${user.fullName}" : "Failed to reset password"),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HotelAppBar(title: "Manage Users"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search users...",
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<AppUser>>(
                future: users,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return ListView(children: [Center(child: Text(snapshot.error.toString()))]);
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return ListView(children: [Center(child: Text("No users found"))]);
                  }

                  final userList = snapshot.data!
                      .where((u) =>
                          u.fullName.toLowerCase().contains(searchQuery) ||
                          u.email.toLowerCase().contains(searchQuery))
                      .toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      final user = userList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(user.fullName, style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text("${user.email} · ${user.roleName}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.lock_reset_outlined, color: AppColors.navy),
                            tooltip: "Reset Password",
                            onPressed: () => _openResetPasswordDialog(user),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}