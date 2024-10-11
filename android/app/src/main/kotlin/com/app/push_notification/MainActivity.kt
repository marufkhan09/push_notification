package com.app.push_notification

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle // Import the Bundle class
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel() // Call the function to create the notification channel
    }

    private fun createNotificationChannel() {
        // Check if the Android version is Oreo or higher
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Default Channel" // Name of the channel
            val descriptionText = "Channel for default notifications" // Description of the channel
            val importance = NotificationManager.IMPORTANCE_DEFAULT // Importance level
            val channel = NotificationChannel("default_notification_channel_id", name, importance).apply {
                description = descriptionText
            }
            val notificationManager: NotificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel) // Create the channel
        }
    }
}
