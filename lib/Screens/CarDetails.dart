import 'dart:convert';

import 'package:autobid/Lists/governorates.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../Lists/brands.dart';

class CarDetails extends StatefulWidget {
  GlobalKey formKey;
  Map<String, Object> brandDateLocation;
  // TextEditingController modelController;
  TextEditingController yearController;
  TextEditingController descriptionController;
  TextEditingController mileageController;
  TextEditingController priceController;
  CarDetails(
      {required this.formKey,
      required this.brandDateLocation,
      // required this.modelController,
      required this.yearController,
      required this.descriptionController,
      required this.mileageController,
      required this.priceController});

  @override
  State<CarDetails> createState() => CarDetailsState();
}

class CarDetailsState extends State<CarDetails> {
  List<String> listOfBrands = [];
  List<String> listOfModels = [];
  late Map<String, dynamic> brandModelInfo;

  Future<void> getBrandModelInfo() async {
    final data = await rootBundle.loadString('assets/brandModelInfo.json');

    brandModelInfo = await json.decode(data);

    setState(() {
      listOfBrands = brandModelInfo.keys.toSet().toList();
      listOfBrands.sort();
      if (widget.brandDateLocation["model"] != "") {
        updateModelList(widget.brandDateLocation["brand"].toString());
      }
    });
  }

  void updateModelList(String brand) {
    List<dynamic> modelList = [];
    listOfModels = [];

    modelList = brandModelInfo[brand];

    modelList.forEach((element) {
      listOfModels.add(getPureModelName(element['Name'], brand));
    });

    listOfModels = listOfModels.toSet().toList();
  }

  int secondIndexOf(String strToRemoveFrom,String stringToFind) {
    if (strToRemoveFrom.indexOf(stringToFind) == -1) return -1;
    return strToRemoveFrom.indexOf(stringToFind, strToRemoveFrom.indexOf(stringToFind) + 1);
  }

  String getPureModelName(String modelName, String brand) {
    if(modelName.contains('Alfa Romeo') || modelName.contains("Aston Martin") || modelName.contains("Great Wall")
        || modelName.contains("Land Rover") || modelName.contains("Magna Steyr")){
          return modelName.substring(secondIndexOf(modelName,' ')+1);
        }
    if (modelName.contains(' ')) {
      if (brand == (modelName.substring(0, modelName.indexOf(' ')))) {
        return modelName.substring(modelName.indexOf(' ') + 1);
      }
    }
    return modelName;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBrandModelInfo();

    //updateModelList(listOfBrands);
  }

