/*
  This will be the sign up page.
  Coded by VorahPong, Mean
 */

import 'package:flutter/material.dart';
import 'db.dart';
import 'models/User.dart';
import './login.dart';

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
    Future<void> createUser(User newUser) async {
      var db = MongoDBService().db; // Access the singleton instance
      var usersCollection = db.collection('UserCluster');

      try {
        await usersCollection.insertOne({
          'name': newUser.name,
          'email': newUser.email,
          'password': newUser.password,
        });
      print('User created successfully');
      } catch (e) {
        print('Failed to create user: $e');
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

          // Button
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
            ),
            onPressed: () async {
              // Retrieve values from controllers
              final name = _nameController.text;
              final email = _emailController.text;
              final password = _passwordController.text;

              await createUser(User(name: name, email: email, password: password));
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
