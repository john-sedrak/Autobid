import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final List<String> favorites;
  final String name;
  final String email;
  final String phoneNumber;

  UserModel({
    required this.id,
    required this.favorites,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });
}
