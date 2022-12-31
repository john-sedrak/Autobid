import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatTile extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> chatRef;
  const ChatTile({super.key, required this.chatRef});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {

  bool _chatterFetched = false;
  bool _error = false;
  late DocumentSnapshot<Map<String, dynamic>> chatter;
  void getChatterName() async{
    try
    {
      chatter = await widget.chatRef.get();
      setState(() {
        _chatterFetched = true;
      });
    }
    catch(e){
      setState(() {
        _error = true;
      });
      print(e);
    }

  }
  @override
  void initState() {
    // TODO: implement initState
    getChatterName();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    DateTime currentTime = DateTime.now();
    String time = "${currentTime.hour}:${currentTime.minute<10?"0${currentTime.minute}":currentTime.minute}";
    return _chatterFetched && !_error?
    InkWell(
      onTap: () => print("hi"),
      child: ListTile(
        title: Text(chatter.data()!['name'], overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), ),
        subtitle: Container(margin: EdgeInsets.only(top:5), child: Text("testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttest", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16),)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(time),
            Container(height: 20, width: 20,decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, shape: BoxShape.circle),)
          ]),
      ),
    ):
    ListTile(leading: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary),);
  }
}
