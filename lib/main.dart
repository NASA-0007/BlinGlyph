import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'intro_screen.dart';
import 'sensor_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value){
    if (value)
    {
      Permission.notification.request();
    }
  });
  runApp(const MyApp());
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<double> _getSensitivityThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('sensitivityThreshold') ?? -5.0; // Default value if not set
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const IntroScreen(), // Start with the IntroScreen
      routes: {
        '/main': (context) => FutureBuilder<double>(
          future: _getSensitivityThreshold(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()), // Show loading indicator while fetching
              );
            } else if (snapshot.hasError) {
              return const Scaffold(
                body: Center(child: Text('Error loading sensitivity threshold')),
              );
            } else if (snapshot.hasData) {
              final double initialSensitivity = snapshot.data!;
              return SensorScreen(initialSensitivity: initialSensitivity);
            } else {
              return const Scaffold(
                body: Center(child: Text('No data available')),
              );
            }
          },
        ),
      },
    );
  }
}
