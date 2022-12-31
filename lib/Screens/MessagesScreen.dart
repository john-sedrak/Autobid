import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  // const MessagesScreen({super.key});

  var messageController = TextEditingController();

  bool _messagesFetched = false;

  bool _error = false;

  DocumentReference<Map<String, dynamic>> userRef =
      FirebaseFirestore.instance.doc('Users/' + 'RoFvf4QhbYY3dybd0nDulXzxLcK2');

  @override
  Widget build(BuildContext context) {

    
    var colorScheme = Theme.of(context).colorScheme;

    var routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var chatSnapshot = routeArgs['chatSnapshot'] as QueryDocumentSnapshot<Map<String, dynamic>>;
    var textStream = chatSnapshot.reference.collection('Texts').orderBy('timestamp', descending: true).snapshots();

    Column buildMessage(Map<String, dynamic> text, bool isLastForDay){

      bool isMyMessage = text['sender'] != (routeArgs['otherChatter'] as DocumentSnapshot).reference; 
      var messageTime = (text['timestamp'] as Timestamp).toDate();
      String time = "${messageTime.hour}:${messageTime.minute<10?"0${messageTime.minute}":messageTime.minute}";
      String date = "${messageTime.day<10?"0${messageTime.day}":messageTime.day}/${messageTime.month<10?"0${messageTime.month}":messageTime.month}/${messageTime.year}";

      return Column(
        crossAxisAlignment: isMyMessage?CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: [
          if(isLastForDay)
            Center(
             
              child: Container(padding: EdgeInsets.only(bottom:0, top: 15),child: Text(date)),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: isMyMessage?MainAxisAlignment.end: MainAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints( maxWidth: 300),
                margin: EdgeInsets.only(right: isMyMessage?10:0, left: isMyMessage?0:10, top: isLastForDay?5:10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: isMyMessage?colorScheme.secondary:colorScheme.primary),
                child: Column(
                  crossAxisAlignment: isMyMessage?CrossAxisAlignment.end: CrossAxisAlignment.start,
                  children: [
                    Text(text['content'], style: TextStyle(color: isMyMessage?colorScheme.onSecondary: colorScheme.onPrimary, fontSize: 16),),
                    Text(time, style: TextStyle(color: isMyMessage?colorScheme.onSecondary: colorScheme.onPrimary),)
                  ],
                )
              ),
            ],
          ),
        ],
      );
  }

    void sendMessage(){
      chatSnapshot.reference.collection('Texts').doc().set({
        'content': messageController.text,
        'sender': userRef,
        'timestamp': Timestamp.now()
      });
      messageController.clear();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(routeArgs['otherChatter']['name']),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: textStream,
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  var texts = snapshot.data!.docs;
                  // print(texts[0].data());
                
                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: 10),
                    reverse: true,
                    itemBuilder: ((context, index) {
                      var text = texts[index].data();
                      bool isLastForDay = false;
                      if(index == texts.length-1){
                        isLastForDay = true;
                      }
                      else{
                        var curDate = (text['timestamp'] as Timestamp).toDate();
                        var prevDate = (texts[index + 1]['timestamp'] as Timestamp).toDate();

                        isLastForDay = curDate.day != prevDate.day || curDate.month != prevDate.month || curDate.year != prevDate.year;
                      }

                      return buildMessage(text, isLastForDay);
                    }), 
                    itemCount: texts.length,
                  );
                }
                else{
                  return Center(child: CircularProgressIndicator(color: colorScheme.secondary,));
                }
              },
            ),
          ),
          Container(
            height: 50,
            color: colorScheme.primary,
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  cursorColor: colorScheme.secondary,
                  style: TextStyle(color: colorScheme.onPrimary, fontSize: 16),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(right: 5),
                      hintText: "Enter your message",
                      hintStyle: TextStyle(color: colorScheme.onPrimary, fontSize: 16),
                      border: InputBorder.none),
                )
              ),
              ElevatedButton(
                onPressed: sendMessage,
                child: Icon(Icons.send),
                style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary),
              )
            ]),
          )
        ],
      ),
    );
  }
}
