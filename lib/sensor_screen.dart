import 'dart:async';
import 'package:blin_glyph/accelerometer.dart';
import 'package:flutter/material.dart';
import 'package:nothing_glyph_interface/nothing_glyph_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // For MethodChannel
import 'glyph_trigger.dart'; // Import GlyphTrigger class
import 'sensitivity_adjust_screen.dart'; // Import SensitivityAdjustScreen
import 'phone.dart'; // Import Phone enum
import 'glyph_map.dart'; // Import GlyphMap class
import 'lock_screen.dart';
import 'assets.dart';
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
  static const platform = MethodChannel('com.avnasa.blin_glyph/proximity');
  static const platform2 = MethodChannel('com.avnasa.blin_glyph/service');
  double zAxis = 0;
  bool isProximityClose = false;
  String phoneis = '';
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
    AccelerometerManager().addListener((value) {
      setState(() {
        zAxis = value;
      });
    });

    platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'proximityChanged') {
        setState(() {
          isProximityClose = call.arguments as bool;
        });
        checkConditions();
      }
    });
  }

  Future<void> startService() async {
    try {
      await platform2.invokeMethod('startService');
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'.");
    }
  }

  Future<void> stopService() async {
    try {
      await platform2.invokeMethod('stopService');
    } on PlatformException catch (e) {
      print("Failed to stop service: '${e.message}'.");
    }
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
      print(sensitivityThreshold);
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
      await Future.delayed(const Duration(milliseconds: 40));
      await glyphTrigger2.multiGlyphE(phone);
    }
    else if (phoneis == "Phone (2a)") {
      await Future.delayed(const Duration(milliseconds: 40));
      await glyphTrigger2.multiGlyphA(phone);
      await glyphTrigger2.multiGlyphB(phone);
      await glyphTrigger2.multiGlyphC(phone);
    }
    
    print('Glyph Flowing Done');
    _isGlyphRunning = false;
  }

  @override
  void dispose() async{
     AccelerometerManager().removeListener((value) {});
    _controller.dispose();
    checkTimer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    const assets = $AssetsImagesGlyphsGen();
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
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Wrap the GIF display in a Container to set the width
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.75, // Set width according to your preference
          child: assets.getGifDisplay(phoneis),
        ),
        const SizedBox(height: 20), // Adjust this height to move the text down
        Text(
          phoneis,
          style: TextStyle(
            fontSize: 25,
            color: (zAxis < sensitivityThreshold && isProximityClose) 
                ? Colors.red 
                : Colors.white,
            fontFamily: "Nothing_ALT",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
