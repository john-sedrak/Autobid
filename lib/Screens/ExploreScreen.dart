import 'package:flutter/material.dart';

import '../Classes/Car.dart';
import '../Custom/CarCard.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: CarCard(
            car: Car(
                id: 'cid1',
                mileage: 2000,
                bidderID: '',
                sellerID: '',
                brand: 'Mercedes',
                model: 'A-Class',
                year: 2022,
                currentBid: 0,
                startingPrice: 1000000,
                sellerDescription: 'Best Car',
                validUntil: DateTime.utc(2022, 12, 31),
                carImagePaths: [
          'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
          'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
          'https://image.shutterstock.com/image-photo/plate-delicious-chicken-alfredo-on-600w-613083071.jpg',
          'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
          'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
          'https://image.shutterstock.com/image-photo/plate-delicious-chicken-alfredo-on-600w-613083071.jpg',
          'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
          'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
          'https://image.shutterstock.com/image-photo/plate-delicious-chicken-alfredo-on-600w-613083071.jpg',
          'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
          'https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg',
          'https://image.shutterstock.com/image-photo/plate-delicious-chicken-alfredo-on-600w-613083071.jpg'
        ])));
  }
}
