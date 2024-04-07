import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'task_list_screen.dart'; // This screen is for displaying tasks after login.
import 'register_screen.dart'; // This screen is for registering a new user.

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate to the TaskListScreen after a successful sign-in.
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => TaskListScreen()));
    } catch (e) {
      print(e); // It's better to use more sophisticated error handling in a production app.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to sign in'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SingleChildScrollView( // Wrap your Column in a SingleChildScrollView to prevent overflow when the keyboard is visible
        child: Padding( // Added Padding for better UI
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 8.0), // Added SizedBox for spacing
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
              ),
              SizedBox(height: 24.0), // Added SizedBox for spacing
              ElevatedButton(
                onPressed: signIn,
                child: Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50), // Make the button larger
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to the RegisterScreen when the 'Register' button is pressed.
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RegisterScreen(),
                  ));
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
