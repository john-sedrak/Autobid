import 'dart:convert';

import 'package:autobid/Providers/UserProvider.dart';
import 'package:autobid/Screens/AuthenticationScreens/LoginScreen.dart';
import 'package:autobid/Screens/AuthenticationScreens/WelcomeScreen.dart';
import 'package:autobid/Screens/MessagesScreen.dart';
import 'package:autobid/Screens/BiddingScreen.dart';
import 'package:autobid/Screens/AddCarScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'Screens/TabControllerSceen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'Services/local_notification_service.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationService.setup();
  runApp(MyApp());
  FirebaseMessaging.onBackgroundMessage(notifHandler);
}

Future<void> notifHandler(RemoteMessage message) async {
//await Firebase.initializeApp();
  print("Handling message: ${message.data}");

  print(LocalNotificationService.chatContext);
  if (LocalNotificationService.chatContext != null) {
  var routeArgs = ModalRoute.of(LocalNotificationService.chatContext!)!.settings.arguments
      as Map<String, dynamic>;
      print(message.data['senderRef']);
      print(routeArgs['otherChatter'].reference.path);
  if (routeArgs['otherChatter'] != null &&
      message.data['senderRef'] == routeArgs['otherChatter'].reference.path) {
    return;
  }
  print(routeArgs['otherChatterRef']);
  if (routeArgs['otherChatterRef'] != null &&
      message.data['senderRef'] == routeArgs['otherChatterRef']) {
    return;
  }
}

  LocalNotificationService.localNotificationService.show(
    0,
    message.data['title'],
    message.data['body'],
    LocalNotificationService.platformChannelSpecifics,
    payload: jsonEncode(message.data)
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _error = false;
  var auth;

  Future<void> initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
        print("Connected to firebase");
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      print("error $e");
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire().then((_) {
      auth = FirebaseAuth.instance;
      var fbm = FirebaseMessaging.instance;
      fbm.requestPermission();
      FirebaseMessaging.onMessage.listen(notifHandler);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (_initialized)
        ? ChangeNotifierProvider(
            create: (ctx) => UserProvider(),
            child: MaterialApp(
                title: "AutoBid",
                theme: ThemeData(
                  colorScheme: ColorScheme(
                    brightness: Brightness.light,
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    secondary: Colors.pink,
                    onSecondary: Colors.white,
                    error: Colors.white,
                    onError: Colors.pink,
                    background: Colors.grey.shade300,
                    onBackground: Colors.black,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                  appBarTheme: AppBarTheme(
                      elevation: 0, backgroundColor: Colors.grey.shade300),
                  scaffoldBackgroundColor: Colors.grey.shade300,
                  //useMaterial3: true
                ),
                initialRoute: (auth != null && auth.currentUser == null)
                    ? '/welcome'
                    : '/',
                routes: {
                  '/welcome': (context) => const WelcomeScreen(),
                  '/login': (context) => const LoginScreen(),
                  '/': (context) => const TabControllerScreen(),
                  '/bidRoute': (context) => const BiddingScreen(),
                  '/addCar': (context) => const AddCarScreen(),
                  '/messages': (context) => MessagesScreen(),
                }),
          )
        : Container(
            color: Colors.grey.shade300,
          );
  }
}
