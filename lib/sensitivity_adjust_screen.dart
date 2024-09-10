import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart'; // For accelerometer

class SensitivityAdjustScreen extends StatefulWidget {
  final double initialSensitivity;
  final ValueChanged<double> onSensitivityChanged; // Callback

  SensitivityAdjustScreen({
    required this.initialSensitivity,
    required this.onSensitivityChanged,
    Key? key,
  }) : super(key: key);

  @override
  _SensitivityAdjustScreenState createState() => _SensitivityAdjustScreenState();
}

class _SensitivityAdjustScreenState extends State<SensitivityAdjustScreen> {
  late double sensitivityThreshold;
  late double zAxis;
  bool isProximityClose = false;
  late StreamSubscription<AccelerometerEvent> accelerometerSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  @override
  Widget build(BuildContext context) {
    bool isExceedingLimit =
        sensitivityThreshold < -8.5 || sensitivityThreshold > -4.5;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Adjust Sensitivity', style: TextStyle(fontFamily: "Nothing", color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                        'Recommended to keep the sensitivity between -8.5 and -4.5 to prevent false triggers.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10, fontFamily: "Nothing_ALT",
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
