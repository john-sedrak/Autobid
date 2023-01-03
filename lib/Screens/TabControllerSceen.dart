import 'package:autobid/Custom/CustomAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
    'Favorites'
  ];

  int pageIndex = 0;

  void pageSelect(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        print('opened notification');
        
        FirebaseFirestore.instance.doc(message.data['senderRef']).get().then((otherChatter){
            Navigator.of(context).pushNamed(message.data['screen'],
              arguments: {'otherChatter': otherChatter});
        });

      });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: labels[pageIndex]),
      body: pages[pageIndex],
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
    );
  }
}
