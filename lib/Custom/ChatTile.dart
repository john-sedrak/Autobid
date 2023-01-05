import 'package:autobid/Utilities/TimeManager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatTile extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> chatSnapshot;
  final Future<DocumentSnapshot<Map<String, dynamic>>> otherChatterFuture;
  const ChatTile(
      {super.key,
      required this.chatSnapshot,
      required this.otherChatterFuture});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  bool _chatterFetched = false;
  bool _latestTextFetched = false;
  bool _error = false;
  int _unreadCount = 0;
  DocumentReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance
      .doc('Users/${FirebaseAuth.instance.currentUser!.uid}');
  late DocumentSnapshot<Map<String, dynamic>> otherChatter;
  Map<String, dynamic> latestText = {};

  void navigateToChat() {
    // Future.delayed(Duration(milliseconds: 500), (){
    Navigator.of(context).pushNamed('/messages', arguments: {
      'chatSnapshot': widget.chatSnapshot,
      'otherChatter': otherChatter
    });
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    widget.otherChatterFuture.then((value) {
      setState(() {
        otherChatter = value;
        _chatterFetched = true;
      });
    }).catchError((error) {
      setState(() {
        _error = true;
      });
    });
    widget.chatSnapshot.reference.snapshots().listen((event) {
      if (mounted) {
        setState(() {
          _unreadCount = event.get('unread.${userRef.id}');
        });
        setState(() {
          try {
          latestText = {
            'sender': event.get('latestTextSender'),
            'timestamp': event.get('latestTextTime'),
            'content': event.get('latestTextContent'),
          };
          _latestTextFetched = true;
        } catch (e) {
          print(e);
          _latestTextFetched = false;
        }
        });
        
      }
    });

    super.initState();
  }

  bool isMyMessage() {
    return latestText['sender'] == userRef;
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentTime = DateTime.now();
    String time = "";
    if (_latestTextFetched && !_error) {
      var timestamp = latestText['timestamp'];
      time = TimeManager.isToday(timestamp)
          ? TimeManager.messageTime(timestamp)
          : TimeManager.messageDate(timestamp);
    }

    return _chatterFetched && !_error
        ? InkWell(
            onTap: navigateToChat,
            child: ListTile(
              title: Text(
                otherChatter.data()!['name'],
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Text(
                    _latestTextFetched
                        ? (isMyMessage()
                            ? 'You: ${latestText['content']}'
                            : '${otherChatter.data()!['name'].toString().split(' ')[0]}: ${latestText['content']}')
                        : "Tap here to start chatting!",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16),
                  )),
              trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(time),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            padding: EdgeInsets.only(right: 5, left: 5),
                            height: 20,
                            constraints:
                                BoxConstraints(maxWidth: 50, minWidth: 20),
                            decoration: BoxDecoration(
                                color: _unreadCount > 0
                                    ? Theme.of(context).colorScheme.secondary
                                    : null,
                                borderRadius: BorderRadius.circular(50)),
                            child: _unreadCount > 0
                                ? Text(
                                    _unreadCount.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  )
                                : null),
                      ],
                    )
                  ]),
            ),
          )
        : ListTile(
            leading: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary),
          );
  }
}
