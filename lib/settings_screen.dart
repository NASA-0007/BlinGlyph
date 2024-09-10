
//{"Not Used in Updated Version"}


/*
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'sensitivity_adjust_screen.dart'; // Import SensitivityAdjustScreen
import 'sensor_screen.dart'; // Import SensorScreen

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double sensitivityThreshold = 0.0; // Default value

  @override
  void initState() {
    super.initState();
    _loadSensitivityThreshold();
  }

  Future<void> _loadSensitivityThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      sensitivityThreshold = prefs.getDouble('sensitivityThreshold') ?? 0.0;
    });
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

  Future<void> _saveSensitivityThreshold(double newThreshold) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sensitivityThreshold', newThreshold);
  }

  void _navigateToSensorScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SensorScreen(
          initialSensitivity: sensitivityThreshold,
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    _navigateToSensorScreen();
    return false; // Prevent the default back navigation
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _navigateToSensorScreen, // Custom back button logic
          ),
          title: const Text('Settings', style: TextStyle(fontFamily: "Nothing", color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
        ),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.tune, color: Colors.white),
              title: const Text('Check and Adjust Sensitivity', style: TextStyle(color: Colors.white)),
              onTap: _navigateToSensitivityAdjustScreen,
            ),
          ],
        ),
      ),
    );
  }
}
*/