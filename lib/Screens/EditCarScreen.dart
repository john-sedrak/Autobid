import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:uri_to_file/uri_to_file.dart';

import 'package:path/path.dart';

import '../Classes/Car.dart';
import 'AuthenticationScreens/errorMessage.dart';
import 'CarDetails.dart';
import 'UploadPhotos.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  final carsRef = FirebaseFirestore.instance.collection('Cars');
  int _currentStep = 0;
  final detailsKey = GlobalKey<FormState>();

  _stepState(int step) {
    if (_currentStep > step) {
      return StepState.complete;
    } else {
      return StepState.editing;
    }
  }

  // TextEditingController modelController = new TextEditingController();
  TextEditingController yearController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController mileageController = new TextEditingController();
  TextEditingController priceController = new TextEditingController();
  List downloadUrls = [];
  List allPictures = [];
  Map<String, Object> brandDateLocation = {
    "brand": "",
    "model": "",
    "date": DateTime.now(),
    "location": ""
  };

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Car;
    if (yearController.text == "") {
      //modelController.text = args.model;
      yearController.text = args.year.toString();
      descriptionController.text = args.sellerDescription;
      mileageController.text = args.mileage.toString();
      priceController.text = args.startingPrice.toString();
      downloadUrls = args.carImagePaths;
      brandDateLocation["brand"] = args.brand;
      brandDateLocation["model"] = args.model;
      brandDateLocation["date"] = args.validUntil;
      brandDateLocation["location"] = args.location;
    }

    _steps() => [
          Step(
            title: Text('Details'),
            content: CarDetails(
              formKey: detailsKey,
              brandDateLocation: brandDateLocation,
              // modelController: modelController,
              yearController: yearController,
              descriptionController: descriptionController,
              mileageController: mileageController,
              priceController: priceController,
            ),
            state: _stepState(0),
            isActive: _currentStep == 0,
          ),
          Step(
            title: Text('Photos'),
            content: UploadPhotos(
              allPhotos: allPictures,
              downloadUrls: downloadUrls,
            ),
            state: _stepState(1),
            isActive: _currentStep == 1,
          ),
        ];

    Future<void> uploadFiles() async {
      await Future.wait(allPictures.map((photo) async {
        if (photo == null) return "";
        final fileName = basename(photo!.path);
        final destination = 'files/$fileName';

        try {
          final ref = FirebaseStorage.instance.ref(destination).child('file/');
          await ref.putFile(photo!);
          String url = await ref.getDownloadURL();
          downloadUrls.add(url);
          return url;
        } catch (e) {
          print('error occured');
        }
      }));
    }

    postCar() async {
      final User? user = await auth.currentUser;
      carsRef.doc(args.id).update({
        'brand': brandDateLocation["brand"],
        'model': brandDateLocation["model"],
        'year': yearController.text,
        'description': descriptionController.text,
        'mileage': mileageController.text,
        'startingPrice': priceController.text,
        'images': downloadUrls,
        'validUntil': brandDateLocation["date"],
        'location': brandDateLocation["location"],
        'sellerID': user!.uid,
        'bidderID': args.bidderID,
        'currentBid': args.currentBid
      });
    }

    deleteListing() async {
      carsRef.doc(args.id).delete();
    }

    void showErrorMessage(String msg) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.grey.shade300,
        elevation: 0,
        content: errorMessage(
          message: msg,
        ),
        behavior: SnackBarBehavior.floating,
      ));
    }

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          title: const Text(
            'Edit Car Details',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.pink,
        ),
        body: SafeArea(
            child: Theme(
          data: ThemeData(
            canvasColor: Colors.white,
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.pink,
                  background: Colors.white,
                  secondary: Colors.pink,
                ),
          ),
          child: Stepper(
            controlsBuilder: (BuildContext context, ControlsDetails controls) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: _currentStep != 0
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.end,
                    children: <Widget>[
                      if (_currentStep != 0)
                        OutlinedButton(
                          style: ButtonStyle(
                              side: MaterialStateProperty.all(
                                  BorderSide(color: Colors.pink))),
                          onPressed: controls.onStepCancel,
                          child: const Text(
                            'BACK',
                            style: TextStyle(color: Colors.pink),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: controls.onStepContinue,
                        child: Text(
                          _currentStep == 0 ? 'NEXT' : 'UPDATE',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: OutlinedButton(
                          style: ButtonStyle(
                              side: MaterialStateProperty.all(
                                  BorderSide(color: Colors.red.shade900))),
                          onPressed: () async {
                            await deleteListing();

                            Navigator.popUntil(
                              context,
                              ModalRoute.withName('/'),
                            );
                          },
                          child: const Text(
                            'DELETE LISTING',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      )
                    ],
                  )
                ]),
              );
            },
            type: StepperType.horizontal,
            onStepTapped: (step) => setState(() => _currentStep = step),
            onStepContinue: () async {
              if (_currentStep == 0 && detailsKey.currentState!.validate()) {
                setState(() {
                  if (_currentStep < _steps().length - 1) {
                    _currentStep += 1;
                  } else {
                    _currentStep = 0;
                  }
                });
              } else if (_currentStep == 1 && (downloadUrls.length > 0) ||
                  allPictures.length > 0) {
                await uploadFiles();
                await postCar();
                Navigator.of(context).pop();
              } else if (_currentStep == 1 &&
                  (!(downloadUrls.length > 0) || !(allPictures.length > 0))) {
                showErrorMessage("Add at least one image of the car.");
              }
            },
            onStepCancel: () {
              setState(() {
                if (_currentStep > 0) {
                  _currentStep -= 1;
                } else {
                  _currentStep = 0;
                }
              });
            },
            currentStep: _currentStep,
            steps: _steps(),
          ),
        )));
  }
}
