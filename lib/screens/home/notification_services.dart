import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('iconNotif');
    const IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: null, 
            macOS: null
    );
    
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    tz.initializeTimeZones();
  }



  void showNotification(String notificationMessage) async {
    await flutterLocalNotificationsPlugin.show(
        123,
        'Virtual Closet',
        notificationMessage,
        const NotificationDetails(
            android: AndroidNotificationDetails('123', 'Virtual Closet',)
        ),
        payload: jsonEncode(123)
    );
  }

  void scheduleNotification(DateTime userInputTime, String notificationMessage) async {
    DateTime now = DateTime.now();
    Duration difference = now.isAfter(userInputTime)
        ? now.difference(userInputTime)
        : userInputTime.difference(now);

    _wasApplicationLaunchedFromNotification()
        .then((bool didApplicationLaunchFromNotification) => {
      if (didApplicationLaunchFromNotification && difference.inDays == 0) {
          // Do nothing
      }
      else if (!didApplicationLaunchFromNotification && difference.inDays == 0) {
          showNotification(notificationMessage)}
        });

    await flutterLocalNotificationsPlugin.zonedSchedule(
        123,
        'Virtual Closet',
        notificationMessage,
        tz.TZDateTime.now(tz.local).add(difference),
        const NotificationDetails(
            android: AndroidNotificationDetails('123', 'Virtual Closet',)),
        payload: jsonEncode(123),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }


  void cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void handleApplicationWasLaunchedFromNotification() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails!.didNotificationLaunchApp) {
      cancelAllNotifications();
      //scheduleNotification();
    }
  }


  Future<bool> _wasApplicationLaunchedFromNotification() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    return notificationAppLaunchDetails!.didNotificationLaunchApp;
  }
}