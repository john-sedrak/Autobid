import 'package:autobid/Utilities/TimeManager.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatTile extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> chatSnapshot;
  const ChatTile({super.key, required this.chatSnapshot});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  bool _chatterFetched = false;
  bool _latestTextFetched = false;
  bool _error = false;
  DocumentReference<Map<String, dynamic>> userRef =
      FirebaseFirestore.instance.doc('Users/' + 'RoFvf4QhbYY3dybd0nDulXzxLcK2');
  late DocumentSnapshot<Map<String, dynamic>> otherChatter;
  late Map<String, dynamic> latestText;

  void getChatterName() async {
    var chat = widget.chatSnapshot.data();
    try {
      List chatters = chat['chatters'];
      int otherChatterIndex =
          chatters.indexWhere((element) => element != userRef);
      otherChatter = await chatters[otherChatterIndex].get();
      setState(() {
        _chatterFetched = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
      print(e);
    }
  }

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
    getChatterName();
    widget.chatSnapshot.reference.collection('Texts').snapshots().listen(
      (event) {
        if(mounted){
        widget.chatSnapshot.reference
            .collection('Texts')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .first
            .then(
          (value) {
            setState(() {
              if(value.docs.isNotEmpty){
                latestText = value.docs.first.data();
                _latestTextFetched = true;
              }
              else{
                latestText = {};
              }
            });
          },
        );}
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentTime = DateTime.now();
    String time = "";
    if(_latestTextFetched && !_error){
      var timestamp = latestText['timestamp'];
      time = TimeManager.isToday(timestamp)?TimeManager.messageTime(timestamp):TimeManager.messageDate(timestamp);
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
                    child: Text(_latestTextFetched?latestText['content']:"Tap here to start chatting!",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16),
                    )),
                trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(time),
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                            // color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle),
                      )
                    ]),
              ),
          )
        : ListTile(
            title: Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary)),
          );
  }
}
