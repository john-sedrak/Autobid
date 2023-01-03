import 'package:autobid/Classes/Car.dart';
import 'package:autobid/Classes/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static Future<void> dialPhoneNumber(String phoneNumber) async {
    final call = Uri.parse('tel:+20 ${phoneNumber}');
    if (await canLaunchUrl(call)) {
      launchUrl(call);
    } else {
      throw 'Could not launch $call';
    }
  }

  static Car mapToCar(String id, Map<String, dynamic> map) {
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

  static UserModel mapToUser(String id, Map<String, dynamic> map) {
    List<String> favorites = [];
    for (var img in map["favorites"]) {
      favorites.add(img.toString());
    }

    UserModel u = UserModel(
        id: id,
        favorites: favorites,
        name: map["name"].toString(),
        email: map["email"].toString(),
        phoneNumber: map["phone"].toString());
    return u;
  }

  static Future<void> addOrRemoveFromFavorites(UserModel u, String carId) {
    List<String> favIds = u.favorites;

    int index = favIds.indexOf(carId);
    if (index == -1) {
      //add to fav
      favIds.add(carId);
    } else {
      //remove from fav
      favIds.removeAt(index);
    }
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(u.id)
        .update({"favorites": favIds});
  }
}
