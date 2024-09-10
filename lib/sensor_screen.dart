import 'dart:async';
import 'sensitivity_adjust_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // For MethodChannel
import 'package:sensors_plus/sensors_plus.dart'; // For accelerometer

class SensorScreen extends StatefulWidget {
  final double initialSensitivity; // Add this parameter

  const SensorScreen({
    super.key,
    required this.initialSensitivity,
  });

  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  static const platform = MethodChannel('com.example.blin_glyph/proximity');
  double zAxis = 0;
  bool isProximityClose = false;
  late StreamSubscription<AccelerometerEvent> accelerometerSubscription;
  late double sensitivityThreshold;
  @override
  void initState() {
    super.initState();
    sensitivityThreshold = widget.initialSensitivity; // Use the passed value

    accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        setState(() {
          zAxis = event.z;

          if (zAxis < sensitivityThreshold) {
            _checkProximitySensor();
          }
        });
      },
      onError: (error) {
        print('Accelerometer error: $error');
      },
    );
    platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'proximityChanged') {
        setState(() {
          isProximityClose = call.arguments as bool;
        });
        if (isProximityClose && zAxis < sensitivityThreshold) {
          print('Proximity is close and zAxis < $sensitivityThreshold: Triggering action.');
        }
      }
    });
  }
  Future<void> _checkProximitySensor() async {
    try {
      // Check proximity sensor updates
    } on PlatformException catch (e) {
      print("Failed to get proximity sensor data: '${e.message}'.");
    }
  }
  Future<void> _saveSensitivityThreshold(double newThreshold) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sensitivityThreshold', newThreshold);
  }
  Future<void> _navigateToSensitivityAdjustScreen() async {
    final updatedThreshold = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SensitivityAdjustScreen(
          initialSensitivity: sensitivityThreshold,
          onSensitivityChanged: (newThreshold) {
            setState(() {
              sensitivityThreshold = newThreshold;
            });
            _saveSensitivityThreshold(newThreshold); // Save the updated threshold immediately
          },
        ),
      ),
    );

    // The updatedThreshold is now handled in the onSensitivityChanged callback
  }
  @override
  void dispose() {
    accelerometerSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('BlinGlyph', style: TextStyle(color: (zAxis < sensitivityThreshold && isProximityClose)? Colors.red : Colors.white, fontFamily: "Nothing")),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color:(zAxis < sensitivityThreshold && isProximityClose)? Colors.red : Colors.white),
            onPressed: () {
              _navigateToSensitivityAdjustScreen();
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Main Sensor Screen', style: TextStyle(color: (zAxis < sensitivityThreshold && isProximityClose)? Colors.red : Colors.white),),
      ),
    );
  }
}
