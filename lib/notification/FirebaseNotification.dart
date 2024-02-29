import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotification {
  final _firebaseMessaging = FirebaseMessaging.instance;

  _mapMessageToUser(RemoteMessage message) {
    Map<String, dynamic> json = message.data;
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Handling a background message ${message.messageId}');
  }

  Future<void> initNotification () async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    final token = await _firebaseMessaging.getToken();
    print('User granted permission: ${settings.authorizationStatus} token: $token');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<void> setUpInteractedMessage() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    ///Configure notification permissions
    //IOS
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    //Android
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    log('User granted permission: ${settings.authorizationStatus}');

    //Get the message from tapping on the notification when app is not in foreground
    RemoteMessage? initialMessage = await messaging.getInitialMessage();

    if (initialMessage != null) {
      await _mapMessageToUser(initialMessage);
    }

    //This listens for messages when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_mapMessageToUser);

    //Listen to messages in Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      //Initialize FlutterLocalNotifications
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'schedular_channel', // id
        'Schedular Notifications', // title
        description:
        'This channel is used for Schedular app notifications.', // description
        importance: Importance.max,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      //Construct local notification using our created channel
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: "@mipmap/ic_launcher",
              ),
            ));
      }
    });
  }
}

