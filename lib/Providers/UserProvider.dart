import 'package:autobid/Classes/UserModel.dart';
import 'package:autobid/Utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final FirebaseAuth auth = FirebaseAuth.instance;

  UserProvider() {
    if (_user == null) fetchUser();
  }

  void fetchUser() async {
    try {
      print("wow");
      var document = await FirebaseFirestore.instance
          .collection("Users")
          .doc(auth.currentUser!.uid)
          .get();

      Map<String, dynamic> map = document.data() as Map<String, dynamic>;
      _user = Utils.mapToUser(auth.currentUser!.uid, map);
      // _user = UserModel(
      //     email: document['email'],
      //     favorites: document['favorites'],
      //     name: document['name'],
      //     id: auth.currentUser!.uid,
      //     phoneNumber: document['phoneNumber']);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  UserModel? get getUser {
    print("user: " + _user!.name);
    if (_user == null) fetchUser();
    return _user;
  }
}
