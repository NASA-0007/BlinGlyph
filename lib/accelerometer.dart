import 'dart:async';
import 'package:flutter/services.dart';

class AccelerometerManager {
  static final AccelerometerManager _instance = AccelerometerManager._internal();
  factory AccelerometerManager() => _instance;

  static const MethodChannel accelerometerChannel = MethodChannel('com.avnasa.blin_glyph/accelerometer');
  final List<void Function(double)> _listeners = [];

  AccelerometerManager._internal() {
    accelerometerChannel.setMethodCallHandler(_methodCallHandler);
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    if (call.method == 'accelerometerChanged') {
      final zAxis = call.arguments as double;
      for (var listener in _listeners) {
        listener(zAxis);
      }
    }
  }

  void addListener(void Function(double) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(double) listener) {
    _listeners.remove(listener);
  }
}
