import 'dart:ffi';
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
  List<Car> displayCars = [];
  final carsRef = FirebaseFirestore.instance.collection('Cars');

  final startPriceController = TextEditingController();
  final endPriceController = TextEditingController();
  final mileageController = TextEditingController();
  final yearValue = TextEditingController();

  late List<String> listOfAllBrands;

  List<String> listOfBrands = [];
  List<String> listOfModels = [];
  List<int> listOfYears = List<int>.generate(60, (index) => DateTime.now().year-(60-index));
  late Map<String, dynamic> brandModelInfo;

  List<String> queryBrands = [];
  List<String> queryModels = [];
  List<int> queryYears = [];
  double queryPriceLowerBound = 0;
  double queryPriceUpperBound = double.infinity;
  double queryMileageUpperBound = double.infinity;
  List<String> queryLocations = [];

  int displayLimit = 5;

  bool isLoading = false;

  bool _initialized = false;
  bool _error = false;

  Future<void> getCars() async {
    setState(() {
      isLoading = true;
      _cars = [];
    });

    print(queryBrands);

    var stream = carsRef.snapshots();


    stream.listen(
      (snapshot) {
        snapshot.docs.forEach(
          (carDoc) { 
            setState(() {
              Map<String, dynamic> carMap = carDoc.data() as Map<String, dynamic>;
              Car carToAdd = Utils.mapToCar(carDoc.id, carMap);
              _cars.add(carToAdd);
            });
          }
        );
      }
    );

  }

  Future<void> getBrandModelInfo() async {
    final data = await rootBundle.loadString('assets/brandModelInfo.json');

    brandModelInfo = await json.decode(data);

    setState(() {
      listOfAllBrands = brandModelInfo.keys.toList();
      listOfAllBrands.sort();
      listOfBrands = List.from(listOfAllBrands);
    });
  }

  void updateModelList(List<dynamic> brands) {
    List<dynamic> modelList = [];

    brands.forEach((brand) {
      modelList = brandModelInfo[brand];

      modelList.forEach((element) {
        listOfModels.add(element['Name']);
      });
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

  int findIndexReach(){
    int displayed = 0;
    for(int i =0; i < _cars.length; i++){
      if(!isCarFiltered(_cars[i])){
        displayed++;
      }
      if(displayed == displayLimit){
        return i;
      }
    }
    return -1;
  }

  bool isCarFiltered(Car carToAdd){
    if(!queryBrands.isEmpty){
      if(!queryBrands.contains(carToAdd.brand)){
        return true;
      }
    }
    if(!queryModels.isEmpty){
      if(!queryModels.contains(carToAdd.model)){
        return true;
      }
    }
    if(!queryYears.isEmpty){
      if(!queryYears.contains(carToAdd.year)){
        return true;
      }
    }
    if(carToAdd.bidderID.length == 0){
      if(carToAdd.startingPrice < queryPriceLowerBound || carToAdd.startingPrice > queryPriceUpperBound){
        return true;
      }
    }
    else{
      if(carToAdd.currentBid < queryPriceLowerBound || carToAdd.currentBid > queryPriceUpperBound){
        return true;
      }
    }
    if(!(carToAdd.mileage <= queryMileageUpperBound)){
      return true;
    }
    if(!queryLocations.isEmpty){
      if(!queryLocations.contains(carToAdd.location)){
        return true;
      }
    }
    return false;
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
                            itemBuilder: (context, index){
                              return
                              isCarFiltered(_cars[index])? SizedBox.shrink():
                              CarCard(  
                                car: _cars[index],
                              );
                              // ElevatedButton(onPressed: (){setState(() {
                              //   displayLimit+=6;
                              // });}, 
                              // child: Text(
                              //   "Load More", 
                              //   style: TextStyle(color: Colors.pink),
                              // )
                              // );
                            }
                              )
                            ),
                      
                    ],
                  ),
                  Container( width:500,decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(blurRadius: 5.0, spreadRadius: 3, color: Colors.grey.shade400)

                      ],
                    ),
                    Container(
                        width: 500,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 5.0,
                                spreadRadius: 3,
                                color: Colors.grey.shade400)
                          ],
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey.shade200,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
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
                                           
                                          items: listOfBrands.map((e) => MultiSelectItem(e, e)).toList(),
                                          initialValue: queryBrands,
                                          onConfirm: (list){
                                            queryBrands = [];
                                            list.forEach((element) {
                                              queryBrands.add(element.toString()); 
                                            });
                                            updateModelList(list);
                                            setState(() {
                                              
                                            });
                                          },
                                          chipDisplay: MultiSelectChipDisplay(
                                            scroll: true,
                                            textStyle:
                                                TextStyle(color: Colors.white),
                                            chipColor: Colors.pinkAccent,
                                          ),
                                          searchable: true,
                                          title: const Text('Brand'),
                                          searchHint: 'Brand...',
                                          buttonText: const Text('Brand'),
                                        ),
                                      ),
                                      Container(
                                        width: 140,
                                        child: MultiSelectDialogField(
                                          decoration: BoxDecoration(

                                            border: Border.all(),
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                           
                                          items: listOfModels.map((e) => MultiSelectItem(e, e)).toList(),
                                          initialValue: queryModels,
                                          onConfirm: (list){
                                            queryModels = [];
                                            list.forEach((element) {
                                              queryModels.add(element.toString()); 
                                            });
                                            setState(() {
                                              
                                            });
                                          },
                                          chipDisplay: MultiSelectChipDisplay(scroll: true, textStyle: TextStyle(color: Colors.white), chipColor: Colors.pinkAccent,),
                                          searchable: true,
                                          title: const Text('Model'),
                                          searchHint: 'Model...',
                                          buttonText: const Text('Model'),
                                        ),

                                    ),
                                  SizedBox(width:100,
                                    child: MultiSelectDialogField(
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                           
                                          items: listOfYears.map((e) => MultiSelectItem(e, e.toString())).toList(),
                                          initialValue: queryYears,
                                          onConfirm: (list){
                                            queryYears = [];
                                            list.forEach((element) {
                                              queryYears.add(element); 
                                            });
                                            setState(() {
                                              
                                            });
                                          },
                                          chipDisplay: MultiSelectChipDisplay(scroll: true, textStyle: TextStyle(color: Colors.white), chipColor: Colors.pinkAccent,),
                                          searchable: true,
                                          title: const Text('Year'),
                                          searchHint: 'Year...',
                                          buttonText: const Text('Year'),
                                        ),
                                  ),
                                ),
                                Container(
                                  width: 300,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            width: 80,
                                            child: TextField(
                                              controller: startPriceController,
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.all(5),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10))),
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                            )),
                                        Icon(Icons.arrow_forward),
                                        SizedBox(
                                            width: 80,
                                            child: TextField(
                                              controller: endPriceController,
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.all(5),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10))),
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                            )),
                                        Text(" EGP")
                                      ]),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(width:80,
                                      child: TextField(
                                        controller: startPriceController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(5),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                                        ), 
                                        keyboardType: TextInputType.number, textAlign: TextAlign.center,
                                         onChanged: (value){
                                          
                                          setState(() {
                                            queryPriceLowerBound = startPriceController.text == ''?0:double.parse(startPriceController.text);
                                          });
                                        },
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
                                         onChanged: (value){
                                          
                                          setState(() {
                                            queryPriceUpperBound = endPriceController.text == ''?double.infinity:double.parse(endPriceController.text);
                                          });
                                        },
                                      )
                                    ),
                                  ],
                                ),
                              ),
                              Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(height:50,width: 180,
                                    child: Row(children: [
                                      Expanded(child: Divider(color: Colors.grey)),
                                      Text(" Mileage below ", style: TextStyle(color: Colors.grey)),
                                      Expanded(child: Divider(color: Colors.grey)),
                                    ],),
                                  ),
                                  Container(height:50,width: 180,
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
                                            controller: mileageController,
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(5),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                                            ), 
                                            keyboardType: TextInputType.number, textAlign: TextAlign.center,
                                             onChanged: (value){
                                              
                                              setState(() {
                                                queryMileageUpperBound = mileageController.text == ''?double.infinity:double.parse(mileageController.text);
                                              });
                                            },
                                          )
                                        ),
                                        Text(' '),
                                        Text(' '),
                                        Text(" km")
                                      ],
                                    ),
                                    Container(
                                        // height: 110, //causes a weird error in console for some reason
                                        child: Expanded(
                                            child: VerticalDivider(
                                                color: Colors.grey,
                                                thickness: 1))),
                                    Container(
                                      width: 170,
                                      child: Center(
                                        
                                          child: MultiSelectDialogField(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(10)
                                            ),
                                             
                                            items: governorates.map((e) => MultiSelectItem(e, e)).toList(),
                                            initialValue: queryLocations,
                                            onConfirm: (list){
                                                queryLocations = [];
                                                list.forEach((element) {
                                                  queryLocations.add(element.toString());
                                                });
                                                setState(() {
                                                  
                                                });
                                            },
                                            chipDisplay: MultiSelectChipDisplay(scroll: true, textStyle: TextStyle(color: Colors.white), chipColor: Colors.pinkAccent,),
                                            searchable: true,
                                            title: const Text('Location'),
                                            searchHint: 'Location...',
                                            buttonText: const Text('Location'),
                                          ),
                                          searchable: true,
                                          title: const Text('Location'),
                                          searchHint: 'Location...',
                                          buttonText: const Text('Location'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                        )),
                  ],
                ),
              ));
  }
}
