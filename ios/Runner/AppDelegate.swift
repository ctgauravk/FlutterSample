import UIKit
import CleverTapSDK
import clevertap_plugin
import Flutter
@available(iOS 10.0, *)
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, CleverTapURLDelegate, CleverTapPushNotificationDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "myChannel", binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "callAppDelegateFunction" {
                self.callYourAppDelegateFunction()
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        GeneratedPluginRegistrant.register(with: self)
        registerPush()
        CleverTap.autoIntegrate() // integrate CleverTap SDK using the autoIntegrate option
        CleverTapPlugin.sharedInstance()?.applicationDidLaunch(options: launchOptions)
        UNUserNotificationCenter.current().delegate = self
        CleverTap.sharedInstance()?.setUrlDelegate(self)
        CleverTap.sharedInstance()?.setPushNotificationDelegate(self)
        let defaults = UserDefaults.init(suiteName: "group.clevertap.fdemo")
        
        
//        CleverTap.sharedInstance()?.notifyApplicationLaunched(withOptions: self)
        let email2 = defaults?.value(forKey: "email")
        
        print("email2 \(email2)")
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func shouldHandleCleverTap(_ url: URL?, for channel: CleverTapChannel) -> Bool {
        print("Handling URL by CT App: \(url!) for channel: \(channel)")
        
        return true
    }
    
    
    private func registerPush() {
        UNUserNotificationCenter.current().delegate = self
        let action1 = UNNotificationAction(identifier: "action_1", title: "Back", options: [])
        let action2 = UNNotificationAction(identifier: "action_2", title: "Next", options: [])
        let action3 = UNNotificationAction(identifier: "action_3", title: "View In App", options: [])
        let category = UNNotificationCategory(identifier: "CTNotification", actions: [action1, action2, action3], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        // request permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) {
            (granted, error) in
            if (granted) {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    private func application(application: UIApplication,
                             didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("token",token)
        CleverTap.sharedInstance()?.setPushToken(deviceToken as Data)
        UserDefaults.standard.set(deviceToken, forKey: "ct_push_token")
        
        let token1 =  UserDefaults.standard.data(forKey: "ct_push_token")
        print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \(token1)")
        
    }
    
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            //      for manual integration
            //      CleverTap.sharedInstance()?.handleNotification(withData: notification.request.content.userInfo, openDeepLinksInForeground: true)
            completionHandler([.badge, .sound, .alert])
        }
    
    
    
    //notification clicks
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         didReceive response: UNNotificationResponse,
                                         withCompletionHandler completionHandler: @escaping () -> Void) {
        
        var channel: FlutterMethodChannel?
        if let controller = self.window?.rootViewController as? FlutterViewController {
            channel = FlutterMethodChannel(name: "myChannel", binaryMessenger: controller.binaryMessenger)
            channel?.invokeMethod("pushClickedResponse", arguments: response.notification.request.content.userInfo)
        }
        completionHandler()
        
    }
    
    public func callYourAppDelegateFunction(){
        print("mthodchannel called")
        
        
        
        guard let accId = CleverTap.sharedInstance()?.config.accountId else {
            return
        }
        
      
        
        let fileName = "clevertap-\(accId)-userprofile.plist"
        let appDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last
        let filePath = "\(appDir!)/\(fileName)"
        if FileManager.default.fileExists(atPath: filePath) {
            try! FileManager.default.removeItem(atPath: filePath)
        }

        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if key.contains("WizRocket"){
//                print("key \(key)")
                if(key != "WizRocketdevice_token" || key != "WizRocketfirstTime"){
                    defaults.removeObject(forKey: key)
                }
            }
        }
        defaults.synchronize()
                
        
    }
}
