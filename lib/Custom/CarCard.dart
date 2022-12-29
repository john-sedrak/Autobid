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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1, initialPage: 0);
  }

  void goToBiddingScreen(BuildContext context) {
    Navigator.of(context)
        .pushNamed('/bidRoute', arguments: {'car': widget.car});
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
                                          setState(() {
                                            isFav = !isFav;
                                          });
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
                        subtitle: Row(children: [
                          Icon(Icons.speed),
                          Text(
                            addCommas(" ${widget.car.mileage.round()}"),
                            style: TextStyle(color: Colors.grey),
                          )
                        ]),
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
                                    fontSize: 24, fontWeight: FontWeight.bold),
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
                                    'U',
                                    style: TextStyle(
                                        fontSize: 25, color: Colors.white),
                                  )),
                              Text('  '),
                              CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 15,
                                  child: IconButton(
                                      icon: const Icon(Icons.chat_rounded,
                                          color: Colors.white),
                                      onPressed: () {},
                                      iconSize: 15)),
                              Text('   '),
                              CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 15,
                                  child: IconButton(
                                      icon: const Icon(Icons.phone,
                                          color: Colors.white),
                                      onPressed: () {},
                                      iconSize: 15)),
                            ],
                          ),
                        ),
                        trailing: ElevatedButton(
                          child: Text(
                            "Bid",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          onPressed: () {
                            goToBiddingScreen(context);
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
