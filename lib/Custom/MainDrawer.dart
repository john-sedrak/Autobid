import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width*0.75,
        child: Column(
      children: [
        Container(
          height: 90 + MediaQuery.of(context).viewPadding.top,
          width: double.infinity,
          padding: EdgeInsets.only(bottom:15, left: 20),
          alignment: Alignment.bottomLeft,
          color: Theme.of(context).colorScheme.secondary,
          child: const Text('AutoBid',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        // const SizedBox(
        //   height: 20,
        // ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text("Logout"),
          onTap: () {
            var userID = FirebaseAuth.instance.currentUser!.uid;
            FirebaseAuth.instance.signOut().then((value) => FirebaseFirestore
                .instance
                .doc('Users/${userID}')
                .update({'notifToken': ""}));

            Navigator.of(context).pushReplacementNamed('/login');
          },
        ),
        // ListTile(leading: Icon(Icons.settings), title: Text("Settings"), onTap: (){Navigator.of(context).pushNamed('/settingsRoute');},)
      ],
    ));
  }
}
