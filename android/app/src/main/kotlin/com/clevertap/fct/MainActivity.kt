package com.clevertap.fct

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.PersistableBundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.clevertap.android.sdk.CleverTapAPI
import com.clevertap.android.sdk.CleverTapInstanceConfig
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.android.awaitFrame
import kotlin.random.Random

class MainActivity : FlutterActivity() {

    var clevertapAdditionalInstance: CleverTapAPI? = null
    var clevertapAdditionalInstanceConfig: CleverTapInstanceConfig? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    private val CHANNEL = "myChannel";
    private lateinit var channel: MethodChannel
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        Log.e("TAG", "configureFlutterEngine:" )

        channel.setMethodCallHandler { call, result ->
            if (call.method == "nativeMethod") {
                Log.e("TAG", "configureFlutterEngine: if", )
                val preferences = applicationContext.getSharedPreferences("WizRocket", MODE_PRIVATE)  ?: null
                if (preferences!= null) {
                    val editor = preferences.edit()


                    for ((key, value) in preferences.all) {
                        // Check if the key starts with the specified prefix
//|| !key.contains("fcm_token")
                        if (!(key.contains("fcm_token") || key.contains("comms_first_ts"))) {

                            editor.remove(key)
                        }

//                        }

                    }
                    editor.apply()


                    CleverTapAPI.setInstances(null)
                    (application as AppFCT).setCleverTapMethods()
                    var cleverTapDefaultInstance: CleverTapAPI? = null
                    cleverTapDefaultInstance = CleverTapAPI.getDefaultInstance(applicationContext)
                }
            }
            else  if(call.method == "uaeInstance") {

                clevertapAdditionalInstanceConfig = CleverTapInstanceConfig.createInstance(
                    this,
                    "TEST-RZ7-Z94-K95Z",
                    "TEST-4c1-a12"
                )

                clevertapAdditionalInstanceConfig!!.setDebugLevel(CleverTapAPI.LogLevel.DEBUG)
                clevertapAdditionalInstanceConfig!!.isAnalyticsOnly = false
                clevertapAdditionalInstanceConfig!!.useGoogleAdId(false)
                clevertapAdditionalInstanceConfig!!.enablePersonalization(false)

                clevertapAdditionalInstance = CleverTapAPI.instanceWithConfig(applicationContext, clevertapAdditionalInstanceConfig)
                (application as AppFCT).setCleverTapMethods()

                result.success(clevertapAdditionalInstance)

            }
            else{
                Log.e("TAG", "configureFlutterEngine: ")
            }
        }
    }
//override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//    super.configureFlutterEngine(flutterEngine)
//    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "example.com/channel").setMethodCallHandler {
//      call, result ->
//        if(call.method == "getRandomNumber") {
//          val rand = Random.nextInt(100)
//          result.success(rand)
//        }
//        else {
//          result.notImplemented()
//        }
//    }
//  }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        CleverTapAPI.getDefaultInstance(applicationContext)
            ?.pushNotificationClickedEvent(intent.extras)

//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//            AppFCT.NotificationUtils.dismissNotification(activity.intent, applicationContext)
//        }
    }

//    private val CHANNEL = "myChannel"
//
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//
//        Log.e("qwertyuio","123456789")
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//            if (call.method == "recordEvent") {
//                    // Call your native Android method here
//                    // For example: nativeMethodImplementation()
//
//                val preferences = applicationContext.getSharedPreferences("WizRocket", MODE_PRIVATE)
//                val editor = preferences.edit()
//                val allEntries: Map<String, *> = preferences.all
//
//                for ((key, value) in allEntries) {
//                    println("key12345678 $key : $value")
//                }
//
//
//                    result.success(null)
//                } else {
//                    result.notImplemented()
//                }
//            }
//    }
}
