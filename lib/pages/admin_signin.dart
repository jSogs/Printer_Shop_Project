import 'package:flutter/material.dart';
import '/pages/admin_homepage.dart';

class AdminSignInPage extends StatefulWidget {
  const AdminSignInPage({super.key});

  @override
  _AdminSignInPageState createState() => _AdminSignInPageState();
}

class _AdminSignInPageState extends State<AdminSignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),  // AppBar for admin login page
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Username and Password fields
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Username',
              ),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
              ),
              onPressed: () {
                if (_usernameController.text == 'admin' && _passwordController.text == 'admin') {
                  // Navigate to AdminHomePage if credentials are correct
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AdminHomePage()),
                  );
                } else {
                  // Show alert if credentials are incorrect
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("Invalid admin username or password"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text(
                'Login as Admin',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}