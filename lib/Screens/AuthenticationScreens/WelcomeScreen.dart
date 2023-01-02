import 'package:autobid/Screens/AuthenticationScreens/FirstWelcomeContainer.dart';
import 'package:autobid/Screens/AuthenticationScreens/SecondWelcomeCoontainer.dart';
import 'package:autobid/Screens/AuthenticationScreens/ThirdWelcomeContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: Center(
              child: Text(
            "AutoBid",
            style: TextStyle(color: Colors.grey.shade300),
          ))),
      body: Container(
        child: PageView(
          controller: controller,
          children: const [
            FirstWelcomeContainer(),
            SecondWelcomeContainer(),
            ThirdWelcomeContainer()
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.black,
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: RichText(
                  text: TextSpan(
                      text: "Skip to Sign Up",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 12,
                          color: Colors.grey.shade300))),
            ),
            Center(
                child: SmoothPageIndicator(
              controller: controller,
              count: 3,
              effect: const ScaleEffect(
                  activeDotColor: Colors.white,
                  spacing: 20,
                  radius: 10,
                  dotWidth: 10,
                  dotHeight: 10,
                  scale: 1.8),
            )),
          ],
        ),
      ),
    );
  }
}
