import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ThirdWelcomeContainer extends StatelessWidget {
  const ThirdWelcomeContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      padding: EdgeInsets.only(left: 20, right: 20),
      color: Colors.black,
      child: Stack(
          // padding: EdgeInsets.all(30),
          // decoration: BoxDecoration(
          //     color: Colors.black,
          //     borderRadius: BorderRadius.all(Radius.circular(5000)),
          //     image: DecorationImage(
          //         image: NetworkImage(
          //             "https://i.pinimg.com/564x/c1/f4/3d/c1f43d7640468e7cf53c09a6fc7c0ca0.jpg"),
          // fit: BoxFit.cover)),
          alignment: AlignmentDirectional.center,
          children: [
            Container(
              color: Colors.black,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image(
                image: NetworkImage(
                    "https://i.pinimg.com/564x/52/33/ec/5233ec1dfa7dae333595f9301004ec6e.jpg"),
              ),
            ),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 170),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Text(
                            "Purchase",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 55),
                          ),
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          "We help you find your dream car ",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          "with a fraction of the price !",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        )
                      ]),
                ),
                SizedBox(
                  height: 230,
                ),
                SizedBox(
                  width: 100,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text("Start", style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold, fontSize: 16),),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          //to set border radius to button
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                )
              ],
            ),
          ]),
    );
  }
}
