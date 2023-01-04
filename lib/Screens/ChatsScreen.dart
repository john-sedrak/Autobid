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
  var searchController = TextEditingController();
  var searchResults = <ChatTile>[];
  var chatMaps = <ChatTile>[];
  bool _error = false;
  DocumentReference<Map<String, dynamic>> userRef =
      FirebaseFirestore.instance.doc('Users/RoFvf4QhbYY3dybd0nDulXzxLcK2');

  void onSearchChanged(String input) {
    searchResults.clear();

    for (var element in chatMaps) {
      element.otherChatterFuture.then((otherChatter) {
        if (otherChatter
            .get('name')
            .toString()
            .toLowerCase()
            .split(' ')
            .any((element) => element.startsWith(input.toLowerCase()))) {
          searchResults.add(element);
        }
      }).catchError((e) {
        setState(() {
          _error = true;
        });
      });
    }
    setState(() {});
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getChatterFuture(
      var chatSnapshot) async {
    var chat = chatSnapshot.data();
    var chatters = chat['chatters'];
    int otherChatterIndex =
        chatters.indexWhere((element) => element != userRef);

    return chatters[otherChatterIndex].get()
        as Future<DocumentSnapshot<Map<String, dynamic>>>;
  }

  void populateResultLists(var chats) {
    if (chatMaps.isEmpty) {
      for (int i = 0; i < chats.length; i++) {
        var element = chats[i];

        chatMaps.add(ChatTile(
            key: ValueKey(i),
            chatSnapshot: element,
            otherChatterFuture: getChatterFuture(element)));
      }
    }
    if (searchController.text.trim().isEmpty) {
      searchResults.clear();
      chatMaps.forEach((element) {
        searchResults.add(element);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var chatsInstance = FirebaseFirestore.instance
        .collection("Chats")
        .where('chatters', arrayContains: userRef)
        .snapshots();

    if (_error) {
      return const Center(
        child: Text(
            "An error occured while fetching chats. Please try again later."),
      );
    }
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          padding: const EdgeInsets.only(left: 15, right: 5),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(30)),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  enableInteractiveSelection: true,
                  controller: searchController,
                  cursorColor: Theme.of(context).colorScheme.secondary,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search...",
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
              if (searchController.text.isNotEmpty)
                IconButton(
                    splashRadius: 1,
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged("");
                    },
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.grey,
                    ))
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
              stream: chatsInstance,
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  var chats = snapshot.data!.docs;

                  if (chats.isNotEmpty) {
                    populateResultLists(chats);
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return searchResults[index];
                      },
                      itemCount: searchResults.length,
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
