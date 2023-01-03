import 'package:flutter/services.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'dart:convert';

import '../Classes/Car.dart';
import '../Custom/CarCard.dart';

class ExploreScreen extends StatefulWidget {


  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  

  List<Car> _cars = [];
  final carsRef = FirebaseFirestore.instance.collection('Cars');

  final startPriceController = TextEditingController();
  final endPriceController = TextEditingController();
  final mileageController = TextEditingController();
  final yearValue = TextEditingController();

  late List<String> listOfAllBrands;

  List<String> listOfBrands = [];
  List<String> listOfModels = [];
  late Map<String, dynamic> brandModelInfo;

  int loaded = 0;

  bool isLoading = false;

  bool _initialized = false;
  bool _error = false;

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
        validUntil: map["validUntil"]==null?DateTime.now():map["validUntil"].toDate());
  }

  Future<void> getCars() async{
    loaded = 0;
    setState(() {
      isLoading = true;
      _cars = [];
    });

    var stream = carsRef.snapshots();

    stream.listen(
      (snapshot) {
        snapshot.docs.forEach(
          (carDoc) { 
            setState(() {
              Map<String, dynamic> carMap = carDoc.data() as Map<String, dynamic>;
              _cars.add(mapToCar(carDoc.id, carMap));
              loaded++;
              if(loaded > 5){
                return;
              }
            });
          }
        );
      }
    );
  }

  Future<void> getBrandModelInfo() async{
    final data = await rootBundle.loadString('assets/brandModelInfo.json');

    brandModelInfo = await json.decode(data);

    

    setState(() {
      listOfAllBrands = brandModelInfo.keys.toList();
      listOfAllBrands.sort();
      listOfBrands = listOfAllBrands;
    });

  }

  void updateModelList(List<String> brands) {

    List<dynamic> modelList = [];

    brands.forEach((brand) { 
      modelList = brandModelInfo[brand];

      modelList.forEach((element) {listOfModels.add(element['Name']);});
    });


  }

  @override
  void initState() {
    
    getCars();
    super.initState();
    getBrandModelInfo();
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _error? Text("Error"):
        (isLoading || !_initialized) && _cars.isEmpty
        ? Center(
            child: CircularProgressIndicator(
            color: Colors.pink,
          ))
        : Container(
            child: RefreshIndicator(
            color: Colors.pink,
            onRefresh: () => getCars(),
            child: SizedBox( height: 550,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(height: 100),
                      Expanded(
                        child: ListView.builder(
                            itemCount: _cars.length,
                            itemBuilder: (context, index) => Column(
                                children: [
                                  CarCard(
                                    car: _cars[index],
                      
                                  ),
                                  // if (loaded != favoriteDocs.length &&
                                  //     index == favorites.length - 1)
                                  //   isLoading
                                  //       ? Center(
                                  //           child: CircularProgressIndicator(
                                  //           color: Colors.pink,
                                  //         ))
                                  //       : ElevatedButton(
                                  //           onPressed: () => loadMore(),
                                  //           child: Text("Load More"))
                                ],
                              )
                            ),
                      ),
                    ],
                  ),
                  Container( width:500, 
                    child: 
                        ExpansionTile(
                          tilePadding: EdgeInsets.all(5),
                          childrenPadding: EdgeInsets.all(5),
                          backgroundColor: Colors.white,
                          collapsedBackgroundColor: Colors.white,
                          maintainState: true,
                          title: const Text('Filter...'),
                          children: [
                            Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Price Range: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                Container(width:100,child: TextField(controller: startPriceController, decoration: InputDecoration(labelText: "From"), keyboardType: TextInputType.number, textAlign: TextAlign.center,)),
                                Text(" to "),
                                Container(width:100,child: TextField(controller: endPriceController, decoration: InputDecoration(labelText: "To"), keyboardType: TextInputType.number, textAlign: TextAlign.center,)),
                            ],),
                            Container(width:430,
                              child: Row(
                                children: [
                                  Container( width: 140,
                                    
                                      child: MultiSelectDialogField(
                                        separateSelectedItems: true,
                                        items: listOfBrands.map((e) => MultiSelectItem(e, e)).toList(),
                                        onConfirm: (list){
                                          setState(() {
                                            updateModelList(list);
                                          });
                                        },
                                        buttonIcon: Icon(Icons.arrow_downward, color: Colors.pink,),
                                        searchable: true,
                                        title: const Text('Brand'),
                                        searchHint: 'Brand...',
                                        buttonText: const Text('Brand'),
                                      ),
                                    
                                  ),
                                  Container(width: 140,
                                    
                                      child: MultiSelectDialogField(
                                        separateSelectedItems: true,
                                        items: listOfModels.map((e) => MultiSelectItem(e, e)).toList(),
                                        onConfirm: (list){
                                                      
                                        },
                                        searchable: true,
                                        title: const Text('Model'),
                                        searchHint: 'Model...',
                                        buttonText: const Text('Model'),
                                      ),
                                    
                                  ),
                                  Container(width: 100,
                                    
                                      child: TextField(controller: yearValue, keyboardType: TextInputType.number, decoration: InputDecoration(labelText:"Year"),)
                                    
                                  ),
                                ],
                              ),
                            ),
                            
                          ]
                        
                      )
                  ),
                ],
              ),
            ),
            )
          );
  }




}