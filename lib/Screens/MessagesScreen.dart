import 'dart:async';

import 'package:autobid/Screens/ChatsScreen.dart';
import 'package:autobid/Utilities/TimeManager.dart';
import 'package:autobid/Utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Services/local_notification_service.dart';

class MessagesScreen extends StatefulWidget {
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // const MessagesScreen({super.key});
  var messageController = TextEditingController();

  bool _messagesFetched = false;

  bool _error = false;

  late DocumentReference chatRef;
  DocumentReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance
      .doc('Users/${FirebaseAuth.instance.currentUser!.uid}');

  Future<DocumentSnapshot<Map<String, dynamic>>> createOrRetrieveChat(
      DocumentSnapshot otherChatter) async {
    // RETRIEVING
    var myFetchedChats = await FirebaseFirestore.instance
        .collection('Chats')
        .where('chatters', arrayContains: userRef)
        .get();

    if (myFetchedChats.docs.isNotEmpty) {
      var chatIterator = myFetchedChats.docs.iterator;

      while (chatIterator.moveNext()) {
        var fetchedChat = chatIterator.current;
        if ((fetchedChat.data()['chatters'] as List)
            .contains(otherChatter.reference)) {
          return fetchedChat;
        }
      }
    }
    // CREATING
    var newChatRef = FirebaseFirestore.instance.collection('Chats').doc();
    await newChatRef.set({
      'chatters': [otherChatter.reference, userRef],
      'unread': {otherChatter.id: 0, userRef.id: 0},
    });
    var createdChat = await newChatRef.get();

    return createdChat;
  }

  @override
  void dispose() {
    chatRef.update({'unread.${userRef.id}': 0});
    LocalNotificationService.setChatContext(null);
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocalNotificationService.setChatContext(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    var routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    Stream<QuerySnapshot<Map<String, dynamic>>> textStream;
    late DocumentSnapshot<Map<String, dynamic>> chatSnapshot;
    late DocumentSnapshot otherChatter;

    if (routeArgs['otherChatter'] != null) {
      otherChatter = routeArgs['otherChatter'] as DocumentSnapshot;
    } else {
      String otherChatterRef = routeArgs['otherChatterRef'];
      FirebaseFirestore.instance.doc(otherChatterRef).get().then((value) {
        setState(() {
          routeArgs['otherChatter'] = value;
        });
      });
    }

    if (routeArgs['chatSnapshot'] != null) {
      chatSnapshot =
          routeArgs['chatSnapshot'] as DocumentSnapshot<Map<String, dynamic>>;
      chatRef = chatSnapshot.reference;
      textStream = chatSnapshot.reference
          .collection('Texts')
          .orderBy('timestamp', descending: true)
          .snapshots();
      setState(() {
        _messagesFetched = true;
        chatRef = chatSnapshot.reference;
      });
    } else {
      textStream = const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();

      if (routeArgs['otherChatter'] != null) {
        createOrRetrieveChat(otherChatter).then((value) {
          chatSnapshot = value;
          chatRef = chatSnapshot.reference;
          textStream = chatSnapshot.reference
              .collection('Texts')
              .orderBy('timestamp', descending: true)
              .snapshots();
          setState(() {
            _messagesFetched = true;
            routeArgs['chatSnapshot'] = chatSnapshot;
          });
        }).catchError((error) {
          print(error);
          setState(() {
            _error = true;
          });
        });
      }
    }

    Column buildMessage(Map<String, dynamic> text, bool isLastForDay) {
      bool isMyMessage = text['sender'] == userRef;
      var timestamp = text['timestamp'];
      String time = TimeManager.messageTime(timestamp);
      String date;
      if (TimeManager.isToday(timestamp)) {
        date = "Today";
      } else {
        date = TimeManager.messageDate(timestamp);
      }

      return Column(
        crossAxisAlignment:
            isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (isLastForDay)
            Center(
              child: Container(
                  padding: EdgeInsets.only(bottom: 0, top: 15),
                  child: Text(date)),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Container(
                  constraints: BoxConstraints(maxWidth: 300),
                  margin: EdgeInsets.only(
                      right: isMyMessage ? 10 : 0,
                      left: isMyMessage ? 0 : 10,
                      top: isLastForDay ? 5 : 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isMyMessage
                          ? colorScheme.secondary
                          : colorScheme.primary),
                  child: Column(
                    crossAxisAlignment: isMyMessage
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        text['content'],
                        style: TextStyle(
                            color: isMyMessage
                                ? colorScheme.onSecondary
                                : colorScheme.onPrimary,
                            fontSize: 16),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                            color: isMyMessage
                                ? colorScheme.onSecondary
                                : colorScheme.onPrimary),
                      )
                    ],
                  )),
            ],
          ),
        ],
      );
    }

    void sendMessage() {
      if (messageController.text.trim().isNotEmpty) {
        chatSnapshot.reference.collection('Texts').doc().set({
          'content': messageController.text,
          'sender': userRef,
          'receiver': otherChatter.reference,
          'timestamp': Timestamp.now()
        });
        chatSnapshot.reference.update({
          "unread.${otherChatter.id}": FieldValue.increment(1),
          "latestTextTime": Timestamp.now(),
          "latestTextContent": messageController.text,
          "latestTextSender": userRef,
        });
        setState(() {
          messageController.clear();
        });
      }
    }

    if (_error) {
      return Center(
        child: Text("An Error has occured"),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: routeArgs['otherChatter'] == null
            ? CircularProgressIndicator(
                color: colorScheme.secondary,
              )
            : Text(otherChatter['name']),
        actions: [
          IconButton(
              onPressed: () =>
                  Utils.dialPhoneNumber(otherChatter.get('phoneNumber')),
              icon: Icon(Icons.phone))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: textStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var texts = snapshot.data!.docs;

                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: 10),
                    reverse: true,
                    itemBuilder: ((context, index) {
                      var text = texts[index].data();
                      bool isLastForDay = false;
                      if (index == texts.length - 1) {
                        isLastForDay = true;
                      } else {
                        var curDate = (text['timestamp'] as Timestamp).toDate();
                        var prevDate =
                            (texts[index + 1]['timestamp'] as Timestamp)
                                .toDate();

                        isLastForDay = curDate.day != prevDate.day ||
                            curDate.month != prevDate.month ||
                            curDate.year != prevDate.year;
                      }

                      return buildMessage(text, isLastForDay);
                    }),
                    itemCount: texts.length,
                  );
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    color: colorScheme.secondary,
                  ));
                }
              },
            ),
          ),
          Container(
            height: 50,
            color: colorScheme.primary,
            padding: EdgeInsets.only(left: 15, right: 15),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                  child: TextField(
                controller: messageController,
                cursorColor: colorScheme.secondary,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: colorScheme.onPrimary, fontSize: 16),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(right: 5),
                    hintText: "Enter your message",
                    hintStyle:
                        TextStyle(color: colorScheme.onPrimary, fontSize: 16),
                    border: InputBorder.none),
              )),
              _messagesFetched && routeArgs['otherChatter'] != null
                  ? ElevatedButton(
                      onPressed: sendMessage,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary),
                      child: const Icon(Icons.send),
                    )
                  : ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.background,
                          foregroundColor: colorScheme.onSecondary),
                      child: const Icon(Icons.cancel_schedule_send),
                    )
            ]),
          )
        ],
      ),
    );
  }
}
