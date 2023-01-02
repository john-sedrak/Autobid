import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var usernameController = TextEditingController();
  var phoneNumberController = TextEditingController();
  final authenticationInstance = FirebaseAuth.instance;
  final fbm = FirebaseMessaging.instance;

  bool authenticationMode = false;

  void signup() async {
    var email = emailController.text.trim();
    var password = passwordController.text.trim();

    await fbm.getToken();
    UserCredential authResult = await authenticationInstance
        .createUserWithEmailAndPassword(email: email, password: password);

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(authResult.user!.uid)
        .set({
      'email': email,
      'favorites': [],
      'name': 'testtest',
      'phoneNumber': '01273489867',
      'notifToken': fbm.getToken()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey.shade300,
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10, top: 100),
          child: Column(children: [
            const Text(
              "AutoBid",
              style: TextStyle(
                  color: Colors.black, decoration: TextDecoration.none),
            ),
            Container(
              margin: EdgeInsets.only(left: 50, top: 60),
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SIGN UP",
                      style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontSize: 30)),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    padding: const EdgeInsets.only(right: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Email",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none),
                        ),
                        SizedBox(
                          width: 300,
                          height: 50,
                          child: TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            style: const TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.none),
                          ),
                        ),
                        const Text(
                          "Password",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none),
                        ),
                        SizedBox(
                          width: 300,
                          height: 50,
                          child: TextField(
                            obscureText: true,
                            controller: passwordController,
                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            style: TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.none),
                          ),
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: signup,
                            child: Text("Sign Up"),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
