import 'package:autobid/Classes/UserModel.dart';
import 'package:autobid/Providers/UserProvider.dart';
import 'package:autobid/Screens/AuthenticationScreens/ForgetPasswordScreen.dart';
import 'package:autobid/Screens/AuthenticationScreens/LoginScreen.dart';
import 'package:autobid/Screens/AuthenticationScreens/WelcomeScreen.dart';
import 'package:autobid/Screens/MessagesScreen.dart';
import 'package:autobid/Screens/BiddingScreen.dart';
import 'package:autobid/Screens/AddCarScreen.dart';
import 'package:autobid/Screens/myListingScreen.dart';
import 'package:autobid/Screens/EditCarScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'Screens/TabControllerSceen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main(List<String> args) {
  runApp(MyApp());
  FirebaseMessaging.onBackgroundMessage(background_notif_handler);
}

Future<void> background_notif_handler(RemoteMessage message) async {
//await Firebase.initializeApp();
  print("Handling a background message: ${message.data}");
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
      FirebaseMessaging.onMessage.listen((message) {
        print(message.data.toString());
      });
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
                  '/forgetPassword': (context) => const ForgetPasswordScreen(),
                  '/': (context) => const TabControllerScreen(),
                  '/bidRoute': (context) => const BiddingScreen(),
                  '/myListingRoute': (context) => const MyListingScreen(),
                  '/addCar': (context) => const AddCarScreen(),
                  '/messages': (context) => MessagesScreen(),
                  '/edit': (context) => EditScreen()
                }),
          )
        : Container(
            color: Colors.grey.shade300,
          );
  }
}
