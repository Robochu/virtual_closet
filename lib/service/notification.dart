// Sending user notifications class
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Singleton object
  static final NotificationService _notificationService =
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  //FlutterLocalNotificationsPlugin initialize for IOS and Android
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
}