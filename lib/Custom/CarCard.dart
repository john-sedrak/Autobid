import 'package:autobid/Classes/UserModel.dart';
import 'package:autobid/Utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Classes/Car.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class CarCard extends StatefulWidget {
  Car car;

  CarCard({required this.car});

  @override
  State<CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<CarCard> {
  bool isFav = false;
  int activePage = 0;
  late PageController _pageController;
  bool _userLoaded = false;
  late UserModel seller;
  late DocumentSnapshot sellerSnapshot;
  //update this code when authentication is complete
  String userId = FirebaseAuth.instance.currentUser!.uid;
  late UserModel curUser;
  bool curUserObtained = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1, initialPage: 0);
    getSellerUser();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    Map<String, dynamic> curMap = snap.data() as Map<String, dynamic>;
    curUser = Utils.mapToUser(userId, curMap);
    curUserObtained = true;
    isFav = curUser.favorites.contains(widget.car.id);
  }

  void goToBiddingScreen(BuildContext context, {bool isExpanded = false}) {
    if (widget.car.sellerID == FirebaseAuth.instance.currentUser!.uid) {
      Navigator.of(context)
          .pushNamed('/myListingRoute', arguments: {'car': widget.car});
    } else {
      Navigator.of(context).pushNamed('/bidRoute',
          arguments: {'car': widget.car, 'isExpanded': isExpanded});
    }
  }

  void goToChatScreen(BuildContext context) {
    Navigator.of(context)
        .pushNamed('/messages', arguments: {'otherChatter': sellerSnapshot});
  }

  void goToEditingScreen(BuildContext context) {
    Navigator.of(context).pushNamed('/edit', arguments: widget.car);
  }

  UserModel mapToUserWithoutFavorites(String id, Map<String, dynamic> map) {
    return UserModel(
        id: id,
        favorites: [],
        name: map["name"].toString(),
        email: map["email"].toString(),
        phoneNumber: map["phoneNumber"].toString());
  }

  Future<void> getSellerUser() async {
    try {
      var sellerID = widget.car.sellerID;

      final sellerRef =
          FirebaseFirestore.instance.collection('Users').doc(sellerID);

      DocumentSnapshot d = await sellerRef.get();

      setState(() {
        sellerSnapshot = d;
        Map<String, dynamic> sellerMap =
            sellerSnapshot.data() as Map<String, dynamic>;

        seller = Utils.mapToUser(sellerSnapshot.id, sellerMap);
        _userLoaded = true;
      });
    } catch (err) {
      print(err);
    }
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => goToBiddingScreen(context),
        child: Container(
          height: 300,
          child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              margin: EdgeInsets.all(10),
              child: Column(children: [
                Stack(children: [
                  ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      child: SizedBox(
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        child: Stack(children: [
                          PageView.builder(
                              itemCount: widget.car.carImagePaths.length,
                              pageSnapping: true,
                              controller: _pageController,
                              onPageChanged: (page) {
                                setState(() {
                                  activePage = page;
                                });
                              },
                              itemBuilder: (ctx, pagePos) {
                                return Image.network(
                                    widget.car.carImagePaths[pagePos],
                                    height: 150,
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
                                      widget.car.carImagePaths.length,
                                      activePage),
                                ),
                              )
                            ],
                          )
                        ]),
                      )),
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Utils.addOrRemoveFromFavorites(
                                                  curUser, widget.car.id)
                                              .then((value) => setState(() {
                                                    isFav = !isFav;
                                                  }));
                                        },
                                        icon: Icon(
                                            isFav
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber),
                                        iconSize: 35,
                                      ),
                                    ])
                              ])))
                ]),
                Container(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                            widget.car.brand +
                                " " +
                                widget.car.model +
                                " " +
                                widget.car.year.toString(),
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        subtitle: ShaderMask(
                          shaderCallback: (Rect rect) {
                            return LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white,
                                Colors.white,
                                Colors.transparent
                              ],
                              stops: [
                                0.0,
                                0.9,
                                1.0
                              ], // 10% purple, 80% transparent, 10% purple
                            ).createShader(rect);
                          },
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        child: Row(
                                      children: [
                                        Icon(Icons.speed),
                                        Text(
                                          addCommas(
                                              " ${widget.car.mileage.round()}"),
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Text(' km',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    )),
                                    Text(' '),
                                    Container(
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_pin),
                                          Text(
                                            widget.car.location,
                                            style:
                                                TextStyle(color: Colors.grey),
                                          )
                                        ],
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                        trailing: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                  widget.car.bidderID == ''
                                      ? 'Starting at'
                                      : 'Current bid at',
                                  style: TextStyle(fontSize: 10)),
                              Text(
                                addCommas(widget.car.bidderID == ''
                                    ? '${widget.car.startingPrice.round()} EGP'
                                    : '${widget.car.currentBid.round()} EGP'),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  'Valid until ' +
                                      DateFormat('dd-MM-yyyy')
                                          .format(widget.car.validUntil),
                                  style: TextStyle(color: Colors.grey))
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        visualDensity: VisualDensity(vertical: -4),
                        leading: Container(
                          width: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                  backgroundColor: Colors.pink,
                                  radius: 25,
                                  child: Text(
                                    _userLoaded
                                        ? seller.name.substring(0, 1)
                                        : ' ',
                                    style: TextStyle(
                                        fontSize: 25, color: Colors.white),
                                  )),
                              Text('  '),
                              curUserObtained && curUser.id == seller.id
                                  ? CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      radius: 15,
                                      child: IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.white),
                                          onPressed: () {
                                            if (_userLoaded) {
                                              goToEditingScreen(context);
                                            }
                                          },
                                          iconSize: 15))
                                  : CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      radius: 15,
                                      child: IconButton(
                                          icon: const Icon(Icons.chat_rounded,
                                              color: Colors.white),
                                          onPressed: () {
                                            if (_userLoaded) {
                                              goToChatScreen(context);
                                            }
                                          },
                                          iconSize: 15)),
                              Text('   '),
                              curUserObtained && curUser.id == seller.id
                                  ? SizedBox.shrink()
                                  : CircleAvatar(
                                      backgroundColor: Colors.green,
                                      radius: 15,
                                      child: IconButton(
                                          icon: const Icon(Icons.phone,
                                              color: Colors.white),
                                          onPressed: () async {
                                            if (_userLoaded) {
                                              Utils.dialPhoneNumber(
                                                  seller.phoneNumber);
                                            }
                                          },
                                          iconSize: 15)),
                            ],
                          ),
                        ),
                        trailing: curUserObtained && curUser.id == seller.id?SizedBox.shrink():ElevatedButton(
                          child: Text(
                            "Bid",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          onPressed: () {
                            goToBiddingScreen(context, isExpanded: true);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.pink),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ])),
        ));
  }
}
