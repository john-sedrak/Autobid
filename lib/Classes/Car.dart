import 'package:flutter/material.dart';

class Car{

  final String id;
  final List<String> carImagePaths;
  final double mileage;
  final String bidderID;
  final String sellerID;
  final String brand;
  final String model;
  final int year;
  final double currentBid;
  final double startingPrice;
  final String sellerDescription;

  Car({required this.id, required this.carImagePaths, required this.mileage, required this.bidderID, required this.sellerID,
        required this.brand, required this.model, required this.year, required this.currentBid, required this.startingPrice,
        required this.sellerDescription});


}