import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../technician/technician_home_page.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ApiService apiService = ApiService();
  Future<void> checkLogin() async {
  final prefs = await SharedPreferences.getInstance();
  print("Stored role: ${prefs.getString("role")}");
  final role = prefs.getString("role");
  final userId = prefs.getInt("userId");

  if (role == null) return;

  if (role.toLowerCase() == "employee") {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
    );
  } else if (role.toLowerCase().contains("technician")) {
   Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => TechnicianHomePage(
     technicianId: userId!,
    ),
  ),
);
  }
}
  @override
void initState() {
  super.initState();
  checkLogin();
}
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hotel IT Login"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 40),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
               onPressed: isLoading
    ? null
    : () async {

        setState(() {
          isLoading = true;
        });

        final login = await apiService.login(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
        if (login == null) {
          setState(() {
            isLoading = false;
          });

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
        await prefs.reload();
        print("Saved role after reload: ${prefs.getString("role")}");

        setState(() {
          isLoading = false;
        });


        if (login.role.toLowerCase() == "employee") {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomePage(),
            ),
          );

        }
        else if (login.role.toLowerCase().contains ("it technician")) {

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
             builder: (_) => TechnicianHomePage(
  technicianId: login.userId,
),
            ),
          );

        }
        else {

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Role: ${login.role} not implemented yet"),
            ),
          );

        }
      },
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}