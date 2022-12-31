import 'package:flutter/material.dart';

class ListingsScreen extends StatelessWidget {
  const ListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }
}