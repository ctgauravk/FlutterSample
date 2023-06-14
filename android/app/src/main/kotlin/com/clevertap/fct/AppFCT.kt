package com.clevertap.fct

import android.app.NotificationManager
import android.os.Build
import com.clevertap.android.pushtemplates.PushTemplateNotificationHandler
import com.clevertap.android.sdk.ActivityLifecycleCallback
import com.clevertap.android.sdk.CleverTapAPI
import com.clevertap.android.sdk.interfaces.NotificationHandler
import io.flutter.app.FlutterApplication
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint

class AppFCT : FlutterApplication() {
    private lateinit var flutterEngine: FlutterEngine


    override fun onCreate() {
        ActivityLifecycleCallback.register(this)
        super.onCreate()

        //Tentative solution to solve killed state issue for notification click callback.
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartEntrypoint.createDefault()
        )

        CleverTapAPI.setDebugLevel(CleverTapAPI.LogLevel.DEBUG);
        CleverTapAPI.setNotificationHandler(PushTemplateNotificationHandler() as NotificationHandler)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CleverTapAPI.createNotificationChannelGroup(this, "YourGroupId", "YourGroupName")
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CleverTapAPI.createNotificationChannel(
                applicationContext,
                "testkk123",
                "test",
                "test",
                NotificationManager.IMPORTANCE_MAX,
                true
            )
        }
    }
}