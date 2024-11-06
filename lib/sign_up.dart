/*
  This will be the sign up page.
  Coded by VorahPong, Mean
 */

import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // background color
        backgroundColor: Colors.white,

        // Top bar
        appBar: appBar(),
        //

        // middle of the page
        body: middle(),
        //

    );
  }

// Middle page include input for email, password, and a sign up button
  Column middle() {
    return Column(
          children: [

              // Email input
              TextFormField(
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your email',
                  ), 
              ),
              //

              // Password input
              TextFormField(
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your Password',
                  ), 
              ),
              //
              
              // Button
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  onPressed: () {}, 
                  child: Text(
                      'Sign Me Up!',
                      style: TextStyle(color: Colors.white), // to ensure the text is visible
                  ),
              ),

              //
          ],
      );
  }

  // Top Bar
  AppBar appBar() {
    return AppBar(
          // Sign Up Label on top
          title: Text(
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
          //
          
          // go back button
          actions: [
            GestureDetector(
              onTap: () {
                
              },
              child:
                  Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                      ),
                  ),
            ),
          ],
          //
      );
  }
}