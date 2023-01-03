import 'package:autobid/Screens/AuthenticationScreens/LoginScreen.dart';
import 'package:autobid/Screens/AuthenticationScreens/WelcomeScreen.dart';
import 'package:flutter/material.dart';
import 'Screens/TabControllerSceen.dart';
import 'package:firebase_core/firebase_core.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _error = false;

  void initializeFlutterFire() async {
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
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "AutoBid",
        theme: ThemeData(
          colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: Colors.white,
            onPrimary: Colors.black,
            secondary: Colors.pink.shade300,
            onSecondary: Colors.white,
            error: Colors.white,
            onError: Colors.pink.shade300,
            background: Colors.grey.shade300,
            onBackground: Colors.black,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          appBarTheme:
              AppBarTheme(elevation: 0, backgroundColor: Colors.grey.shade300),
          scaffoldBackgroundColor: Colors.grey.shade300,
          //useMaterial3: true
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const TabControllerScreen()
        });
  }
}
