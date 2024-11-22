/*
  This will be the sign up page.
  Coded by VorahPong, Mean
 */

import 'package:flutter/material.dart';
import '/pages/home_page.dart';
import 'sign_up.dart';
import '../db.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  // Function to save the unique ID and user Name to local storage
  Future<void> saveUniqueId(String uniqueId, String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('unique_id', uniqueId);
    await prefs.setString('user_name', userName);
    await prefs.setInt('cart_size',0);
  }

  // function to set LoginState
  Future<void> setLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
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
          
          Row(
            children: [
              // Login Button
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
                ),
                onPressed: () async {
                  // Retrieve values from controllers
                  final email = _emailController.text;
                  final password = _passwordController.text;

                  // Access MongoDB instance
                  var db = MongoDBService().db;
                  var usersCollection = db.collection('UserCluster');

                  // Find the user
                  var user = await usersCollection.findOne({
                    'email': email,
                    'password': password,
                  });

                  if (user != null) {
                    print("Login successful");
                    // save unique id
                    print(user['_id']);
                    print(user['name']);
                    await saveUniqueId(user['_id'].oid, user['name'].toString());
                    await setLoginState(true);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                  } else {
                    print("Invalid email or password");
                    // Show error message to the user
                    showDialog(
                      context: context, 
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Error"),
                          content: const Text("Invalid email or password"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              }, 
                              child: const Text("OK")
                            ),
                          ],
                        );
                      }
                    );
                  }


                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white), // Ensures text is visible
                ),
              ),

              // Register Button
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
                ),
                onPressed: () {
                    // direct to register page
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                },
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.white), // Ensures text is visible
                ),
              ),
            ],
          ),

          

        ],
      ),
    );
  }

  // Top Bar
  AppBar _appBar() {
    return AppBar(
      title: const Text(
        'Welcome, please login to continue',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 2.0,
    );
  }
}
