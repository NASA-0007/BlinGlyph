package com.avnasa.blin_glyph;

import android.app.Notification;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import androidx.core.app.NotificationCompat;

public class ForegroundService extends Service {

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Create a notification
        Notification notification = new NotificationCompat.Builder(this, "CHANNEL_ID")
            .setContentTitle("Service Running")
            .setContentText("Your app is running a background task")
            .setSmallIcon(R.mipmap.ic_launcher)
            .build();

        // Start the service in the foreground
        startForeground(1, notification);

        // Execute the code you want to keep running here
        
        return START_NOT_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
