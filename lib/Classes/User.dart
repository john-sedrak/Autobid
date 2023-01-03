import 'package:flutter/material.dart';

class User {
  final String id;
  final List<String> favorites;
  final String name;
  final String email;
  final String phoneNumber;

  User({
    required this.id,
    required this.favorites,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });
}
