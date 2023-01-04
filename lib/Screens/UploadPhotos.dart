import 'dart:io';

import 'package:autobid/main.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadPhotos extends StatefulWidget {
  List allPhotos;
  UploadPhotos({required this.allPhotos});

  @override
  State<UploadPhotos> createState() => _UploadPhotosState();
}

class _UploadPhotosState extends State<UploadPhotos> {
  // Create a storage reference from our app
  final storageRef = FirebaseStorage.instance;

  File? _photo;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery() async {
    final pickedFiles = await _picker.pickMultiImage();

    setState(() {
      if (pickedFiles != null) {
        for (XFile pickedFile in pickedFiles) {
          _photo = File(pickedFile.path);
          widget.allPhotos.add(_photo);
        }

        //uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        widget.allPhotos.add(_photo);
        // uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = basename(_photo!.path);
    final destination = 'files/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination).child('file/');
      await ref.putFile(_photo!);
      String url = await ref.getDownloadURL();
      // print(url);
    } catch (e) {
      print('error occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              _showPicker(context);
            },
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: Radius.circular(20),
              dashPattern: [10, 10],
              color: Colors.grey,
              strokeWidth: 2,
              child: widget.allPhotos.length > 0
                  ?
                  // ? ClipRRect(
                  //     borderRadius: BorderRadius.circular(20),
                  //     child: Image.file(
                  //       _photo!,
                  //       width: 350,
                  //       height: 400,
                  //       fit: BoxFit.fitHeight,
                  //     ),
                  //   )
                  Container(
                      padding: EdgeInsets.all(5),
                      height: 400,
                      width: 350,
                      child: SingleChildScrollView(
                          child: Column(children: [
                        Wrap(
                            children: widget.allPhotos!.map((imageone) {
                          return Stack(children: [
                            /// put container first , so the icon will show stacked on top of container
                            Container(
                              child: Card(
                                child: Container(
                                    height: 100,
                                    width: 100,
                                    child: Image.file(imageone)),
                              ),
                            ), // your card
                            Positioned(
                                top: 2,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.remove_circle),
                                  color: Colors.grey[850],
                                  onPressed: () {
                                    setState(() {
                                      widget.allPhotos.remove(imageone);
                                    });
                                  },
                                )),
                          ]);
                        }).toList()),
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Click to add more images.",
                              style: TextStyle(
                                  color: Colors.grey[800], fontSize: 10),
                            ))
                      ])))
                  : Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20)),
                      width: 350,
                      height: 400,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: Colors.grey[800],
                            size: 50,
                          ),
                          Text(
                            "Upload at least one image of the car.",
                            style: TextStyle(
                                color: Colors.grey[800], fontSize: 10),
                          )
                        ],
                      ),
                    ),
            ),
          ),
        )
      ],
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Gallery'),
                      onTap: () {
                        imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
