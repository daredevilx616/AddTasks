import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'xxxx', // Replace with actual apiKey
      appId: 'xxxxx', // Replace with actual appId
      messagingSenderId: 'xxxx', // Replace with actual messagingSenderId
      projectId: 'xxxx', // Replace with actual projectId
      storageBucket: 'xxxx', // Replace with actual storageBucket
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(), // Start with the login screen
    );
  }
}
