/*
  This will be the sign up page.
  Coded by VorahPong, Mean
 */

import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers for email and password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Dispose of controllers when not in use
    _emailController.dispose();
    _passwordController.dispose();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            onPressed: () {
              // Retrieve values from controllers
              final email = _emailController.text;
              final password = _passwordController.text;

              print("Email: $email");
              print("Password: $password");

              // Perform additional actions here, like sending data to an authentication service
            },
            child: const Text(
              'Sign Up!',
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
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context); // Go back when tapped
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
