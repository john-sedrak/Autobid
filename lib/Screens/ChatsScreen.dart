import 'package:autobid/Custom/ChatTile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  bool _initialized = false;
  bool _error = false;

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized && !_error) {
      String user = 'RoFvf4QhbYY3dybd0nDulXzxLcK2';
      DocumentReference<Map<String, dynamic>> userRef =
          FirebaseFirestore.instance.doc('Users/' + user);
      var chatsInstance = FirebaseFirestore.instance
          .collection("Chats")
          .where('chatters', arrayContains: userRef)
          .snapshots();

      return Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: chatsInstance,
                builder: ((context, snapshot) {

                  if (snapshot.hasData) {
                    var chats = snapshot.data!.docs;

                    return ListView.builder(
                      itemBuilder: (context, index) {
                        var chat = chats[index];
                        // print(chat.reference.collection("Texts").snapshots());
                        return ChatTile(chatSnapshot: chat);
                      },
                      itemCount: chats.length,
                    );
                  }
                  else{
                    return Center(child: CircularProgressIndicator(value: 0.66,color: Theme.of(context).colorScheme.secondary,));
                  }

                })),
          )
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(value: 0.33,color: Theme.of(context).colorScheme.secondary,)
      );
    }
  }
}
