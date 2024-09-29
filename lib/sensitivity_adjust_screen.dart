import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart'; // For accelerometer
import 'package:shared_preferences/shared_preferences.dart';

class SensitivityAdjustScreen extends StatefulWidget {
  final double initialSensitivity;
  final ValueChanged<double> onSensitivityChanged; // Callback
  final ValueChanged<bool> onScreenOffChanged;

  const SensitivityAdjustScreen({
    required this.initialSensitivity,
    required this.onSensitivityChanged,
    required this.onScreenOffChanged,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SensitivityAdjustScreenState createState() => _SensitivityAdjustScreenState();
}

class _SensitivityAdjustScreenState extends State<SensitivityAdjustScreen> {
  late double sensitivityThreshold;
  late double zAxis;
  bool isProximityClose = false;
  bool isScreenOff = false; // For the toggle
  late StreamSubscription<AccelerometerEvent> accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _loadScreenOffState(); // Load the initial state
    sensitivityThreshold = widget.initialSensitivity; // Use initial value from widget
    zAxis = 0; // Default value

    accelerometerSubscription = accelerometerEventStream().listen((event) {
      setState(() {
        zAxis = event.z;
      });
    });
  }

  @override
  void dispose() {
    accelerometerSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadScreenOffState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isScreenOff = prefs.getBool('screenOffState') ?? false; // Default to false if not set
    });
  }

  Future<void> _saveScreenOffState(bool isOff) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('screenOffState', isOff);
  }

  @override
  Widget build(BuildContext context) {
    bool isExceedingLimit = sensitivityThreshold < -7.5 || sensitivityThreshold > -4.5;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontFamily: "Nothing", color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Z Axis: ${zAxis.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    color: (zAxis < sensitivityThreshold && isProximityClose)
                        ? Colors.black
                        : Colors.white,
                    fontFamily: "Nothing_ALT",
                  ),
                ),
                const SizedBox(height: 20),
                Slider(
                  value: sensitivityThreshold,
                  min: -10,
                  max: 10,
                  divisions: 80,
                  onChanged: (value) {
                    setState(() {
                      sensitivityThreshold = value;
                    });
                  },
                  onChangeEnd: (value) {
                    widget.onSensitivityChanged(value); // Notify the parent
                  },
                  activeColor: const Color.fromARGB(255, 255, 255, 255),
                  inactiveColor: const Color.fromARGB(255, 0, 0, 0),
                  thumbColor: const Color.fromARGB(255, 216, 0, 0),
                ),
                Text(
                  "Sensitivity: $sensitivityThreshold",
                  style: TextStyle(
                    fontSize: 24,
                    color: (zAxis < sensitivityThreshold && isProximityClose)
                        ? Colors.black
                        : Colors.white,
                    fontFamily: "Nothing_ALT",
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Turn off screen",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: "Nothing_ALT",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: isScreenOff,
                      onChanged: (value) {
                        setState(() {
                          isScreenOff = value;
                        });
                        widget.onScreenOffChanged(value);
                        _saveScreenOffState(value); // Save the state
                      },
                      activeColor: Colors.red,
                      inactiveThumbColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isExceedingLimit)
            const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recommended to keep the sensitivity between -7.5 and -4.5 to prevent false triggers.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontFamily: "Nothing_ALT",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
