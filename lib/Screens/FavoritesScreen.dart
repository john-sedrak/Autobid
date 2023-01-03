import 'dart:math';
import 'package:autobid/Classes/Car.dart';
import 'package:autobid/Custom/FavoriteCard.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String userId = "RoFvf4QhbYY3dybd0nDulXzxLcK2";
  final carsRef = FirebaseFirestore.instance.collection('Cars');

  List<Car> favorites = [];
  List<String> favoriteIds = [];
  int loaded = 0;

  int pageSize = 3;

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

  void getFavorites() {
    final docRef = FirebaseFirestore.instance.collection('Users').doc(userId);

    docRef.get().then(
      (DocumentSnapshot doc) async {
        final data = doc.data() as Map<String, dynamic>;
        var favs = data["favorites"];

        addAllFavoriteIds(favs);

        List<Car> newFavs = [];

        for (int i = 0; i < min(pageSize, favoriteIds.length); i++) {
          var fav = favoriteIds[i];
          DocumentSnapshot carDoc = await carsRef.doc(fav).get();
          Map<String, dynamic> carMap = carDoc.data() as Map<String, dynamic>;
          Car car = mapToCar(fav, carMap);
          newFavs.add(car);
          loaded++;
        }

        setState(() {
          favorites = newFavs;
        });

        // favs.forEach((fav) async {
        //   DocumentSnapshot carDoc = await carsRef.doc(fav.id).get();
        //   Map<String, dynamic> carMap = carDoc.data() as Map<String, dynamic>;
        //   Car car = mapToCar(fav.id, carMap);
        //   newFavs.add(car);
        //   setState(() {
        //     favorites = newFavs;
        //   });
        // });
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  void addAllFavoriteIds(List firebaseDocReferences) {
    List<String> newIds = [];

    firebaseDocReferences.forEach((element) {
      newIds.add(element.id);
    });

    favoriteIds = newIds;
  }

  void loadMore() async {
    List<Car> newFavs = favorites;

    for (int i = loaded; i < min(loaded + pageSize, favoriteIds.length); i++) {
      var fav = favoriteIds[i];
      DocumentSnapshot carDoc = await carsRef.doc(fav).get();
      Map<String, dynamic> carMap = carDoc.data() as Map<String, dynamic>;
      Car car = mapToCar(fav, carMap);
      newFavs.add(car);
      loaded++;
    }
    setState(() {
      favorites = newFavs;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getFavorites();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) => index == favorites.length - 1
          ? Column(
              children: [
                FavoriteCard(
                  car: favorites[index],
                ),
                if (loaded != favoriteIds.length)
                  ElevatedButton(
                      onPressed: () => loadMore(), child: Text("Load More"))
              ],
            )
          : FavoriteCard(
              car: favorites[index],
            ),
    )
        //
        // FavoriteCard(
        //     car: Car(
        //         id: 'cid1',
        //         mileage: 2000,
        //         bidderID: '',
        //         sellerID: '',
        //         brand: 'Mercedes',
        //         model: 'A-Class',
        //         year: 2022,
        //         currentBid: 0,
        //         startingPrice: 1000000,
        //         sellerDescription: 'Best Car',
        //         validUntil: DateTime.utc(2022, 12, 31),
        //         carImagePaths: [
        //   'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
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
        //   'https://image.shutterstock.com/image-photo/plate-delicious-chicken-alfredo-on-600w-613083071.jpg'
        // ]))
        );
    ;
  }
}
