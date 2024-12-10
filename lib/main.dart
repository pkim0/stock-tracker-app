import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core import
import 'package:stock_app_project/screens/login_screen.dart'; // Login Screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(StockTrackerApp());
}

class StockTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock Tracker App',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Set LoginScreen as the starting screen
      home: LoginScreen(),
    );
  }
}
