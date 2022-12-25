import 'package:flutter/material.dart';

import 'Car.dart';
import 'CarCard.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CarCard(car: Car(id:'cid1', mileage: 100, bidderID: '', sellerID: '', brand: 'Mercedes', model: 'S Class',
      year: 2020, currentBid: 0, startingPrice: 1000000, sellerDescription: 'Best Car',
      carImagePaths: ['https://assets.bonappetit.com/photos/57af6bea53e63daf11a4e565/16:9/w_1280,c_limit/fattoush.jpg']
      ))
    );
  }
}