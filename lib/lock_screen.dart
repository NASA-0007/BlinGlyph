import 'package:flutter/services.dart';

class ScreenLockService {
  static const MethodChannel _accessibilityChannel = MethodChannel('com.example.blin_glyph/accessibility');
static Future<void> screenOff() async {
    final result = await _accessibilityChannel.invokeMethod('lockScreen');
    if (result == null) {
      print('Screen locked successfully');
    } else {
      print('Error locking screen: $result');
    }
  }
}