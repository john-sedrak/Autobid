import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Classes/Car.dart';
import '../Custom/CarCard.dart';
import '../Utils/utils.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});
  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  List<Car> _cars = [];

  final FirebaseAuth auth = FirebaseAuth.instance;

  final carsRef = FirebaseFirestore.instance.collection('Cars');

  int loaded = 0;

  bool isLoading = false;

  bool _initialized = false;

  bool _error = false;

  Future<void> getCars() async {
    loaded = 0;
    setState(() {
      isLoading = true;
      _cars = [];
    });
    final User? user = await auth.currentUser;

    var stream = carsRef.where("sellerID", isEqualTo: user!.uid).snapshots();

    stream.listen((snapshot) {
      snapshot.docs.forEach((carDoc) {
        setState(() {
          Map<String, dynamic> carMap = carDoc.data() as Map<String, dynamic>;
          _cars.add(Utils.mapToCar(carDoc.id, carMap));
          loaded++;
        });
      });
    });
  }

  @override
  void initState() {
    getCars();
    super.initState();
    setState(() {
      _initialized = true;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _error
        ? Text("Error")
        : (isLoading || !_initialized) && _cars.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                color: Colors.pink,
              ))
            : (_initialized && _cars.isEmpty)
                ? Center(
                    child: Text("You have not added any listings yet."),
                  )
                : Container(
                    child: RefreshIndicator(
                    color: Colors.pink,
                    onRefresh: () => getCars(),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                  itemCount: _cars.length,
                                  itemBuilder: (context, index) => Column(
                                        children: [
                                          CarCard(
                                            car: _cars[index],
                                          ),
                                        ],
                                      )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
  }
}
