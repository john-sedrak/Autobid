import 'package:autobid/Custom/ChatTile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
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

                  if (chats.isNotEmpty) {
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        var chat = chats[index];
                        return ChatTile(chatSnapshot: chat);
                      },
                      itemCount: chats.length,
                    );
                  } else {
                    return const Center(
                      child: Text("You have no chats."),
                    );
                  }
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                  ));
                }
              })),
        )
      ],
    );
  }
}
