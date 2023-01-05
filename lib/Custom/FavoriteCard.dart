import 'dart:io';

import 'package:autobid/Classes/Car.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

class FavoriteCard extends StatefulWidget {
  Car car;

  bool sellerCard;
  bool isHighestBidder;
  FavoriteCard(
      {super.key,
      required this.car,
      this.sellerCard = false,
      this.isHighestBidder = false});

  @override
  State<FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {
  void goToBiddingScreen(BuildContext context, {bool isExpanded = false}) {
    if (widget.car.sellerID == FirebaseAuth.instance.currentUser!.uid) {
      Navigator.of(context)
          .pushNamed('/myListingRoute', arguments: {'car': widget.car});
    } else {
      Navigator.of(context).pushNamed('/bidRoute',
          arguments: {'car': widget.car, 'isExpanded': isExpanded});
    }
  }

  String addCommas(String s) {
    return s.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  bool ActiveConnection = false;
  String T = "";
  Future CheckUserConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          ActiveConnection = true;
          T = "Turn off the data and repress again";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        ActiveConnection = false;
        T = "Turn On the data and repress again";
      });
    }
  }

  Image getImage(String url, {double width = 180, double height = 180}) {
    try {
      return Image.network(url,
          fit: BoxFit.cover,
          height: height,
          width: width,
          errorBuilder: (context, error, stackTrace) => Image.asset(
              "lib/Assets/placeholder.jpg",
              height: 180,
              fit: BoxFit.cover));
    } on SocketException catch (_) {
      return Image.asset("lib/Assets/placeholder.jpg",
          height: 180, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool bidExpired = DateTime.now().isAfter(widget.car.validUntil);

    return InkWell(
        onTap: () => goToBiddingScreen(context),
        child: SizedBox(
          height: 180,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            margin: EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15)),
                    child: widget.car.carImagePaths.length > 0
                        ? getImage(widget.car.carImagePaths[0])
                        : Image.asset("lib/Assets/placeholder.jpg",
                            height: 180, fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            "${widget.car.brand} ${widget.car.model} ${widget.car.year.toString()}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(children: [
                                      const Icon(Icons.speed),
                                      Text(
                                        addCommas(
                                            " ${widget.car.mileage.round()}"),
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    ]),
                                  ),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                              widget.car.bidderID == ''
                                                  ? 'Starting at'
                                                  : 'Current bid at',
                                              style: const TextStyle(
                                                  fontSize: 10)),
                                          Text(
                                              addCommas(widget.car.bidderID ==
                                                      ''
                                                  ? '${widget.car.startingPrice.round()} EGP'
                                                  : '${widget.car.currentBid.round()} EGP'),
                                              overflow: TextOverflow.clip,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              )),
                                          Text(
                                              'Until ${DateFormat('dd-MM-yy').format(widget.car.validUntil)}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ))
                                        ]),
                                  ),
                                ],
                              )),
                          if (!widget.sellerCard)
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 8,
                                    child: OutlinedButton(
                                      onPressed:
                                          widget.isHighestBidder || bidExpired
                                              ? null
                                              : () {
                                                  goToBiddingScreen(context,
                                                      isExpanded: true);
                                                },
                                      style: widget.isHighestBidder ||
                                              bidExpired
                                          ? ButtonStyle(
                                              foregroundColor:
                                                  MaterialStateProperty.all(
                                                      Color.fromARGB(
                                                          255, 65, 23, 37)),
                                              overlayColor:
                                                  MaterialStateProperty.all(
                                                      Color.fromARGB(
                                                          255, 65, 23, 37)),
                                              side: MaterialStateProperty.all(
                                                  const BorderSide(
                                                      width: 1,
                                                      color: Color.fromARGB(
                                                          255, 65, 23, 37))))
                                          : ButtonStyle(
                                              foregroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.pink),
                                              overlayColor:
                                                  MaterialStateProperty.all(
                                                      Colors.pink.shade200),
                                              side: MaterialStateProperty.all(
                                                  const BorderSide(
                                                      width: 1,
                                                      color: Colors.pink)),

                                              // side: MaterialStateProperty.all(
                                              //     Colors.pink),
                                            ),
                                      child: widget.isHighestBidder
                                          ? const Text("Your Bid",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color.fromARGB(
                                                      255, 65, 23, 37)))
                                          : bidExpired
                                              ? const Text("Bidding is over!",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color.fromARGB(
                                                          255, 65, 23, 37)))
                                              : const Text(
                                                  "Bid",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.pink),
                                                ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ));
  }
}
