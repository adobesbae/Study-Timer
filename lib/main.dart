import 'package:flutter/material.dart';
import 'package:study_timer/pages/welcome_page.dart';
import 'dart:async'; 
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // Initialize time zones
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _preloadImage(BuildContext context) async {
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<void>(
        future: _preloadImage(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const SplashScreen(); 
          } else {
            return const Scaffold(
              backgroundColor: Colors.transparent,
            );
          }
        },
      ),
    );
  }
}

// Splash screen widget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a delay before navigating to the HomePage
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/icon/icon.png',
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}
