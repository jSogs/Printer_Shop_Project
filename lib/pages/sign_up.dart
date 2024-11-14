/*
  This will be the sign up page.
  Coded by VorahPong, Mean
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import '../db.dart';
import '../models/User.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers for email and password
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool isLoading = false;

  @override
  void dispose() {
    // Dispose of controllers when not in use
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Top bar
      appBar: _appBar(),

      // Middle of the page
      body: _middle(),
    );
  }

  // Middle page includes input for email, password, and a sign-up button
  Widget _middle() {
    // Method to save login state in shared preferences
    Future<void> setLoginState(bool isLoggedIn, String id, String name) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', isLoggedIn);
      await prefs.setString('unique_id', id);
      await prefs.setString('user_name', name);
    }

    Future<bool> createUser(User newUser) async {
      var db = MongoDBService().db; // Access the singleton instance
      var usersCollection = db.collection('UserCluster');

      try {
        var result = await usersCollection.insertOne({
          'name': newUser.name,
          'email': newUser.email,
          'password': newUser.password,
          'cart': [],
        });
      print('User created successfully');
      await setLoginState(true, result.id.oid, newUser.name);
      return true;
      } catch (e) {
        print('Failed to create user: $e');
        return false;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Name input
          TextFormField(
            controller: _nameController, // Attach the email controller
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter your name',
            ),
          ),

          // Email input
          TextFormField(
            controller: _emailController, // Attach the email controller
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter your email',
            ),
          ),

          // Password input
          TextFormField(
            controller: _passwordController, // Attach the password controller
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter your Password',
            ),
            obscureText: true, // Hide text for password security
          ),

          const SizedBox(height: 20), // Add some spacing

          isLoading ? 
            const CircularProgressIndicator(
                color: Colors.black,
            )
          : TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
            ),
            onPressed: () async {
              setState(() => isLoading = true);
              // Retrieve values from controllers
              final name = _nameController.text;
              final email = _emailController.text;
              final password = _passwordController.text;

              bool signedUp = await createUser(User(name: name, email: email, password: password, cart:[]));

              setState(() => isLoading = false);
              if (signedUp) {
                // Navigate to HomePage after successful sign-in
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              } else {
                // Show error message if sign-in fails
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sign-in failed')),
                );
              }
            },
            child: const Text(
              'Sign Up',
              style: TextStyle(color: Colors.white), // Ensures text is visible
            ),
          ),
        ],
      ),
    );
  }

  // Top Bar
  AppBar _appBar() {
    return AppBar(
      title: const Text(
        'Sign Up',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 2.0,

      // Go back button (if needed for navigation)
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => LoginPage()));
        },
      ),
      
    );
  }
}