  @override
  Widget build(BuildContext context) {
    var date = widget.brandDateLocation["date"] == ""
        ? ""
        : DateFormat("dd-MM-yyyy")
            .format(widget.brandDateLocation["date"] as DateTime);
    TextEditingController dateController =
        new TextEditingController(text: date);

    return Form(
        key: widget.formKey,
        child: Column(
          children: [
            DropdownButtonFormField(
              isExpanded: true,

              value: widget.brandDateLocation["brand"] == ""
                  ? null
                  : widget.brandDateLocation["brand"].toString(),
              decoration: InputDecoration(
                // enabledBorder: const OutlineInputBorder(
                //   //<-- SEE HERE
                //   borderSide: BorderSide(color: Colors.pink, width: 2),
                // ),
                // focusedBorder: const OutlineInputBorder(
                //   //<-- SEE HERE
                //   borderSide: BorderSide(color: Colors.pink, width: 2),
                // ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink, width: 2),
                ),
                label: Text("Brand"),
                // filled: true,
                // fillColor: Colors.grey.shade200,
              ),
              // hint: const Text("Select Brand"),
              validator: (value) =>
                  value == null ? "Select a car brand." : null,
              dropdownColor: Colors.grey.shade200,
              onChanged: (String? newValue) {
                setState(() {
                  widget.brandDateLocation["brand"] = newValue!;
                  updateModelList(newValue);
                });
              },
              items: listOfBrands.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              }).toList(),
            ),
            // TextFormField(
            //   controller: widget.modelController,
            //   validator: (value) {
            //     return value == "" ? "Specify the car model." : null;
            //   },
            //   decoration: const InputDecoration(
            //     labelText: 'Model',
            //   ),
            // ),
            DropdownButtonFormField(
              isExpanded: true,
              value: widget.brandDateLocation["model"] == "" ||
                      !listOfModels.contains(widget.brandDateLocation["model"])
                  ? null
                  : widget.brandDateLocation["model"].toString(),
              decoration: InputDecoration(
                // enabledBorder: const OutlineInputBorder(
                //   //<-- SEE HERE
                //   borderSide: BorderSide(color: Colors.pink, width: 2),
                // ),
                // focusedBorder: const OutlineInputBorder(
                //   //<-- SEE HERE
                //   borderSide: BorderSide(color: Colors.pink, width: 2),
                // ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink, width: 2),
                ),
                label: Text("Model"),
                //filled: true,
                //   fillColor: Colors.grey.shade200,
              ),
              // hint: const Text("Select Model"),
              validator: (value) =>
                  value == null ? "Select a car model." : null,
              dropdownColor: Colors.grey.shade200,
              onChanged: (String? newValue) {
                setState(() {
                  widget.brandDateLocation["model"] = newValue!;
                });
              },
              items: listOfModels.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              }).toList(),
            ),
            TextFormField(
              controller: widget.yearController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              validator: (value) {
                return value == ""
                    ? "Specify the manufacturing year."
                    : int.parse(value!) > DateTime.now().year
                        ? "Enter a valid year."
                        : null;
              },
              decoration: const InputDecoration(
                labelText: 'Year',
              ),
            ),
            TextFormField(
              controller: widget.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
            TextFormField(
              controller: widget.mileageController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              validator: (value) => value == "" ? "Specify the mileage." : null,
              decoration: const InputDecoration(
                labelText: 'Mileage in KM',
              ),
            ),
            TextFormField(
              controller: widget.priceController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              validator: (value) =>
                  value == "" ? "Specify the starting selling price." : null,
              decoration: const InputDecoration(
                labelText: 'Starting Price',
              ),
            ),
            TextFormField(
                controller: dateController,
                decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today), //icon of text field
                    labelText: "Bidding Deadline" //label text of field
                    ),
                readOnly: true, // when true user cannot edit text
                validator: (value) =>
                    value == "" ? "Specify the final date for bidding." : null,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(), //get today's date
                      firstDate: DateTime
                          .now(), //DateTime.now() - not to allow to choose before today.
                      lastDate: DateTime(2101));
                  if (pickedDate != null) {
                    String formattedDate =
                        DateFormat('dd-MM-yyyy').format(pickedDate);
                    setState(() {
                      dateController.text = formattedDate;

                      widget.brandDateLocation["date"] = pickedDate;
                    });
                  }
                }),
            DropdownButtonFormField(
              isExpanded: true,

              value: widget.brandDateLocation["location"] == ""
                  ? null
                  : widget.brandDateLocation["location"].toString(),
              decoration: InputDecoration(
                  // enabledBorder: const OutlineInputBorder(
                  //   //<-- SEE HERE
                  //   borderSide: BorderSide(color: Colors.pink, width: 2),
                  // ),
                  // focusedBorder: const OutlineInputBorder(
                  //   //<-- SEE HERE
                  //   borderSide: BorderSide(color: Colors.pink, width: 2),
                  // ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink, width: 2),
                  ),
                  label: Text("Location")
                  // filled: true,
                  // fillColor: Colors.grey.shade200,
                  ),
              //  hint: const Text("Select Location"),
              validator: (value) =>
                  value == null ? "Select your location." : null,
              dropdownColor: Colors.grey.shade200,
              onChanged: (String? newValue) {
                setState(() {
                  widget.brandDateLocation["location"] = newValue!;
                });
              },
              items: governorates.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              }).toList(),
            ),
          ],
        ));
  }
}
