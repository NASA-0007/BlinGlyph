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
import 'lock_screen.dart';

class SensorScreen extends StatefulWidget {
  final double initialSensitivity;
  const SensorScreen({
    super.key,
    required this.initialSensitivity,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> with TickerProviderStateMixin {
  static const platform = MethodChannel('com.example.blin_glyph/proximity');
  double zAxis = 0;
  bool isProximityClose = false;
  String phoneis = '';
  late StreamSubscription<AccelerometerEvent> accelerometerSubscription;
  late double sensitivityThreshold;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final NothingGlyphInterface glyphInterface = NothingGlyphInterface();
  final NothingGlyphInterface glyphInterface2 = NothingGlyphInterface();
  Timer? checkTimer;
  bool _isGlyphRunning = false;
  bool _isRunning = false;
  // ignore: non_constant_identifier_names
  bool _ScreenOff = false;

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
    _getScreenOffState().then((isOff) {
    setState(() {
      _ScreenOff = isOff;
    });
  });
    sensitivityThreshold = widget.initialSensitivity;
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
    phoneis = phone.formattedName;
  }

  Future<void> checkConditions() async {
    GlyphTrigger glyphTrigger = GlyphTrigger(glyphInterface);

    if (zAxis < sensitivityThreshold && isProximityClose) {
      if (_ScreenOff){
      if (checkTimer == null || !checkTimer!.isActive) {
        if (!_isGlyphRunning) {
          _isGlyphRunning = true;
          GlyphTrigger.stopExecution=false;
          _triggerGlyph();
        }
        // Start the timer to wait 2 seconds before triggering
        checkTimer = Timer(const Duration(seconds: 2), () async {
          if (zAxis < sensitivityThreshold && isProximityClose && _isRunning==false) {
              if (_ScreenOff){
              ScreenLockService.screenOff();
              }
              _isRunning = true;
            await _triggerFLowGlyph();
            print("Conditions are Still Met");
          }
        });
      }
    }
    else {
      await Future.delayed(const Duration(milliseconds: 550));
      await _triggerFLowGlyph();
    }
    }
    else {
      checkTimer?.cancel();
      glyphTrigger.stopGlyph();
      _isGlyphRunning = false;
      _isRunning = false;
      print("Not Met");
    }
  }

  Future<void> _saveSensitivityThreshold(double newThreshold) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sensitivityThreshold', newThreshold);
  }

  Future<void> _saveScreenOffState(bool isOff) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('screenOffState', isOff);
  }

  Future<bool> _getScreenOffState() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('screenOffState') ?? false; // Default to false if not set
  }

  Future<void> _navigateToSensitivityAdjustScreen() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SensitivityAdjustScreen(
        initialSensitivity: sensitivityThreshold,
        onSensitivityChanged: (newThreshold) {
          setState(() {
            sensitivityThreshold = newThreshold;
          });
          _saveSensitivityThreshold(newThreshold);
        },
        onScreenOffChanged: (isOff) {
          setState(() {
            _ScreenOff = isOff;
          });
        },
      ),
    ),
  );
}

  Future<void> _triggerGlyph() async {
    int id = 0;
    Phone phone = await Phone.guessCurrentPhone();
    GlyphTrigger glyphTrigger=GlyphTrigger(glyphInterface);
    if (phoneis == "Phone (2)") {
      id = 3;
    } else if (phoneis == "Phone (1)") {
      id = 7;
    } else if (phoneis == "Phone (2a)") {
      id = 0;
    }
    final glyph = GlyphMap.fromIndex(phone, id);
    await glyphTrigger.initialGlyph(glyph, phone);
  }

  Future<void> _triggerFLowGlyph() async {
    Phone phone = await Phone.guessCurrentPhone();
    final GlyphTrigger glyphTrigger2 = GlyphTrigger(glyphInterface2);
    if (phoneis == "Phone (2)") {
      await Future.delayed(const Duration(milliseconds: 40));
      await glyphTrigger2.multiGlyphE(phone);
    }
    else if (phoneis == "Phone (1)") {
      await _runGlyphSequence(phone, [7, 6, 5, 1, 0]);
    }
    else if (phoneis == "Phone (2a)") {
      await _runGlyphSequence(phone, [25, 24, 23]);
    }
    
    print('Glyph Flowing Done');
    _isGlyphRunning = false;
  }

  Future<void> _runGlyphSequence(Phone phone, List<int> sequence) async {
    for (int id in sequence) {
      await glyphSequence(id, phone);
    }
  }

  Future<void> glyphSequence(int id, Phone phone) async {
    await Future.delayed(const Duration(milliseconds: 40));
    final GlyphTrigger glyphTrigger2 = GlyphTrigger(glyphInterface2);
    final glyph2 = GlyphMap.fromIndex(phone, id);
    await glyphTrigger2.flowGlyph(glyph2, phone);
  }

  @override
  void dispose() {
    accelerometerSubscription.cancel();
    _controller.dispose();
    checkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getPhoneFormattedName();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'BlinGlyph',
            style: TextStyle(
              color: (zAxis < sensitivityThreshold && isProximityClose) ? Colors.red : Colors.white,
              fontFamily: "Nothing",
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        actions: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: IconButton(
              icon: Icon(
                Icons.settings,
                color: (zAxis < sensitivityThreshold && isProximityClose) ? Colors.red : Colors.white,
              ),
              onPressed: _navigateToSensitivityAdjustScreen,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Text(
            phoneis,
            style: TextStyle(fontSize: 25,
              color: (zAxis < sensitivityThreshold && isProximityClose) ? Colors.red : Colors.white,
              fontFamily: "Nothing_ALT",
            ),
          ),
        ),
      ),
    );
  }
}
