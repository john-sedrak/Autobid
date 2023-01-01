
import 'package:cloud_firestore/cloud_firestore.dart';

class TimeManager{

  static String messageTime(var timestamp){

    var messageTime = (timestamp as Timestamp).toDate();
    String time = "${messageTime.hour<10?"0${messageTime.hour}":messageTime.hour}:${messageTime.minute<10?"0${messageTime.minute}":messageTime.minute}";
    
    return time;
  }

  static String messageDate(var timestamp){

    var messageTime = (timestamp as Timestamp).toDate();
    String date = "${messageTime.day<10?"0${messageTime.day}":messageTime.day}/${messageTime.month<10?"0${messageTime.month}":messageTime.month}/${messageTime.year}";

    return date;
  }

  static bool isToday(var timestamp){

    var messageTime = (timestamp as Timestamp).toDate();
    var currentTime = DateTime.now();
    return messageTime.day == currentTime.day && messageTime.month == currentTime.month && messageTime.year == currentTime.year;
  }
}