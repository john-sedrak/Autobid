import 'package:flutter/material.dart';

import 'Screens/TabControllerSceen.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        appBarTheme: AppBarTheme(elevation: 0, backgroundColor: Colors.grey.shade300),
        scaffoldBackgroundColor: Colors.grey.shade300,
        
      ),
      initialRoute: '/',
      routes:{
        '/': (context) => const TabControllerScreen(),
      }
    );
  }
}
