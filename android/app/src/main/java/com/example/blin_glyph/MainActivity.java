package com.example.blin_glyph;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.view.accessibility.AccessibilityManager;
import android.content.Intent;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String PROXIMITY_CHANNEL = "com.example.blin_glyph/proximity";
    private static final String ACCESSIBILITY_CHANNEL = "com.example.blin_glyph/accessibility";

    private SensorManager sensorManager;
    private Sensor proximitySensor;
    private SensorEventListener proximitySensorListener;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Proximity Sensor Setup
        sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        proximitySensor = sensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY);

        proximitySensorListener = new SensorEventListener() {
            @Override
            public void onSensorChanged(SensorEvent sensorEvent) {
                if (sensorEvent.values[0] < proximitySensor.getMaximumRange()) {
                    // Object is close
                    new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), PROXIMITY_CHANNEL)
                            .invokeMethod("proximityChanged", true);
                } else {
                    // Object is far
                    new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), PROXIMITY_CHANNEL)
                            .invokeMethod("proximityChanged", false);
                }
            }

            @Override
            public void onAccuracyChanged(Sensor sensor, int accuracy) {
            }
        };

        sensorManager.registerListener(proximitySensorListener, proximitySensor, SensorManager.SENSOR_DELAY_NORMAL);

        // Set up Method Channel for Accessibility Service
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), ACCESSIBILITY_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("lockScreen")) {
                        if (isAccessibilityServiceEnabled()) {
                            lockScreen();
                            result.success(null);
                        } else {
                            result.error("SERVICE_DISABLED", "Accessibility service is not enabled", null);
                        }
                    } else {
                        result.notImplemented();
                    }
                });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Unregister proximity sensor listener
        sensorManager.unregisterListener(proximitySensorListener);
    }

    // Method to check if the accessibility service is enabled
    private boolean isAccessibilityServiceEnabled() {
        AccessibilityManager am = (AccessibilityManager) getSystemService(Context.ACCESSIBILITY_SERVICE);
        return am.isEnabled();
    }

    // Method to lock the screen using the Accessibility Service
    private void lockScreen() {
        YourAccessibilityService service = YourAccessibilityService.getInstance(); // Get the running instance of the Accessibility Service
        if (service != null) {
            service.lockScreen(); // Call the lock screen method in the service
        } else {
            Log.e("MainActivity", "AccessibilityService is not running");
        }
    }
}
