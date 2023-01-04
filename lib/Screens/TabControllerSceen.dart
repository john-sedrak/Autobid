import 'package:autobid/Classes/Car.dart';
import 'package:autobid/Classes/UserModel.dart';
import 'package:autobid/Custom/CustomAppBar.dart';
import 'package:autobid/Custom/MainDrawer.dart';
import 'package:autobid/Utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

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

  UserModel? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      isLoading = true;
    });
    String userID = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userID)
        .get()
        .then((snap) {
      Map<String, dynamic> curMap = snap.data() as Map<String, dynamic>;
      currentUser = Utils.mapToUser(userID, curMap);
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      print(e);
    });

    FirebaseMessaging.instance
        .getToken()
        .then((value) => print("token:  $value"));

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('opened notification');

      if (message.data['screen'] == '/messages') {
        FirebaseFirestore.instance
            .doc(message.data['senderRef'])
            .get()
            .then((otherChatter) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pushReplacementNamed(message.data['screen'],
                arguments: {'otherChatter': otherChatter});
          } else {
            Navigator.of(context).pushNamed(message.data['screen'],
                arguments: {'otherChatter': otherChatter});
          }
        });
      } else if (message.data['screen'] == '/bidRoot') {
        String carId = message.data['carId'];
        FirebaseFirestore.instance.doc("Cars/$carId").get().then((value) {
          Map<String, dynamic> carMap = value.data() as Map<String, dynamic>;
          Car car = Utils.mapToCar(carId, carMap);

          if (Navigator.canPop(context)) {
            Navigator.of(context).pushReplacementNamed('/bidRoute',
                arguments: {'car': car, 'isExpanded': true});
          } else {
            Navigator.of(context).pushNamed('/bidRoute',
                arguments: {'car': car, 'isExpanded': true});
          }
        });
      } else if (message.data['screen'] == "/myListingRoute") {
        String carId = message.data['carId'];
        FirebaseFirestore.instance.doc("Cars/$carId").get().then((value) {
          Map<String, dynamic> carMap = value.data() as Map<String, dynamic>;
          Car car = Utils.mapToCar(carId, carMap);

          if (Navigator.canPop(context)) {
            Navigator.of(context).pushReplacementNamed('/myListingRoute',
                arguments: {'car': car});
          } else {
            Navigator.of(context)
                .pushNamed('/myListingRoute', arguments: {'car': car});
          }
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            appBar: CustomAppBar(title: labels[pageIndex]),
            body: const Center(
                child: CircularProgressIndicator(
              color: Colors.pink,
            )))
        : Scaffold(
            appBar: CustomAppBar(title: labels[pageIndex]),
            drawer: MainDrawer(current: currentUser!),
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
