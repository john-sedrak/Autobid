import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart';

import '../Classes/Car.dart';
import '../Utils/utils.dart';

class LocalNotificationService {
  static final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static FlutterLocalNotificationsPlugin get localNotificationService =>
      _localNotificationsPlugin;

  static BuildContext? _context;
  static void setContext(BuildContext context) =>
      LocalNotificationService._context = context;

  static BuildContext? _chatContext;
  static BuildContext? get chatContext => _chatContext;
  static void setChatContext(BuildContext? chatContext) =>
      LocalNotificationService._chatContext = chatContext;

  static Future<void> setup() async {
    const androidSetting = AndroidInitializationSettings('flutter_logo');
    const iosSetting = DarwinInitializationSettings();

    const initSettings =
        InitializationSettings(android: androidSetting, iOS: iosSetting);

    await _localNotificationsPlugin
        .initialize(
      initSettings,
      onDidReceiveNotificationResponse: onTapNotification,
      onDidReceiveBackgroundNotificationResponse: onTapNotification,
    )
        .then((_) {
      print('setupPlugin: setup success');
    }).catchError((Object error) {
      print('Error: $error');
    });

    await _createNotificationChannel(
            "Updates", "Chat", "Channel for incoming chats")
        .then((value) => print('channel success'))
        .catchError((onError) {
      print("channel error");
    });
  }

  static void onTapNotification(NotificationResponse response) {
    print("tapped");
    print(_context);
    print(response.payload);
    print(_context == null);
    print(response.payload == null);
    if (_context == null || response.payload == null) {
      print('in if');
      return;
    }

    var message = jsonDecode(response.payload!);
    print(message);

    if (message['screen'] == '/messages') {
      FirebaseFirestore.instance
          .doc(message['senderRef'])
          .get()
          .then((otherChatter) {
        if (Navigator.canPop(_context!)) {
          Navigator.of(_context!).pushReplacementNamed(message['screen'],
              arguments: {'otherChatter': otherChatter});
        } else {
          Navigator.of(_context!).pushNamed(message['screen'],
              arguments: {'otherChatter': otherChatter});
        }
      });
    } else if (message.data['screen'] == '/bidRoot') {
        String carId = message.data['carId'];
        FirebaseFirestore.instance.doc("Cars/$carId").get().then((value) {
          Map<String, dynamic> carMap = value.data() as Map<String, dynamic>;
          Car car = Utils.mapToCar(carId, carMap);

          if (Navigator.canPop(_context!)) {
            Navigator.of(_context!).pushReplacementNamed('/bidRoute',
                arguments: {'car': car, 'isExpanded': true});
          } else {
            Navigator.of(_context!).pushNamed('/bidRoute',
                arguments: {'car': car, 'isExpanded': true});
          }
        });
      } else if (message.data['screen'] == "/myListingRoute") {
        String carId = message.data['carId'];
        FirebaseFirestore.instance.doc("Cars/$carId").get().then((value) {
          Map<String, dynamic> carMap = value.data() as Map<String, dynamic>;
          Car car = Utils.mapToCar(carId, carMap);

          if (Navigator.canPop(_context!)) {
            Navigator.of(_context!).pushReplacementNamed('/myListingRoute',
                arguments: {'car': car});
          } else {
            Navigator.of(_context!)
                .pushNamed('/myListingRoute', arguments: {'car': car});
          }
        });
      }
  }

  static Future<void> _createNotificationChannel(
      String id, String name, String description) async {
    var androidNotificationChannel = AndroidNotificationChannel(
      id,
      name,
      description: description,
    );
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  static NotificationDetails platformChannelSpecifics =
      const NotificationDetails(
    android: AndroidNotificationDetails(
      "high_importance_channel",
      "High Importance Notifications",
      priority: Priority.max,
      importance: Importance.max,
    ),
  );
}
