import 'package:autobid/Providers/UserProvider.dart';
import 'package:autobid/Screens/AuthenticationScreens/InputField.dart';
import 'package:autobid/Screens/AuthenticationScreens/errorMessage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

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
  var confirmPasswordController = TextEditingController();
  final authenticationInstance = FirebaseAuth.instance;
  final fbm = FirebaseMessaging.instance;

  bool authenticationMode = true;

  void showErrorMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.grey.shade300,
      elevation: 0,
      content: errorMessage(
        message: msg,
      ),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void changeMode() {
    setState(() {
      FocusManager.instance.primaryFocus?.unfocus();
      authenticationMode = !authenticationMode;
      emailController.text = "";
      passwordController.text = "";
      usernameController.text = "";
      phoneNumberController.text = "";
      confirmPasswordController.text = "";
    });
  }

  void login() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    FocusManager.instance.primaryFocus?.unfocus();
    var email = emailController.text.trim();
    var password = passwordController.text;
    if (email == "" || password == "") {
      showErrorMessage("all fields must be satisfied");
      return;
    }

    var authResult = null;

    try {
      authResult = await authenticationInstance.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == "user-not-found") {
        showErrorMessage('Email not found.');
      } else if (e.code == 'wrong-password') {
        showErrorMessage('Incorrect password.');
      } else {
        showErrorMessage(e.code);
      }
    } catch (e) {
      print(e);
    }
    var token = await fbm.getToken();
    if (authResult != null) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(authResult.user!.uid)
          .update({'notifToken': token});
      userProvider.fetchUser();
      // Navigator.of(context)
      //     .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  bool checkPhone(String phoneNumber) {
    if (phoneNumber.length != 11) return false;
    var code = phoneNumber.substring(0, 3);
    if (code != '010' && code != '011' && code != '012') return false;
    for (var i = 0; i < phoneNumber.length; i++) {
      if (phoneNumber[i].codeUnitAt(0) < '0'.codeUnitAt(0) ||
          phoneNumber[i].codeUnitAt(0) > '9'.codeUnitAt(0)) return false;
    }
    return true;
  }

  void signup() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    FocusManager.instance.primaryFocus?.unfocus();
    var email = emailController.text.trim();
    var password = passwordController.text;
    var username = usernameController.text.trim();
    var phoneNumber = phoneNumberController.text.trim();
    var confirmPassword = confirmPasswordController.text;

    if (email == "" || password == "" || username == "" || phoneNumber == "") {
      showErrorMessage("all fields must be satisfied");
      return;
    }

    if (!checkPhone(phoneNumber)) {
      showErrorMessage("Phone number is incorrect");
      return;
    }

    if (password != confirmPassword) {
      showErrorMessage("Password confirmation is incorrect");
      return;
    }

    var authResult = null;

    try {
      authResult = await authenticationInstance.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showErrorMessage('The password provided is too weak.');
      }
      if (e.code == 'invalid-email') {
        showErrorMessage('Invalid Email address.');
      } else if (e.code == 'email-already-in-use') {
        showErrorMessage('Email already exists.');
      }
    }

    if (authResult != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(authResult.user!.uid)
          .set({
        'email': email,
        'favorites': [],
        'name': username,
        'phoneNumber': phoneNumber,
        'notifToken': await fbm.getToken()
      });
      userProvider.fetchUser();

      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          color: Colors.grey.shade300,
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 10, top: 100),
            child: Column(children: [
              const Text(
                "AutoBid",
                style: TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.none,
                    fontSize: 32),
              ),
              Container(
                margin: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Container(
                      width: 270,
                      alignment: Alignment.centerLeft,
                      child: Text((authenticationMode) ? "SIGN UP" : "LOGIN",
                          style: const TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.none,
                              fontSize: 30)),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 30),
                      child: Column(
                        children: [
                          Container(
                            child: Column(
                              children: [
                                if (authenticationMode)
                                  InputField(
                                    controller: usernameController,
                                    tag: "Name",
                                    isPassword: false,
                                  ),
                                InputField(
                                  controller: emailController,
                                  tag: "Email",
                                  isPassword: false,
                                ),
                                if (authenticationMode)
                                  InputField(
                                    controller: phoneNumberController,
                                    tag: "Phone Number",
                                    isPassword: false,
                                  ),
                                InputField(
                                  controller: passwordController,
                                  tag: "Password",
                                  isPassword: true,
                                ),
                                if (authenticationMode)
                                  InputField(
                                      controller: confirmPasswordController,
                                      tag: "Confirm Password",
                                      isPassword: true),
                              ],
                            ),
                          ),
                          Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 15),
                              child: Center(
                                child: SizedBox(
                                  width: 270,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.pink,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        )),
                                    onPressed:
                                        (authenticationMode) ? signup : login,
                                    child: Text(
                                      (authenticationMode)
                                          ? "Sign Up"
                                          : "Login",
                                      style: TextStyle(
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              )),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 5),
                            child: Center(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      (authenticationMode)
                                          ? "Already a user? "
                                          : "Don't have an account? ",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    InkWell(
                                      child: Text(
                                        (authenticationMode)
                                            ? "LOGIN"
                                            : "SIGN UP",
                                        style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 12,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                      onTap: changeMode,
                                    )
                                  ]),
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
      ),
    );
  }
}
