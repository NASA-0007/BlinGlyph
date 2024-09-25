package com.example.blin_glyph;

import android.accessibilityservice.AccessibilityService;
import android.view.accessibility.AccessibilityEvent;

public class YourAccessibilityService extends AccessibilityService {
    private static YourAccessibilityService instance;

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
    }

    public static YourAccessibilityService getInstance() {
        return instance;
    }

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        // Handle accessibility events here if needed
    }

    @Override
    public void onInterrupt() {
        // Handle interruption here if needed
    }

    @Override
    protected void onServiceConnected() {
        super.onServiceConnected();
        // You can initialize anything related to the service here if needed
    }

    // Method to lock the screen, called from MainActivity
    public void lockScreen() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
            performGlobalAction(AccessibilityService.GLOBAL_ACTION_LOCK_SCREEN);
        }
    }
}
