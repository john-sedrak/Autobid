import 'dart:math';

import 'package:autobid/Lists/governorates.dart';
import 'package:flutter/services.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'dart:convert';

import '../Classes/Car.dart';
import '../Custom/CarCard.dart';
import '../Utils/utils.dart';

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

  Future<void> getCars() async {
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
              _cars.add(Utils.mapToCar(carDoc.id, carMap));
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

  void updateModelList(List<dynamic> brands) {

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
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(height: 55),
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
                  Container( width:500,decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(blurRadius: 5.0, spreadRadius: 3, color: Colors.grey.shade400)
                      ],
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade200,
                    ),
                    child: 
                        ClipRRect( borderRadius: BorderRadius.all(Radius.circular(20)),
                          child: ExpansionTile(
                            iconColor: Colors.grey,
                            collapsedIconColor: Colors.grey,
                            // tilePadding: EdgeInsets.all(5),
                            childrenPadding: EdgeInsets.all(5),
                            backgroundColor: Colors.white,
                            collapsedBackgroundColor: Colors.white,
                            maintainState: true,
                            title: const Text('Filter...'),
                            children: [
                              Container(height:50,
                                child: Row(children: [
                                  Expanded(child: Divider(color: Colors.grey)),
                                  Text(" What are you looking for? ", style: TextStyle(color: Colors.grey)),
                                  Expanded(child: Divider(color: Colors.grey)),
                                ],),
                              ),
                              Container(width:430,
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container( width: 140,
                                      
                                        
                                        child: MultiSelectDialogField(
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                          separateSelectedItems: true,
                                          items: listOfBrands.map((e) => MultiSelectItem(e, e)).toList(),
                                          onConfirm: (list){
                                            setState(() {
                                              updateModelList(list);
                                            });
                                          },
                                          chipDisplay: MultiSelectChipDisplay(scroll: true, textStyle: TextStyle(color: Colors.white), chipColor: Colors.pinkAccent,),
                                          searchable: true,
                                          title: const Text('Brand'),
                                          searchHint: 'Brand...',
                                          buttonText: const Text('Brand'),
                                        ),
                                      
                                    ),
                                    Container(width: 140,
                                      
                                        child: MultiSelectDialogField(
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                          separateSelectedItems: true,
                                          items: listOfModels.map((e) => MultiSelectItem(e, e)).toList(),
                                          onConfirm: (list){
                                                        
                                          },
                                          chipDisplay: MultiSelectChipDisplay(scroll: true, textStyle: TextStyle(color: Colors.white), chipColor: Colors.pinkAccent,),
                                          searchable: true,
                                          title: const Text('Model'),
                                          searchHint: 'Model...',
                                          buttonText: const Text('Model'),
                                        ),

                                    ),
                                  SizedBox(width:100,
                                    child: TextField(
                                      controller: yearValue,
                                      decoration: InputDecoration(
                                        labelText: 'Year',
                                        contentPadding: EdgeInsets.all(5),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                                      ), 
                                      keyboardType: TextInputType.number, textAlign: TextAlign.center,
                                    )
                                  ),
                                  ],
                                ),
                              ),
                              Container(height:50,
                                child: Row(children: [
                                  Expanded(child: Divider(color: Colors.grey)),
                                  Text(" Price Range ", style: TextStyle(color: Colors.grey)),
                                  Expanded(child: Divider(color: Colors.grey)),
                                ],),
                              ),
                              Container( width: 300,
                                child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(width:80,
                                      child: TextField(
                                        controller: startPriceController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(5),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                                        ), 
                                        keyboardType: TextInputType.number, textAlign: TextAlign.center,
                                      )
                                    ),
                                    Icon(Icons.arrow_forward),
                                    SizedBox(width:80,
                                      child: TextField(
                                        controller: endPriceController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(5),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                                        ), 
                                        keyboardType: TextInputType.number, textAlign: TextAlign.center,
                                      )
                                    ),
                                    Text(" EGP")
                                  ]
                                ),
                              ),
                              Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(height:50,width: 200,
                                    child: Row(children: [
                                      Expanded(child: Divider(color: Colors.grey)),
                                      Text(" Mileage below ", style: TextStyle(color: Colors.grey)),
                                      Expanded(child: Divider(color: Colors.grey)),
                                    ],),
                                  ),
                                  
                                  Container(height:50,width: 200,
                                    child: Row(children: [
                                      Expanded(child: Divider(color: Colors.grey)),
                                      Text(" Location ", style: TextStyle(color: Colors.grey)),
                                      Expanded(child: Divider(color: Colors.grey)),
                                    ],),
                                  ),
                                ],
                              ),
                              Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(width: 170,
                                    child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(width:80,
                                          child: TextField(
                                            controller: endPriceController,
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(5),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                                            ), 
                                            keyboardType: TextInputType.number, textAlign: TextAlign.center,
                                          )
                                        ),
                                        Text(' '),
                                        Text(' '),
                                        Text(" km")
                                      ],
                                    ),
                                  ),
                                  Container(height: 110,child: Expanded(child: VerticalDivider(color: Colors.grey, thickness: 1))),
                                  Container(width: 170,
                                      child: Center(
                                        
                                          child: MultiSelectDialogField(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(10)
                                            ),
                                            separateSelectedItems: true,
                                            items: governorates.map((e) => MultiSelectItem(e, e)).toList(),
                                            onConfirm: (list){
                                                          
                                            },
                                            chipDisplay: MultiSelectChipDisplay(scroll: true, textStyle: TextStyle(color: Colors.white), chipColor: Colors.pinkAccent,),
                                            searchable: true,
                                            title: const Text('Location'),
                                            searchHint: 'Location...',
                                            buttonText: const Text('Location'),
                                          ),
                                        
                                      ),
                                    ),
                                ],
                              ),
                            ]
                          ),
                        )
                  ),
                ],
              ),
            )
          );
  }




}
