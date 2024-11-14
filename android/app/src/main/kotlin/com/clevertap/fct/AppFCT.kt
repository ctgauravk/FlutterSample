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



    public fun setCleverTapMethods() {
//        Log.e("called","")
        ActivityLifecycleCallback.register(this)
    }

//    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//            NotificationUtils.dismissNotification(activity.intent, applicationContext)
//        }
//    }

//    object NotificationUtils {
//
//        //Require to close notification on action button click
//        fun dismissNotification(intent: Intent?, applicationContext: Context){
//            intent?.extras?.apply {
//                var autoCancel = true
//                var notificationId = -1
//
//                getString("actionId")?.let {
//                    Log.d("ACTION_ID", it)
//                    autoCancel = getBoolean("autoCancel", true)
//                    notificationId = getInt("notificationId", -1)
//                }
//                /**
//                 * If using InputBox template, add ptDismissOnClick flag to not dismiss notification
//                 * if pt_dismiss_on_click is false in InputBox template payload. Alternatively if normal
//                 * notification is raised then we dismiss notification.
//                 */
//                val ptDismissOnClick = intent.extras!!.getString(PTConstants.PT_DISMISS_ON_CLICK,"")
//
//                if (autoCancel && notificationId > -1 && ptDismissOnClick.isNullOrEmpty()) {
//                    val notifyMgr: NotificationManager =
//                        applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
//                    notifyMgr.cancel(notificationId)
//                }
//            }
//        }
//
//    }
}