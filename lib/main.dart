import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the generated firebase_options.dart
import 'screens/home_screen.dart';  // Import your HomeScreen

void main() async {
  // Ensure that Flutter bindings are initialized before Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options from firebase_options.dart
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase Initialized Successfully!");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(MyApp());  // Run your app after Firebase initialization
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),  // Make sure HomeScreen is correctly set here
    );
  }
}
