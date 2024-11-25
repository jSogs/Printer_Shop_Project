import 'package:flutter/material.dart';
import '/pages/login.dart';
import './edit_printers.dart';
import './edit_users.dart';
import './view_orders.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text(
        'Home',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 2.0,
      leading: null
    );
  }

  Widget _body(){
    return Column(
        children: [
          // Greeting Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Hi, Admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Tabs Section
          Expanded(
            child: Column(
              children: [
                // Edit Printers Tab
                ListTile(
                  leading: const Icon(Icons.print_rounded),
                  title: const Text('Edit printer lineup'),
                  onTap: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const EditPrinters()),
                    ); // Navigate to EditPrinters page
                  },
                ),
                const Divider(), // Add a divider between the tabs

                // Edit Users Tab
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Edit Users'),
                  onTap: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const EditUsers()),
                    ); // Navigate to EditUsers page
                  },
                ),

                const Divider(), // Add a divider between the tabs

                // View Orders Tab
                ListTile(
                  leading: const Icon(Icons.receipt),
                  title: const Text('View All Orders'),
                  onTap: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const ViewOrders()),
                    ); // Navigate to ViewOrders page
                  },
                ),

                const Divider(),
                
                // Sign Out Tab
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign Out'),
                  onTap: (){Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  }, // Call the existing sign-out function
                ),
              ],
            ),
          ),
        ],
      );
  }
}