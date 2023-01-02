import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Classes/Car.dart';
import '../Custom/CarCard.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Car> _cars = [];
  final carsRef = FirebaseFirestore.instance.collection('Cars');

  int loaded = 0;

  bool isLoading = false;

  bool _initialized = false;
  bool _error = false;

  Car mapToCar(String id, Map<String, dynamic> map) {
    List<String> images = [];
    for (var img in map["images"]) {
      images.add(img.toString());
    }

    return Car(
        id: id,
        carImagePaths: images,
        mileage: double.parse(map["mileage"].toString()),
        bidderID: map["bidderID"].toString(),
        sellerID: map["sellerID"].toString(),
        brand: map["brand"].toString(),
        model: map["model"].toString(),
        year: int.parse(map["year"].toString()),
        currentBid: double.parse(map["currentBid"].toString()),
        startingPrice: double.parse(map["startingPrice"].toString()),
        sellerDescription: map["description"].toString(),
        validUntil: map["validUntil"].toDate());
  }

  Future<void> getCars() async {
    loaded = 0;
    setState(() {
      isLoading = true;
      _cars = [];
    });

    var stream = carsRef.snapshots();

    stream.listen((snapshot) {
      snapshot.docs.forEach((carDoc) {
        setState(() {
          Map<String, dynamic> carMap = carDoc.data() as Map<String, dynamic>;
          _cars.add(mapToCar(carDoc.id, carMap));
          loaded++;
        });
      });
    });
  }

  @override
  void initState() {
    getCars();
    super.initState();
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _error
        ? Text("Error")
        : (isLoading || !_initialized) && _cars.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                color: Colors.pink,
              ))
            : Container(
                child: RefreshIndicator(
                color: Colors.pink,
                onRefresh: () => getCars(),
                child: ListView.builder(
                    itemCount: _cars.length,
                    itemBuilder: (context, index) => Column(
                          children: [
                            CarCard(
                              car: _cars[index],
                            ),
                            // if (loaded != favoriteDocs.length &&
                            //     index == favorites.length - 1)
                            //   isLoading
                            //       ? Center(
                            //           child: CircularProgressIndicator(
                            //           color: Colors.pink,
                            //         ))
                            //       : ElevatedButton(
                            //           onPressed: () => loadMore(),
                            //           child: Text("Load More"))
                          ],
                        )),
              ));
  }
}
    // return Container(
    //   child: CarCard(car: Car(id:'cid1', mileage: 2000, bidderID: '', sellerID: '', brand: 'Mercedes', model: 'A-Class',
    //   year: 2022, currentBid: 0, startingPrice: 1000000, sellerDescription: 'Best Car', validUntil: DateTime.utc(2022,12,31),
    //   carImagePaths: ['https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
    //   'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
    //   'https://image.shutterstock.com/image-photo/plate-delicious-chicken-alfredo-on-600w-613083071.jpg',
    //   'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
    //   'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
    //   'https://image.shutterstock.com/image-photo/plate-delicious-chicken-alfredo-on-600w-613083071.jpg',
    //   'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
    //   'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
    //   'https://image.shutterstock.com/image-photo/plate-delicious-chicken-alfredo-on-600w-613083071.jpg',
    //   'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
    //   'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
    //   'https://image.shutterstock.com/image-photo/plate-delicious-chicken-alfredo-on-600w-613083071.jpg']
    //   ))
