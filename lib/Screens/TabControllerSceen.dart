import 'package:autobid/Classes/Car.dart';
import 'package:autobid/Custom/CustomAppBar.dart';
import 'package:autobid/Custom/MainDrawer.dart';
import 'package:autobid/Utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import '../Services/local_notification_service.dart';
import 'ChatsScreen.dart';
import 'ExploreScreen.dart';
import 'FavoritesScreen.dart';
import 'ListingsScreen.dart';

class TabControllerScreen extends StatefulWidget {
  const TabControllerScreen({super.key});

  @override
  State<TabControllerScreen> createState() => _TabControllerScreenState();
}

class _TabControllerScreenState extends State<TabControllerScreen> {
  final List<Widget> pages = [
    const ExploreScreen(),
    const ChatsScreen(),
    const ListingsScreen(),
    const FavoritesScreen()
  ];

  final List<String> labels = [
    'Explore',
    'Chats',
    'Listings',
    'Following',
  ];

  int pageIndex = 0;

  void pageSelect(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  void goToAddCar(BuildContext context) {
    Navigator.of(context).pushNamed('/addCar');
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocalNotificationService.setContext(context);
    });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: labels[pageIndex]),
      drawer: const MainDrawer(),
      body: pages[pageIndex],
      floatingActionButton: pageIndex == 0 || pageIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                goToAddCar(context);
              },
              backgroundColor: Colors.pink,
              child: const Icon(Icons.add),
            )
          : Container(),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: false,
        // type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: labels[0]),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded), label: labels[1]),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded), label: labels[2]),
          BottomNavigationBarItem(
              icon: Icon(Icons.star_rounded), label: labels[3])
        ],
        currentIndex: pageIndex,
        onTap: pageSelect,
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
