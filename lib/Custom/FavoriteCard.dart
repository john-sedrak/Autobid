import 'package:autobid/Classes/Car.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

class FavoriteCard extends StatefulWidget {
  Car car;
  FavoriteCard({super.key, required this.car});

  @override
  State<FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {
  void goToBiddingScreen(BuildContext context) {
    Navigator.of(context)
        .pushNamed('/bidRoute', arguments: {'car': widget.car});
  }

  String addCommas(String s) {
    return s.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Image.network(
                      widget.car.carImagePaths.isEmpty
                          ? "https://craftsnippets.com/articles_images/placeholder/placeholder.jpg"
                          : widget.car.carImagePaths[0],
                      height: 180,
                      fit: BoxFit.cover,
                    ),
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
                                            addCommas(widget.car.bidderID == ''
                                                ? '${widget.car.startingPrice.round()} EGP'
                                                : '${widget.car.currentBid.round()} EGP'),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                              'Until ${DateFormat('dd-MM-yy').format(widget.car.validUntil)}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ))
                                        ]),
                                  ),
                                ],
                              )),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 8,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      goToBiddingScreen(context);
                                    },
                                    style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Colors.pink),
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.pink.shade200),
                                      side: MaterialStateProperty.all(
                                          const BorderSide(
                                              width: 1, color: Colors.pink)),

                                      // side: MaterialStateProperty.all(
                                      //     Colors.pink),
                                    ),
                                    child: const Text(
                                      "Bid",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.pink),
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
