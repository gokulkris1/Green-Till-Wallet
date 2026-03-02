import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/main.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/utils/shared_pref_helper.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _singleton = FirebaseMessagingService._init();

  factory FirebaseMessagingService() {
    return _singleton;
  }

  static String? token;

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;
  RemoteMessage? initialMessage;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  FirebaseMessagingService._init();

  Future<void> init() async {
    if (kIsWeb) {
      return;
    }
    await FirebaseMessaging.instance.requestPermission();

    channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    try {
      final value = await FirebaseMessaging.instance.getToken();
      if (value != null) {
        print("firebaselog: $value");
        SharedPrefHelper.instance
            .putString(SharedPrefHelper.FIREBASE_TOKEN, value);
      }
    } catch (e) {
      print("exception for fetch token ${e.toString()}");
    }

    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      print("notificationlog:" + message.toString());
      print("click for killed");
      print(message.data);
      Future.delayed(const Duration(milliseconds: 2000)).then((value) {
        print("In killed state");
        navigateToForKilledState(message.data, isKilled: true);
      });
    }
    channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    setupLocalNotification();
    setupOnMessage();
  }

  setupOnMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      final android = message.notification?.android;
      if (notification == null || android == null) {
        return;
      }
      FlutterAppBadger.updateBadgeCount(1);
      // final bigPicture = message.data["image"] != null? await DownloadUtil.downloadAndSaveFile(
      //     message.data["image"],
      //     "GreenTill"):null;
      isNotificationArrives = true;
      print("isnotificationarrive");
      print(isNotificationArrives);
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        "GreenTill",
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            color: colortheme,
          ),
        ),
        payload: json.encode(message.data),
      );
    });

    //background but app open and user taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("click for background");
      print(message.data.toString());
      print(message.data);
      Future.delayed(Duration(milliseconds: 500)).then((value) {
        print("In background");
        navigateToForKilledState(message.data, isKilled: false);
      });
    });
  }

  setupLocalNotification() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        final payload = details.payload;
        if (payload == null) return;
        print("notification payload=");
        print(payload);
        Future.delayed(const Duration(milliseconds: 500)).then((value) {
          print("IN app");
          navigateToForKilledState(jsonDecode(payload), isKilled: false);
        });
      },
    );

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  navigateToForKilledState(Map<String, dynamic> message, {bool isKilled = false}) {
    bool isLoggedIn =
        SharedPrefHelper.instance.getBool(SharedPrefHelper.IS_LOGGED_IN_BOOL);
    Future.delayed(Duration(milliseconds: 3000)).then((value) {
      final context = navigatorKey.currentContext;
      if (context == null) return;
      if (isLoggedIn) {
        print("messagetype");
        print(message["type"]);
        switch (message["type"]) {
          case "CUSTOM_NOTIFICATION":
            BlocProvider.of<MainBloc>(context).add(HomeScreenEvent());
            break;

          case "NEW_COUPONS":
            BlocProvider.of<MainBloc>(context).add(CouponsEvent());
            break;

          case "NEW_SHOPPING_LINK":
            BlocProvider.of<MainBloc>(context).add(ShoppingLinkEvent());
            break;

          case "NEW_SURVEY":
            BlocProvider.of<MainBloc>(context).add(SurveyEvent());
            break;

          case "NEW_REWARD":
            BlocProvider.of<MainBloc>(context).add(RewardScreenEvent());
            break;

          case "CLAIM_REWARD":
            BlocProvider.of<MainBloc>(context).add(RewardScreenEvent());
            break;
        }
        // BlocProvider.of<MainBloc>(navigatorKey.currentContext).add(EditProfile());
      } else {
        BlocProvider.of<MainBloc>(context).add(Login());
      }
    });
  }

// navigateTo(Map<String, dynamic> message) {
//   bool isLoggedIn =
//       SharedPrefHelper.instance.getBool(SharedPrefHelper.IS_LOGGED_IN_BOOL);
//   if (isLoggedIn) {
//     print("messagetype");
//     print(message["type"]);
//     switch (message["type"]) {
//       case "CUSTOM_NOTIFICATION":
//         BlocProvider.of<MainBloc>(navigatorKey.currentContext).add(HomeScreenEvent());
//         break;
//
//       case "NEW_COUPONS":
//         BlocProvider.of<MainBloc>(navigatorKey.currentContext).add(CouponsEvent());
//         break;
//
//       case "NEW_SHOPPING_LINK":
//         BlocProvider.of<MainBloc>(navigatorKey.currentContext).add(ShoppingLinkEvent());
//         break;
//
//       case "NEW_SURVEY":
//         BlocProvider.of<MainBloc>(navigatorKey.currentContext).add(SurveyEvent());
//         break;
//
//       case "NEW_REWARD":
//         BlocProvider.of<MainBloc>(navigatorKey.currentContext).add(RewardScreenEvent());
//         break;
//     }
//   } else {
//     BlocProvider.of<MainBloc>(navigatorKey.currentContext).add(Login());
//   }
// }
}

// class DownloadUtil {
//   static Future<String> downloadAndSaveFile(String url, String fileName) async {
//     final Directory directory = await getApplicationDocumentsDirectory();
//     final String filePath = '${directory.path}/$fileName.png';
//     final http.Response response = await http.get(Uri.parse(url));
//     final File file = File(filePath);
//     await file.writeAsBytes(response.bodyBytes);
//     print("filePath");
//     print(filePath);
//     return filePath;
//   }
// }
