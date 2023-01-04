import 'package:autobid/Classes/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class UserProvider with ChangeNotifier {
  var _user;
  final FirebaseAuth auth = FirebaseAuth.instance;

  void fetchUser() async {
    try {
      print("wow");
      var document = await FirebaseFirestore.instance
          .collection("Users")
          .doc(auth.currentUser!.uid)
          .get();

      _user = UserModel(
          email: document['email'],
          favorites: document['favorites'],
          name: document['name'],
          id: auth.currentUser!.uid,
          phoneNumber: document['phoneNumber']);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  UserModel get getUser {
    return _user;
  }
}
