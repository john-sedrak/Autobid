import 'package:autobid/Classes/Car.dart';
import 'package:autobid/Classes/User.dart';
import 'package:autobid/Custom/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BiddingScreen extends StatefulWidget {
  const BiddingScreen({super.key});

  @override
  State<BiddingScreen> createState() => _BiddingScreenState();
}

class _BiddingScreenState extends State<BiddingScreen> {
  int activePage = 0;
  late PageController _pageController;

  var inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1, initialPage: 0);
  }

  List<Widget> indicators(imagesLength, currentIndex) {
    var apparentLength;
    var apparentIndex;
    var shrinkMode;
    if (imagesLength > 7) {
      apparentLength = 7;
      if (currentIndex <= 3) {
        apparentIndex = currentIndex;
        shrinkMode = 0;
      } else if (currentIndex >= imagesLength - 4) {
        apparentIndex = currentIndex - imagesLength + 7;
        shrinkMode = 2;
      } else {
        apparentIndex = 3;
        shrinkMode = 1;
      }
    } else {
      apparentLength = imagesLength;
      apparentIndex = currentIndex;
    }

    return List<Widget>.generate(apparentLength, (index) {
      return Container(
        margin: EdgeInsets.all(3),
        width: shrinkMode < 2 && index == 6
            ? 5
            : (shrinkMode > 0 && index == 0
                ? 5
                : (apparentIndex == index ? 12 : 8)),
        height: shrinkMode < 2 && index == 6
            ? 5
            : (shrinkMode > 0 && index == 0
                ? 5
                : (apparentIndex == index ? 12 : 8)),
        decoration:
            BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
      );
    });
  }

  String addCommas(String s) {
    return s.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  bool isExpanded = false;

  String? errorText;
  bool isLoading = false;

  Future<void> updateBid(BuildContext ctx) {
    setState(() {
      isLoading = true;
    });
    Navigator.pop(ctx, 'OK');
    return Future.delayed(Duration(seconds: 3), () {
      inputController.clear();
      setState(() {
        isExpanded = !isExpanded;
        errorText = null;
        isLoading = false;
      });
    });
  }

  void placeBid() {
    setState(() {
      isExpanded = !isExpanded;
    });
    print(isExpanded);
  }

  void confirmBid(BuildContext ctx) {
    print("confirm click");
    displayDialog(ctx);
  }

  Future<String?> displayDialog(BuildContext ctx) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirm Bid'),
        content: Text('You are placing a ' +
            double.parse(inputController.text).toString() +
            ' EGP bid for this listing?'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              inputController.clear();
              setState(() {
                isExpanded = !isExpanded;
                errorText = null;
              });
              Navigator.pop(context, 'Cancel');
            },
            child: Text(
              "  Cancel  ",
              style: TextStyle(fontSize: 18),
            ),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.redAccent.shade700),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(color: Colors.redAccent.shade700)))),
          ),
          // TextButton(
          //   onPressed: () => Navigator.pop(context, 'OK'),
          //   child: const Text('OK'),
          // ),
          ElevatedButton(
            onPressed: () => updateBid(context),
            child: Text(
              " Confirm ",
              style: TextStyle(fontSize: 18),
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.pink),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(color: Colors.pink)))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Car>;

    final Car car = routeArgs['car'] as Car;
    String userId = "My ID";
    double oldBid = car.bidderID == '' ? car.startingPrice : car.currentBid;
    double minPossibleBid =
        car.bidderID == '' ? car.startingPrice : car.currentBid + 1;

    User seller = new User(
        id: "123",
        email: "email@email.com",
        phoneNumber: "0123456",
        name: "Adam Smith",
        favorites: ["123", "456"]);

    bool isMyBid = car.bidderID == userId;

    void checkErrorText() {
      if (inputController.text == "") {
        setState(() {
          errorText = "Please input bid";
        });
        return;
      }
      try {
        double newBid = double.parse(inputController.text);
        if (newBid - oldBid < 1) {
          setState(() {
            errorText = "Minimum New Bid is $minPossibleBid";
          });
          return;
        }
      } catch (e) {
        setState(() {
          errorText = "Incorrect format";
        });
        return;
      }
      setState(() {
        errorText = null;
      });
    }

    return Scaffold(
        appBar: CustomAppBar(title: "Car Details"),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: Colors.pink,
              ))
            : SingleChildScrollView(
                child: Container(
                    child: Column(children: [
                  Stack(children: [
                    SizedBox(
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(children: [
                        PageView.builder(
                            itemCount: car.carImagePaths.length,
                            pageSnapping: true,
                            controller: _pageController,
                            onPageChanged: (page) {
                              setState(() {
                                activePage = page;
                              });
                            },
                            itemBuilder: (ctx, pagePos) {
                              return Image.network(car.carImagePaths[pagePos],
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover);
                            }),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: indicators(
                                    car.carImagePaths.length, activePage),
                              ),
                            )
                          ],
                        )
                      ]),
                    )
                  ]),

                  //other then images
                  Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                car.brand,
                                style: TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${car.model}, ${car.year}",
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey),
                              ),
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(top: 10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text('Bids open until',
                                              style: TextStyle(
                                                  color: Colors.blueGrey)),
                                          Text(
                                              DateFormat('dd-MM-yyyy')
                                                  .format(car.validUntil),
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                      Row(children: [
                                        Icon(Icons.speed,
                                            color: Colors.blueGrey),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "  Mileage (Km)",
                                                style: TextStyle(
                                                    color: Colors.blueGrey),
                                              ),
                                              Text(
                                                addCommas(
                                                    "  ${car.mileage.round()}"),
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ]),
                                      ])
                                    ]),
                              ),
                            ]),
                      )),

