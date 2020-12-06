import 'dart:convert';
import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Controller {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Controller() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }
  initializeNotifications() async {
    try {
      var initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettingsIOS = IOSInitializationSettings();
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    } catch (e) {
      print(e);
    }
  }

  int makeIDs() {
    Random random = new Random();
    int randomNumber = random.nextInt(100);
    return randomNumber;
  }

  Future<void> scheduleNotification(
      id, content, RepeatInterval interval) async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID ' + id.toString(),
      'CHANNEL_NAME ' + id.toString(),
      "CHANNEL_DESCRIPTION " + id.toString(),
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(
      id,
      'Reminder',
      content,
      interval,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }

  Future<void> showNotification(id, content) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id, 'Reminder', content, platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> scheduledNotification(id, content) async {
    var scheduledNotificationDateTime =
        new DateTime.now().add(new Duration(seconds: 10));
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(id, 'Reminder', content,
        scheduledNotificationDateTime, platformChannelSpecifics);
    print("started");
  }
}
