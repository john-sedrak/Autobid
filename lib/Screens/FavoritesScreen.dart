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

  List favoriteDocs = [];
  int loaded = 0;

  int pageSize = 3;

  bool isLoading = false;

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
    loaded = 0;
    setState(() {
      isLoading = true;
      favorites = [];
      favoriteDocs = [];
    });

    final docRef = FirebaseFirestore.instance.collection('Users').doc(userId);

    docRef.get().then(
      (DocumentSnapshot doc) async {
        final data = doc.data() as Map<String, dynamic>;
        var favs = data["favorites"];

        addAllFavoriteIds(favs);

        List<Car> newFavs = [];

        for (int i = 0; i < min(pageSize, favoriteDocs.length); i++) {
          var fav = favoriteDocs[i].id;
          DocumentSnapshot carDoc = await carsRef.doc(fav).get();
          Map<String, dynamic> carMap = carDoc.data() as Map<String, dynamic>;
          Car car = mapToCar(fav, carMap);
          newFavs.add(car);
          loaded++;
        }
        setState(() {
          favorites = newFavs;
          isLoading = false;
        });
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  void addAllFavoriteIds(List firebaseDocReferences) {
    List newIds = [];

    firebaseDocReferences.forEach((element) {
      newIds.add(element);
    });

    favoriteDocs = newIds;
  }

  void loadMore() async {
    setState(() {
      isLoading = true;
    });

    List<Car> newFavs = favorites;

    for (int i = loaded; i < min(loaded + pageSize, favoriteDocs.length); i++) {
      var fav = favoriteDocs[i].id;
      DocumentSnapshot carDoc = await carsRef.doc(fav).get();
      Map<String, dynamic> carMap = carDoc.data() as Map<String, dynamic>;
      Car car = mapToCar(fav, carMap);
      newFavs.add(car);
      loaded++;
    }
    setState(() {
      favorites = newFavs;
      isLoading = false;
    });
  }

  void removeFromFavorites(int index) {
    setState(() {
      favorites.removeAt(index);
    });

    String idToRemove = favoriteDocs[index].id;
    favoriteDocs.removeAt(index);

    final docRef = FirebaseFirestore.instance.collection('Users').doc(userId);

    docRef
        .update({"favorites": favoriteDocs}).then((value) => print("removed"));
    loaded--;
  }

  @override
  void initState() {
    // TODO: implement initState
    getFavorites();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading && favorites.isEmpty
        ? Center(
            child: CircularProgressIndicator(
            color: Colors.pink,
          ))
        : Container(
            child: RefreshIndicator(
            color: Colors.pink,
            onRefresh: () => Future(getFavorites),
            child: ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) => Column(
                      children: [
                        Dismissible(
                          key: Key(favorites[index].id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) =>
                              removeFromFavorites(index),
                          background: Container(
                              color: Colors.red,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(
                                      "Remove From\n Favorites",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              )),
                          child: FavoriteCard(
                            car: favorites[index],
                          ),
                        ),
                        if (loaded != favoriteDocs.length &&
                            index == favorites.length - 1)
                          isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                  color: Colors.pink,
                                ))
                              : ElevatedButton(
                                  onPressed: () => loadMore(),
                                  child: Text("Load More"))
                      ],
                    )),
          ));
  }
}
