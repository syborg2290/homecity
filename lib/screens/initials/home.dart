import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nearby/config/settings.dart';
import 'package:nearby/screens/main/bookmarks.dart';
import 'package:nearby/screens/main/chat.dart';
import 'package:nearby/screens/main/mainPage.dart';
import 'package:nearby/screens/main/notification.dart';
import 'package:nearby/screens/main/profile.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/utils/pallete.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController pageController;
  AuthServcies _authSerivice = AuthServcies();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  int pageIndex = 0;
  String currentUserId;

  @override
  void initState() {
    super.initState();
    _authSerivice.getCurrentUser().then((user) {
      setState(() {
        currentUserId = user.uid;
      });
    });
    pageController = PageController();
    checkLocationPermission();

    initializeLocalNotification();

    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(
          IosNotificationSettings(alert: true, badge: true, sound: true));
      _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
        print('Settings Registered:$settings');
      });
    } else {
      _firebaseMessaging.configure(onLaunch: (Map<String, dynamic> msg) {
        _showNotificationWithSound(msg);
      }, onResume: (Map<String, dynamic> msg) {
        _showNotificationWithSound(msg);
      }, onMessage: (Map<String, dynamic> msg) {
        _showNotificationWithSound(msg);
      });
    }
  }

  initializeLocalNotification() {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    // If you have skipped STEP 3 then change app_icon to @mipmap/ic_launcher
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
  }

  Future onSelectNotification(String payload) async {
    Map<String, dynamic> re = json.decode(payload);
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(url == "null" ? Null_user : url);
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future _showNotificationWithSound(Map<String, dynamic> message) async {
    String path =
        await _downloadAndSaveFile(message["data"]["userImage"], "userImage");

    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      currentUserId,
      currentUserId,
      'your channel description',
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      importance: Importance.Max,
      priority: Priority.High,
      playSound: true,
      enableLights: true,
      color: Pallete.mainAppColor,
      ledColor: Pallete.mainAppColor,
      ledOnMs: 1000,
      ledOffMs: 500,
      sound: RawResourceAndroidNotificationSound('swiftly'),
      largeIcon: FilePathAndroidBitmap(path),
      styleInformation: MediaStyleInformation(),

      //ongoing: true,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      message["data"]["username"],
      message["notification"]["body"],
      platformChannelSpecifics,
      payload: json.encode(message),
    );
  }

  checkLocationPermission() async {
    var statusIn = await Permission.locationWhenInUse.status;
    if (statusIn.isUndetermined) {
      var statusInRe = await Permission.locationWhenInUse.request();
      if (statusInRe.isGranted) {}
    }

    if (statusIn.isGranted) {
    } else {
      var statusReIn2 = await Permission.locationWhenInUse.request();
      if (statusReIn2.isGranted) {}
    }
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return WillPopScope(
      onWillPop: () async {
        AwesomeDialog(
          context: context,
          animType: AnimType.SCALE,
          dialogType: DialogType.NO_HEADER,
          body: Center(
            child: Text(
              'Are you sure to continue?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          btnOkColor: Pallete.mainAppColor,
          btnCancelColor: Pallete.mainAppColor,
          btnOkText: 'Yes',
          btnCancelText: 'No',
          btnOkOnPress: () {
            exit(0);
          },
          btnCancelOnPress: () {},
        )..show();
        return false;
      },
      child: Scaffold(
        body: Container(
          width: width,
          height: height,
          child: PageView(
            allowImplicitScrolling: true,
            children: <Widget>[
              MainPage(),
              Notify(),
              Chat(),
              Bookmarks(),
              Profile(
                profileId: currentUserId,
              ),
            ],
            controller: pageController,
            onPageChanged: onPageChanged,
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(2), topLeft: Radius.circular(2)),
            boxShadow: [
              BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 0),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(2.0),
              topRight: Radius.circular(2.0),
            ),
            child: BottomAppBar(
              shape: CircularNotchedRectangle(),
              notchMargin: 2.0,
              elevation: 2.0,
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: 55,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      iconSize: pageIndex == 0 ? 35.0 : 30.0,
                      padding: EdgeInsets.only(left: 28.0),
                      icon: Image(
                        image: AssetImage("assets/icons/home.png"),
                        color: pageIndex == 0
                            ? Pallete.mainAppColor
                            : Colors.black54,
                      ),
                      onPressed: () {
                        onTap(0);
                      },
                    ),
                    IconButton(
                      iconSize: pageIndex == 1 ? 35.0 : 30.0,
                      padding: EdgeInsets.only(
                        right: 14.0,
                        left: 14,
                      ),
                      icon: Image(
                        image: AssetImage("assets/icons/bell.png"),
                        color: pageIndex == 1
                            ? Pallete.mainAppColor
                            : Colors.black54,
                      ),
                      onPressed: () {
                        onTap(1);
                      },
                    ),
                    IconButton(
                      iconSize: pageIndex == 2 ? 35.0 : 30.0,
                      padding: EdgeInsets.only(
                        right: 14.0,
                        left: 14.0,
                      ),
                      icon: Image(
                        image: AssetImage("assets/icons/chat.png"),
                        color: pageIndex == 2
                            ? Pallete.mainAppColor
                            : Colors.black54,
                      ),
                      onPressed: () {
                        onTap(2);
                      },
                    ),
                    IconButton(
                      iconSize: pageIndex == 3 ? 35.0 : 30.0,
                      padding: EdgeInsets.only(
                        right: 14.0,
                        left: 14.0,
                      ),
                      icon: Image(
                        image: AssetImage("assets/icons/bookmark.png"),
                        color: pageIndex == 3
                            ? Pallete.mainAppColor
                            : Colors.black54,
                      ),
                      onPressed: () {
                        onTap(3);
                      },
                    ),
                    IconButton(
                      iconSize: pageIndex == 4 ? 35.0 : 30.0,
                      padding: EdgeInsets.only(right: 28.0),
                      icon: Image(
                        image: AssetImage("assets/icons/user.png"),
                        color: pageIndex == 4
                            ? Pallete.mainAppColor
                            : Colors.black54,
                      ),
                      onPressed: () {
                        onTap(4);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
