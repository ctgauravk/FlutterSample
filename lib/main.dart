import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

GlobalKey globalKey = GlobalKey();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const methodChannelName = "nativeMethodCallHandler";

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter SDK Integration'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var inboxInitialized = false;
  late CleverTapPlugin _clevertapPlugin;
  var optOut = false;
  var offLine = false;
  var enableDeviceNetworkingInfo = false;
  String appGroupID = 'group.flutter.fct';

  //for killed state notification clicked
  static const platform = MethodChannel("myChannel");

  Map<String, dynamic> myParams = {
    'email': 'null'
  };
  @override
  void initState() {
    super.initState();

    CleverTapPlugin.setDebugLevel(3);

    if (kIsWeb) {
      CleverTapPlugin.init("6ZR-965-446Z", "eu1",null);
      CleverTapPlugin.setDebugLevel(3);

    }
    initPlatformState();
    activateCleverTapFlutterPluginHandlers();
    CleverTapPlugin.createNotificationChannelGroup("groupId", "groupName");


    // CleverTapPlugin.enableDeviceNetworkInfoReporting(true);
    CleverTapPlugin.createNotificationChannel(
        "euro", "Test Notification Flutter", "Flutter Test", 5, true);
    CleverTapPlugin.createNotificationChannelWithGroupId(
        "gtid1", "Test Notification Flutter", "Flutter Test", 5, "groupId", true);

    CleverTapPlugin.createNotificationChannelWithGroupId(
        "gtid2", "Test Notification Flutter", "Flutter Test", 5, "groupId", true);
    var stuff = ["bags", "shoes"];
    CleverTapPlugin.onUserLogin({
      'Name': 'Test 28',
      'Identity': 'test45',
      'Email': 'test45@test.com',
      'Phone': '+14364532109',
      'MSG-email': true,
      'MSG-push': true,
      'MSG-sms': true,
      'MSG-whatsapp': true,
      'DOB':'23-06-2001'
    });
    SharedPreferenceAppGroup.setString('email', 'test28@test.com');
    // getMyParams();

    //For Killed State Handler
    platform.setMethodCallHandler(nativeMethodCallHandler);

    CleverTapPlugin.initializeInbox();
    var initURl = CleverTapPlugin.getInitialUrl();
    print("URL = $initURl");


  }

  Future<void> getMyParams() async {
    String stringValue = await SharedPreferenceAppGroup.get('email');

    this.myParams = {
      'email': stringValue
    };

    print("From app groups $stringValue");

    String text = '';
    for (String key in this.myParams.keys) {
      text += '$key = ${this.myParams[key]}\n';
      print("Inside for loop $text");
    }


  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
  }

  void inAppNotificationButtonClicked(Map<String, dynamic>? map) {
    setState(() {
      print("InApp called = ${map.toString()}");
    });
  }

  void activateCleverTapFlutterPluginHandlers() {
    _clevertapPlugin = CleverTapPlugin();

    //Handler for receiving Push Clicked Payload in FG and BG state
    _clevertapPlugin.setCleverTapPushClickedPayloadReceivedHandler(
        pushClickedPayloadReceived);
    _clevertapPlugin.setCleverTapInboxDidInitializeHandler(inboxDidInitialize);
    _clevertapPlugin
        .setCleverTapDisplayUnitsLoadedHandler(onDisplayUnitsLoaded);
    _clevertapPlugin.setCleverTapInAppNotificationButtonClickedHandler(
        inAppNotificationButtonClicked);
  }


  //For Push Notification Clicked Payload in FG and BG state
  void pushClickedPayloadReceived(Map<String, dynamic> map) {
    print("pushClickedPayloadReceived called");

    var d1 = jsonEncode(map);
    Fluttertoast.showToast(
        msg: " ${d1.length}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );

    setState(() async {
      var data = jsonEncode(map);
      print("on Push Click Payload = $data");
    });
  }

  //For Push Notification Clicked Payload in killed state
  Future<dynamic> nativeMethodCallHandler(MethodCall methodCall) async {
    print("killed state called!");


    switch (methodCall.method) {
      case "pushClickedResponse":
        debugPrint("onPushNotificationClicked in dart");
        debugPrint("Clicked Payload in Killed state: ${methodCall.arguments}");
        Fluttertoast.showToast(
            msg: " {user}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );

        return "This is from iOS!!";
      default:
        return "Nothing";
    }
  }

  void inboxDidInitialize() {
    setState(() {
      debugPrint("inboxDidInitialize called");
      inboxInitialized = true;
    });
  }

  void onDisplayUnitsLoaded(List<dynamic>? displayUnits) {
    setState(() async {
      List? displayUnits = await CleverTapPlugin.getAllDisplayUnits();
      debugPrint("native display called");
      debugPrint("Display Units are " + displayUnits.toString());
      getAdUnits();

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              color: Colors.grey.shade300,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: const Text("Profile push"),
                  subtitle: const Text("push your profile"),
                  onTap: login,
                ),
              ),
            ),
            Card(
              color: Colors.grey.shade300,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: const Text("Push Event"),
                  subtitle: const Text("Pushes/Records an event"),
                  onTap: recordEvent,
                ),
              ),
            ),
            Card(
              color: Colors.grey.shade300,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: const Text("Notification Event"),
                  subtitle: const Text("Pushes Notification"),
                  onTap: pushNotification,
                ),
              ),
            ),
            Card(
              color: Colors.grey.shade300,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: const Text("InApp Event"),
                  subtitle: const Text("Pushes InApp Notification"),
                  onTap: inAppNotification,
                ),
              ),
            ),
            Card(
              color: Colors.grey.shade300,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: const Text("App Inbox Event"),
                  subtitle: const Text("Pushes App Inbox Messages"),
                  onTap: appInbox,
                ),
              ),
            ),
            Card(
              color: Colors.grey.shade300,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: const Text("Native Display"),
                  subtitle: const Text("Returns all Display Units set"),
                  onTap: nativeDisplay,
                ),
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void login() {
    
    var profile = {
      'Photo':
      "https://i.pinimg.com/originals/39/95/65/399565162c331db08fde4211da835551.jpg",
      'Name':'Gaurav 12',
      'Phone':null
    };
    CleverTapPlugin.profileSet(profile);

    // CleverTapPlugin.onUserLogin({
    //   'Name': 'Test 66',
    //   'Identity': 'test66',
    //   'Email': 'test66@test.com',
    //   // 'Phone': '+14364532109',
    //   'MSG-email': true,
    //   'MSG-push': true,
    //   'MSG-sms': true,
    //   'MSG-whatsapp': true,
    //   'DOB':'23-06-2001'
    // });
    // showToast("Pushed profile " + profile.toString());
  }

  void recordEvent() {
    var eventData = {
      'Stuff': 'Shirt',
    };

    CleverTapPlugin.recordEvent("Button Click", eventData);
  }

  void pushNotification() {
    var eventData = {
      '': '',
    };
    CleverTapPlugin.recordEvent("Push Event", eventData);
  }

  void inAppNotification() {
    var eventData = {
      '': '',
    };
    CleverTapPlugin.recordEvent("InApp Event", eventData);
  }


  // void inAppNotificationButtonClicked(Map<String, dynamic> map) {
  //   this.setState(() {
  //     print("inAppNotificationButtonClicked called = ${map.toString()}");
  //   });
  // }

  void appInbox() {
    var eventData = {
      'data': 'content',
    };
    CleverTapPlugin.recordEvent("App Inbox Event", eventData);
    showInbox();
  }

  void showInbox() {
    var styleConfig = {
      'noMessageTextColor': '#ff6600',
      'noMessageText': 'No message(s) to show.',
      'navBarTitle': 'App Inbox'
    };
    CleverTapPlugin.showInbox(styleConfig);
  }

  void nativeDisplay() {
    var eventData = {
      '': '',
    };
    CleverTapPlugin.recordEvent("Native Display Event", eventData);

    CleverTapPlugin.recordEvent("Native Display Event2", eventData);

  }

  void getAdUnits() {
    this.setState(() async {
      List? displayUnits = await CleverTapPlugin.getAllDisplayUnits();
      print("Display Units Payload = " + displayUnits.toString());

      displayUnits?.forEach((element) {
        var customExtras = element["custom_kv"];
        if (customExtras != null) {
          print("Display Units CustomExtras: " +  customExtras.toString());
        }
      });
    });
  }
  //
  // void getAdUnits() async {
  //   debugPrint("GetAdunits");
  //   var displayUnits = await CleverTapPlugin.getAllDisplayUnits();
  //
  //   if(displayUnits!.contains("native display event2")){
  //     debugPrint("event2 true");
  //   }
  //   else{
  //     debugPrint("event2 false");
  //   }
  //
  //   if(displayUnits!.contains("native display event3")) {
  //     debugPrint("event1 true");
  //   }else{
  //     debugPrint("event1 false");
  //   }
  //
  //
  //   var a = "";
  //   for (var i in displayUnits!) {
  //     a = i;
  //   }
  //   var decodedJson = json.decode(a);
  //   var jsonValue = json.decode(decodedJson['content']);
  //   debugPrint("value12345 = " + jsonValue['message']);
  //   for (var i = 0; i < displayUnits.length; i++) {
  //     var units = displayUnits[i];
  //     displayText(units);
  //     debugPrint("units1234= " + units.toString());
  //   }
  //   for (var element in displayUnits) {
  //     debugPrint("units123456= " + element[1].toString());
  //   }
  // }

  void displayText(units) {
    for (var i = 0; i < units.length; i++) {
      debugPrint("title= " + units[i].toString());
    }
  }
}