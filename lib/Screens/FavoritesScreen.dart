import 'dart:math';
import 'package:autobid/Classes/Car.dart';
import 'package:autobid/Classes/UserModel.dart';
import 'package:autobid/Custom/FavoriteCard.dart';
import 'package:autobid/Providers/UserProvider.dart';
import 'package:autobid/Screens/AuthenticationScreens/errorMessage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  final carsRef = FirebaseFirestore.instance.collection('Cars');

  List<Car> favorites = [];

  List favoriteIds = [];
  int loaded = 0;

  int pageSize = 8;

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
        location: map["location"].toString(),
        validUntil: map["validUntil"].toDate());
  }

  void getFavorites() {
    loaded = 0;
    setState(() {
      isLoading = true;
      favorites = [];
      favoriteIds = [];
    });

    final docRef = FirebaseFirestore.instance.collection('Users').doc(userId);

    docRef.get().then(
      (DocumentSnapshot doc) async {
        final data = doc.data() as Map<String, dynamic>;
        var favs = data["favorites"];

        addAllFavoriteIds(favs);

        List<Car> newFavs = [];
        List<dynamic> newFavIds = List<dynamic>.from(favoriteIds);

        for (int i = 0; i < min(pageSize, favoriteIds.length); i++) {
          var fav = favoriteIds[i];
          try {
            DocumentSnapshot carDoc = await carsRef.doc(fav).get();
            Map<String, dynamic> carMap = carDoc.data() as Map<String, dynamic>;
            Car car = mapToCar(fav, carMap);
            newFavs.add(car);
            loaded++;
          } catch (e) {
            if (e.toString() ==
                    "type 'Null' is not a subtype of type 'Map<String, dynamic>' in type cast" &&
                i < newFavIds.length) {
              newFavIds.removeAt(i);
            }
            // loaded++;
          }
        }

        if (favoriteIds.length != newFavIds.length) {
          final docRef =
              FirebaseFirestore.instance.collection('Users').doc(userId);
          docRef.update({"favorites": newFavIds}).then((value) {
            getFavorites();
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }

        setState(() {
          favorites = newFavs;
          favoriteIds = newFavIds;
        });
      },
    );
  }

  void addAllFavoriteIds(List firebaseDocReferences) {
    List newIds = [];

    firebaseDocReferences.forEach((element) {
      newIds.add(element);
    });

    favoriteIds = newIds;
  }

  void loadMore() async {
    setState(() {
      isLoading = true;
    });

    List<Car> newFavs = favorites;
    List<dynamic> newFavIds = List<dynamic>.from(favoriteIds);
    for (int i = loaded; i < min(loaded + pageSize, favoriteIds.length); i++) {
      String fav = favoriteIds[i];
      try {
        DocumentSnapshot carDoc = await carsRef.doc(fav).get();
        Map<String, dynamic> carMap = carDoc.data() as Map<String, dynamic>;
        Car car = mapToCar(fav, carMap);
        newFavs.add(car);
        loaded++;
      } catch (e) {
        if (e.toString() ==
                "type 'Null' is not a subtype of type 'Map<String, dynamic>' in type cast" &&
            i < newFavIds.length) {
          newFavIds.removeAt(i);
        }
        //loaded++;
      }

      if (favoriteIds.length != newFavIds.length) {
        final docRef =
            FirebaseFirestore.instance.collection('Users').doc(userId);
        docRef.update({"favorites": newFavIds}).then((value) {});
      }
      // DocumentSnapshot carDoc = await carsRef.doc(fav).get();
      // if (carDoc.data() == null) {
      //   setState(() {
      //     isLoading = false;
      //   });
      //   return;
      // }
      // Map<String, dynamic> carMap = carDoc.data() as Map<String, dynamic>;
      // Car car = mapToCar(fav, carMap);
      // newFavs.add(car);
      // loaded++;
    }
    setState(() {
      favorites = newFavs;
      isLoading = false;
      favoriteIds = newFavIds;
    });
  }

  void removeFromFavorites(int index) {
    setState(() {
      favorites.removeAt(index);
    });

    String idToRemove = favoriteIds[index];
    favoriteIds.removeAt(index);

    final docRef = FirebaseFirestore.instance.collection('Users').doc(userId);

    docRef.update({"favorites": favoriteIds});
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
            color: Color(0xFFE91E62),
          ))
        : favorites.isEmpty
            ? Center(
                child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Image.asset(
                    'lib/Assets/nofavs2.gif',
                    height: 150,
                    fit: BoxFit.scaleDown,
                  ),
                  Text(
                    "Getting Kinda lonely in here!\nFollow listings or make bids and track them in this tab!",
                    textAlign: TextAlign.center,
                  )
                ],
              ))
            : Container(
                child: RefreshIndicator(
                color: Colors.pink,
                onRefresh: () {
                  return Future(getFavorites);
                },
                child: ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) => Column(
                          children: [
                            Dismissible(
                              key: Key(favoriteIds[index]),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) =>
                                  removeFromFavorites(index),
                              background: Container(
                                  color: Colors.red,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text(
                                          "Remove From\n Following",
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
                                sellerCard: favorites[index].sellerID == userId,
                                isHighestBidder:
                                    favorites[index].bidderID == userId,
                              ),
                            ),
                            if (loaded < favoriteIds.length &&
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
