import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class InputField extends StatelessWidget {
  TextEditingController controller;
  final String tag;
  final bool isPassword;

  InputField(
      {super.key,
      required this.controller,
      required this.tag,
      required this.isPassword});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Text(
                tag,
                textAlign: TextAlign.left,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none),
              ),
            ),
            SizedBox(
              width: 270,
              height: 35,
              child: TextField(
                obscureText: isPassword,
                controller: controller,
                decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                style: const TextStyle(
                    color: Colors.black, decoration: TextDecoration.none),
              ),
            ),
          ]),
    );
  }
}
