import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import the Login Screen

class SplashScreen extends StatefulWidget {
  final Function(bool) onThemeChange; // Add this parameter for theme change callback

  SplashScreen({required this.onThemeChange});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to the Login Screen after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png', // App logo
              height: 150,
              width: 150,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to StockWatch',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            // Theme Toggle Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: widget.onThemeChange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
