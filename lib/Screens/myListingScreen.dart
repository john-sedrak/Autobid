import 'package:autobid/Classes/Car.dart';
import 'package:autobid/Classes/UserModel.dart';
import 'package:autobid/Custom/CustomAppBar.dart';
import 'package:autobid/Screens/AuthenticationScreens/errorMessage.dart';
import 'package:autobid/Utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MyListingScreen extends StatefulWidget {
  const MyListingScreen({super.key});

  @override
  State<MyListingScreen> createState() => _BiddingScreenState();
}

class _BiddingScreenState extends State<MyListingScreen> {
  int activePage = 0;
  late PageController _pageController;

  String userID = FirebaseAuth.instance.currentUser!.uid;
  //"RoFvf4QhbYY3dybd0nDulXzxLcK2";
  UserModel? currentUser;
  UserModel? bidder;

  Car? carObj;

  bool isFav = false;

  @override
  void initState() {
    super.initState();
    //--------------remove when auth-----------------------
    // userID = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userID)
        .get()
        .then((snap) {
      Map<String, dynamic> curMap = snap.data() as Map<String, dynamic>;
      setState(() {
        currentUser = Utils.mapToUser(userID, curMap);
      });
    });

    Future.delayed(Duration(seconds: 1)).then((value) {
      var carsInstance =
          FirebaseFirestore.instance.collection("Cars").doc(carObj!.id);
      var stream = carsInstance.snapshots();
      stream.listen((snapshot) {
        Map<String, dynamic> carMap = snapshot.data() as Map<String, dynamic>;
        setState(() {
          carObj = Utils.mapToCar(carObj!.id, carMap);
        });
      });
    }).catchError((e) {
      showErrorMessage("Error! Cannot load car data!");
    });
    //---------------------------------------------------------
    _pageController = PageController(viewportFraction: 1, initialPage: 0);
  }

  List<Widget> indicators(imagesLength, currentIndex) {
    var apparentLength;
    var apparentIndex;
    var shrinkMode = 4;
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

  String? errorText;
  bool isLoading = false;

  late DocumentSnapshot bidderSnapshot;

  Future<void> refreshCar() {
    final carsRef = FirebaseFirestore.instance.collection('Cars');
    return carsRef.doc(carObj!.id).get().then((carDoc) {
      Map<String, dynamic> carMap = carDoc.data() as Map<String, dynamic>;
      Car carTmp = Utils.mapToCar(carObj!.id, carMap);
      setState(() {
        carObj = carTmp;
      });
    });
  }

  Future<void> getBidder(String bidderId) {
    final usersRef = FirebaseFirestore.instance.collection('Users');
    return usersRef.doc(bidderId).get().then((userDoc) {
      bidderSnapshot = userDoc;
      Map<String, dynamic> userMap = userDoc.data() as Map<String, dynamic>;
      UserModel bidderTmp = Utils.mapToUser(bidderId, userMap);
      setState(() {
        bidder = bidderTmp;
      });
    });
  }

  void showErrorMessage(String msg) {
    Future.delayed(Duration(seconds: 0))
        .then((_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Color.fromARGB(0, 255, 255, 255),
              elevation: 0,
              content: errorMessage(
                message: msg,
              ),
              behavior: SnackBarBehavior.fixed,
            )));
  }

  void goToEditPage() {
    Navigator.of(context).pushNamed('/edit', arguments: carObj);
  }

  bool onStart = true;
  bool noBidder = false;
  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;

    Car car = routeArgs['car'] as Car;

    if (carObj == null) {
      setState(() {
        carObj = car;
        isLoading = true;
      });
      getBidder(car.bidderID)
          .then((value) => setState(() {
                isLoading = false;
              }))
          .catchError((e) {
        //showErrorMessage("Connection Error! Could not load Content.");
        setState(() {
          isLoading = false;
          noBidder = true;
        });
      });
    } else {
      car = carObj!;
    }

    if (currentUser != null && currentUser!.favorites.contains(car.id)) {
      setState(() {
        isFav = true;
      });
    }

    double oldBid = car.bidderID == '' ? car.startingPrice : car.currentBid;
    double minPossibleBid =
        car.bidderID == '' ? car.startingPrice : car.currentBid + 1;
    bool isMyBid = car.bidderID == userID;

    return Scaffold(
        appBar: CustomAppBar(title: "Car Details"),
        floatingActionButton: FloatingActionButton(
          onPressed: () => goToEditPage(),
          backgroundColor: Colors.pink,
          child: const Icon(Icons.edit),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: Colors.pink,
              ))
            : RefreshIndicator(
                color: Colors.pink,
                onRefresh: () => refreshCar(),
                child: SingleChildScrollView(
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
                      ),
                      Positioned.fill(
                          bottom: 0,
                          child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15)),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(15),
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.white,
                                              child: IconButton(
                                                onPressed: () {
                                                  Utils.addOrRemoveFromFavorites(
                                                          currentUser!, car.id)
                                                      .then((value) =>
                                                          setState(() {
                                                            isFav = !isFav;
                                                          }));
                                                },
                                                icon: Icon(
                                                    isFav
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    color: Colors.amber),
                                              ),
                                            ),
                                          ),
                                        ])
                                  ])))
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      car.brand,
                                      style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(Icons.location_pin,
                                            color: Colors.blueGrey),
                                        Text(
                                          car.location,
                                          style:
                                              TextStyle(color: Colors.blueGrey),
                                        )
                                      ],
                                    )
                                  ],
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      if (!noBidder) ...BidderWidgets(context)
                                    ]))))
                  ])),
                ),
              ));
  }

  Set<Widget> BidderWidgets(BuildContext context) {
    return {
      Container(
        margin: EdgeInsets.only(bottom: 5),
        child: const Text("Current Bidder",
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
      ),
      Row(
        children: [
          CircleAvatar(
              backgroundColor: Colors.pink,
              radius: 20,
              child: Text(
                bidder != null ? bidder!.name.substring(0, 1) : ' ',
                style: TextStyle(fontSize: 25, color: Colors.white),
              )),
          Text('   '),
          Text(
            '${bidder?.name}',
            style: TextStyle(fontSize: 17),
          ),
        ],
      ),
      Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: const Text("Contact Current Bidder",
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
      ),
      Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: Colors.green,
                radius: 18,
                child: IconButton(
                    icon: const Icon(Icons.phone, color: Colors.white),
                    onPressed: () async {
                      if (bidder != null) {
                        Utils.dialPhoneNumber(bidder!.phoneNumber);
                      }
                    },
                    iconSize: 15)),
            Text('   '),
            CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 18,
                child: IconButton(
                    icon: const Icon(Icons.chat_rounded, color: Colors.white),
                    onPressed: () {
                      if (bidder != null) {
                        Navigator.of(context).pushNamed('/messages',
                            arguments: {'otherChatter': bidderSnapshot});
                        ;
                      }
                    },
                    iconSize: 15)),
          ],
        ),
      )
    };
  }
}