//place bids container
                  Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                          bottom: 15, left: 15, right: 15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15))),
                      child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                            width: double.infinity,
                            child: Column(
                              //crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  child: Text(
                                    car.bidderID == ''
                                        ? 'Starting Bid'
                                        : 'Current Bid',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Colors.blueGrey, fontSize: 18),
                                  ),
                                ),
                                Text(
                                  addCommas(car.bidderID == ''
                                      ? '${car.startingPrice.round()} EGP'
                                      : '${car.currentBid.round()} EGP'),
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold),
                                ),
                                //Place a bid hidden components
                                if (isExpanded)
                                  Container(
                                      margin: EdgeInsets.only(top: 10),
                                      width: double.infinity,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            margin: EdgeInsets.only(bottom: 10),
                                            child: const Text(
                                              "Enter Your Bid",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          TextField(
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: "Bid in EGP",
                                                errorText: errorText),
                                            onChanged: (value) =>
                                                checkErrorText(),
                                            controller: inputController,
                                            keyboardType: TextInputType.number,
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    inputController.clear();
                                                    setState(() {
                                                      isExpanded = !isExpanded;
                                                      errorText = null;
                                                    });
                                                  },
                                                  child: Text(
                                                    "  Cancel  ",
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty.all(
                                                              Colors.redAccent
                                                                  .shade700),
                                                      foregroundColor:
                                                          MaterialStateProperty.all(
                                                              Colors.white),
                                                      shape: MaterialStateProperty.all<
                                                              RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(15.0),
                                                              side: BorderSide(color: Colors.redAccent.shade700)))),
                                                ),
                                                ElevatedButton(
                                                  onPressed: errorText !=
                                                              null ||
                                                          inputController.text
                                                                  .length ==
                                                              0
                                                      ? null
                                                      : () =>
                                                          confirmBid(context),
                                                  child: Text(
                                                    " Place Bid ",
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                  style: ButtonStyle(
                                                      backgroundColor: MaterialStateProperty.all(
                                                          errorText != null ||
                                                                  inputController.text.length ==
                                                                      0
                                                              ? Color.fromARGB(
                                                                  255, 65, 23, 37)
                                                              : Colors.pink),
                                                      foregroundColor:
                                                          MaterialStateProperty.all(
                                                              Colors.white),
                                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(15.0),
                                                              side: BorderSide(color: errorText != null || inputController.text.length == 0 ? Color.fromARGB(255, 65, 23, 37) : Colors.pink)))),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )),

                                //----------------------
                                if (!isExpanded)
                                  Container(
                                      margin:
                                          EdgeInsets.only(top: 15, bottom: 5),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed:
                                              isMyBid ? null : () => placeBid(),
                                          child: Text(
                                            isMyBid
                                                ? "You Placed The Highest Bid!"
                                                : "Place Your Bid",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      isMyBid
                                                          ? Color.fromARGB(
                                                              255, 65, 23, 37)
                                                          : Colors.pink),
                                              foregroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.white),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(15.0),
                                                      side: BorderSide(color: isMyBid ? Color.fromARGB(255, 65, 23, 37) : Colors.pink)))),
                                        ),
                                      )),
                              ],
                            ),
                          ))),

                  // car and seller details

                  Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                          bottom: 15, left: 15, right: 15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15))),
                      child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                              width: double.infinity,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Car Description",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 16)),
                                    Text(
                                      '${car.sellerDescription}\n',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    const Text("Seller",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 16)),
                                    Text(
                                      '${seller.name}',
                                      style: TextStyle(fontSize: 17),
                                    )
                                  ]))))
                ])),
              ));
  }
}
