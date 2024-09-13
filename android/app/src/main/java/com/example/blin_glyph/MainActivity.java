package com.example.blin_glyph;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.view.View;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String PROXIMITY_CHANNEL = "com.example.blin_glyph/proximity";
    
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
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Unregister proximity sensor listener
        sensorManager.unregisterListener(proximitySensorListener);
    }
}
