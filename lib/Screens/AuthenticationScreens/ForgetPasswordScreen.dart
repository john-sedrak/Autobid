import 'package:autobid/Screens/AuthenticationScreens/InputField.dart';
import 'package:autobid/Screens/AuthenticationScreens/errorMessage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  var emailController = TextEditingController();
  final auth = FirebaseAuth.instance;

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

  void success() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.grey.shade300,
      elevation: 0,
      content: Container(
        padding: const EdgeInsets.all(16),
        height: 50,
        decoration: const BoxDecoration(
            color: Color.fromARGB(255, 20, 179, 46),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: const Text("Please check your email."),
      ),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void forgetPass() async {
    FocusManager.instance.primaryFocus?.unfocus();

    String email = emailController.text.trim();
    if (email.length == 0) {
      showErrorMessage("You should provide an email address.");
      return;
    }
    try {
      await auth.sendPasswordResetEmail(email: email);
      success();
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email") {
        showErrorMessage("Invalid email address.");
      } else if (e.code == 'user-not-found') {
        showErrorMessage("There is no user registered with this email.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
            color: Colors.grey.shade300,
            child: Container(
                margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "AutoBid",
                        style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.none,
                            fontSize: 32),
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 60),
                          child: Column(children: [
                            Container(
                              width: 270,
                              margin: const EdgeInsets.only(bottom: 30),
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                  "Enter the email address associated with your account and we'll send you a link to reset your password",
                                  style: TextStyle(
                                      color: Colors.black,
                                      decoration: TextDecoration.none,
                                      fontSize: 10)),
                            ),
                            InputField(
                              controller: emailController,
                              tag: "Email",
                              isPassword: false,
                              isEmail: true,
                              isPhone: false,
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
                                      onPressed: forgetPass,
                                      child: const Text(
                                        "Submit",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                )),
                          ]))
                    ]))),
      ),
    );
  }
}
