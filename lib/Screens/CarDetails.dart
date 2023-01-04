import 'package:autobid/Lists/governorates.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../Lists/brands.dart';

class CarDetails extends StatefulWidget {
  GlobalKey formKey;
  Map<String, Object> brandDateLocation;
  TextEditingController modelController;
  TextEditingController yearController;
  TextEditingController descriptionController;
  TextEditingController mileageController;
  TextEditingController priceController;
  CarDetails(
      {required this.formKey,
      required this.brandDateLocation,
      required this.modelController,
      required this.yearController,
      required this.descriptionController,
      required this.mileageController,
      required this.priceController});

  @override
  State<CarDetails> createState() => CarDetailsState();
}

class CarDetailsState extends State<CarDetails> {
  TextEditingController dateController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: widget.formKey,
        child: Column(
          children: [
            DropdownButtonFormField(
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  //<-- SEE HERE
                  borderSide: BorderSide(color: Colors.pink, width: 2),
                ),
                focusedBorder: const OutlineInputBorder(
                  //<-- SEE HERE
                  borderSide: BorderSide(color: Colors.pink, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
              hint: const Text("Select Brand"),
              validator: (value) =>
                  value == null ? "Select a car brand." : null,
              dropdownColor: Colors.grey.shade200,
              onChanged: (String? newValue) {
                setState(() {
                  widget.brandDateLocation["brand"] = newValue!;
                });
              },
              items: brands.map<DropdownMenuItem<String>>((String value) {
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
              controller: widget.modelController,
              validator: (value) {
                return value == "" ? "Specify the car model." : null;
              },
              decoration: const InputDecoration(
                labelText: 'Model',
              ),
            ),
            TextFormField(
              controller: widget.yearController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              validator: (value) {
                return value == "" ? "Specify the manufacturing year." : null;
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
                  } else {
                    print("Date is not selected");
                  }
                }),
            DropdownButtonFormField(
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  //<-- SEE HERE
                  borderSide: BorderSide(color: Colors.pink, width: 2),
                ),
                focusedBorder: const OutlineInputBorder(
                  //<-- SEE HERE
                  borderSide: BorderSide(color: Colors.pink, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
              hint: const Text("Select Location"),
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
