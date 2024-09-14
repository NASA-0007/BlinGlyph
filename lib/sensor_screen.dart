import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nothing_glyph_interface/nothing_glyph_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // For MethodChannel
import 'package:sensors_plus/sensors_plus.dart'; // For accelerometer
import 'glyph_trigger.dart'; // Import GlyphTrigger class
import 'sensitivity_adjust_screen.dart'; // Import SensitivityAdjustScreen
import 'phone.dart'; // Import Phone enum
import 'glyph_map.dart'; // Import GlyphMap class

class SensorScreen extends StatefulWidget {
  final double initialSensitivity; // Add this parameter
  const SensorScreen({
    super.key,
    required this.initialSensitivity,
  });

  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> with TickerProviderStateMixin {

  static const platform = MethodChannel('com.example.blin_glyph/proximity');
  double zAxis = 0;
  bool isProximityClose = false;
  String phoneis='';
  late StreamSubscription<AccelerometerEvent> accelerometerSubscription;
  late double sensitivityThreshold;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final NothingGlyphInterface glyphInterface = NothingGlyphInterface();
  Timer? checkTimer; // Timer for 2-second delay
  bool _isGlyphRunning=false;
  bool _isRunning=false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
    sensitivityThreshold = widget.initialSensitivity; // Use the passed value
    accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        setState(() {
          zAxis = event.z;
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
        checkConditions();
      }
    });
  }
  Future<void> getPhoneFormattedName() async {
    Phone phone = await Phone.guessCurrentPhone();
    phoneis= phone.formattedName;
  }
  Future<void> checkConditions() async {
    GlyphTrigger glyphTrigger = GlyphTrigger(glyphInterface);
    // Check if both conditions (zAxis and proximity) are met
    if (zAxis < sensitivityThreshold && isProximityClose) {
      if (checkTimer == null || !checkTimer!.isActive) {
        
        if (!_isGlyphRunning)
        {
        _isGlyphRunning=true;
        _isRunning=true;
        GlyphTrigger.stopExecution=false;
        _triggerGlyphPH2();
        }
        // Start the timer to wait 2 seconds before triggering
        checkTimer = Timer(Duration(seconds: 2), () {
          _isRunning=false;
          if (zAxis < sensitivityThreshold && isProximityClose) {
            _isRunning=false;
            _isGlyphRunning=false;
            print("Conditons are Still Met");
          }
        });
      }}
     else {
      checkTimer?.cancel();
      glyphTrigger.stopGlyph();
       _isGlyphRunning=false;

      print("Not Met");
      // Reset the timer if conditions are no longer met
    }
  }
  Future<void> _checkProximitySensor() async {
    try {
      // Check proximity sensor updates
    } on PlatformException catch (e) {
      print("Failed to get proximity sensor data: '${e.message}'");
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

  Future<void> _triggerGlyphPH2() async {
    final Phone phone;
    final GlyphTrigger glyphTrigger = GlyphTrigger(glyphInterface);
    phone = await Phone.guessCurrentPhone();
    final glyph = GlyphMap.fromIndex(phone, 4); // Update based on your requirements
    int totalZones = phone.calculateTotalZones;
    phoneis=phone.formattedName;
    print('Current phone is: ${phoneis} Number of Zones : $totalZones');

    // Assuming you want to use the default glyph map and phone for demonstration
    await glyphTrigger.initialGlyph(glyph,phone);
  }
  @override
  void dispose() {
    accelerometerSubscription.cancel();
    _controller.dispose();
    checkTimer?.cancel(); // Cancel the timer when disposing the widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getPhoneFormattedName();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:FadeTransition(opacity: _fadeAnimation,
        child: Text('BlinGlyph', style: TextStyle(color: (zAxis < sensitivityThreshold && isProximityClose)? Colors.red : Colors.white, fontFamily: "Nothing"))),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        actions: [
          FadeTransition(opacity: _fadeAnimation,
          child:IconButton(
            icon: Icon(Icons.settings, color:(zAxis < sensitivityThreshold && isProximityClose)? Colors.red : Colors.white),
            onPressed: () {
              _navigateToSensitivityAdjustScreen();
            },
          )
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
        child: Text('Current Phone is : ${phoneis}', style: TextStyle(color: (zAxis < sensitivityThreshold && isProximityClose)? Colors.red : Colors.white,fontFamily:"Nothing_ALT")),
      ),
    ));
  }
}