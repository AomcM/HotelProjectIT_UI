import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../technician/technician_home_page.dart';
import 'home_page.dart';
import 'package:flutter_app/manager/manager_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ApiService apiService = ApiService();
  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    print("Stored role: ${prefs.getString("role")}");
    final role = prefs.getString("role");
    final userId = prefs.getInt("userId");

    if (role == null) return;

    if (role.toLowerCase() == "employee") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else if (role.toLowerCase().contains("technician")) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TechnicianHomePage(technicianId: userId!),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> handleLogin() async {
    setState(() => isLoading = true);

    final login = await apiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (login == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email or password")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("userId", login.userId);
    await prefs.setString("role", login.role);
    await prefs.setString("name", login.fullName);
    await prefs.setString("email", login.email);
    await prefs.setString("departmentName", login.department);
    await prefs.reload();
    print("Saved role after reload: ${prefs.getString("role")}");

    setState(() => isLoading = false);

    if (login.role.toLowerCase() == "employee") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else if (login.role.toLowerCase().contains("it technician")) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TechnicianHomePage(technicianId: login.userId),
        ),
      );
    } else if (login.role.toLowerCase().contains("it manager")) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ManagerHomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Role: ${login.role} not implemented yet")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 12),
                Text(
                  'Hotel IT Support System',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),

                const SizedBox(height: 40),

                // Email field
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary, size: 20),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Password field
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: isLoading ? null : handleLogin,
                  child: isLoading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: AppColors.navy,
                          ),
                        )
                      : const Text('Login'),
                ),

               const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Forgot Password?"),
                          content: const Text(
                            "For security reasons, only your IT Manager can reset your password. "
                            "Please contact your IT Manager to request a password reset.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}