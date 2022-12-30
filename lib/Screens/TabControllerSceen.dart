import 'package:autobid/Custom/CustomAppBar.dart';
import 'package:flutter/material.dart';

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
    'Favorites',
  ];

  int pageIndex = 0;

  void pageSelect(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: labels[pageIndex]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
      body: pages[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedItemColor: Colors.pink,
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
