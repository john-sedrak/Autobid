import 'package:autobid/Classes/UserModel.dart';
import 'package:autobid/Utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path/path.dart';

class MainDrawer extends StatelessWidget {
  final UserModel current;
  const MainDrawer({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Column(
          children: [
            Container(
              height: 90 + MediaQuery.of(context).viewPadding.top,
              width: double.infinity,
              padding: EdgeInsets.only(bottom: 10, left: 10),
              alignment: Alignment.bottomLeft,
              color: Theme.of(context).colorScheme.secondary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // const Text('AutoBid',
                  //     style: TextStyle(
                  //         fontSize: 24,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.white)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 25,
                          child: Text(
                            current.name.substring(0, 1),
                            style: TextStyle(fontSize: 25, color: Colors.pink),
                          )),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Text(
                          current.name,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            // const SizedBox(
            //   height: 20,
            // ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {
                var userID = FirebaseAuth.instance.currentUser!.uid;
                FirebaseAuth.instance.signOut().then((value) =>
                    FirebaseFirestore.instance
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
