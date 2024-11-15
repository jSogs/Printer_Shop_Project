import 'package:flutter/material.dart';
import '/pages/login.dart';
import '/pages/orders.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;

  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('user_name') ?? 'User'; // Fallback to 'User'
    });
  }

  void signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all preferences or just the necessary ones
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );// Navigate to login
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          // Greeting Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Hi, ${username ?? 'User'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Tabs Section
          Expanded(
            child: Column(
              children: [
                // Orders Tab
                ListTile(
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: const Text('Orders'),
                  onTap: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const OrdersPage()),
                    ); // Navigate to OrdersPage
                  },
                ),
                const Divider(), // Add a divider between the tabs

                // Sign Out Tab
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign Out'),
                  onTap: signOut, // Call the existing sign-out function
                ),
              ],
            ),
          ),
        ],
      );
  }
}