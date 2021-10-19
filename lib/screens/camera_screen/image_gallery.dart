// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:virtual_closet/clothes.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:virtual_closet/screens/closet/detail.dart';

class ImageFromGalleryScreen extends StatefulWidget {
  final type;

  ImageFromGalleryScreen(this.type);

  @override
  ImageFromGalleryScreenState createState() =>
      ImageFromGalleryScreenState(this.type);
}

class ImageFromGalleryScreenState extends State<ImageFromGalleryScreen> {
  var _image;
  var imagePicker;
  var type;

  ImageFromGalleryScreenState(this.type);

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);
    var title;
    var source;
    if (type == 'camera') {
      title = "Image from Camera";
      source = ImageSource.camera;
    } else {
      title = "Image from Gallery";
      source = ImageSource.gallery;
    }
    void up() async {

      Clothing item = Clothing.full(user!.uid, _image.path, '', '', '', '', '', '', false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
          DetailPage(clothing: item)));

      //await item.upload();
      //Navigator.pop(context);
      print('\n\n\n\n');
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 52,
          ),
          Center(
            child: GestureDetector(
              onTap: () async {
                XFile image = await imagePicker.pickImage(
                    source: source,
                    imageQuality: 50,
                    preferredCameraDevice: CameraDevice.front);
                setState(() {
                  _image = File(image.path);
                }); //TODO: handle Null Exception - user may click return without taking photo
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(color: Colors.red[200]),
                child: _image != null
                    ? Image.file(
                        _image,
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.fitHeight,
                      )
                    : Container(
                        decoration: BoxDecoration(color: Colors.red[200]),
                        width: 200,
                        height: 200,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(height:60),
          ElevatedButton(
            // onPress: null = disabled button
            onPressed:  (_image == null) ? null : () => up(),

            child: const Text('Continue to details'),
           style: ElevatedButton.styleFrom(
             primary: Colors.blue,
           ),
          )

        ],
      ),
    );
  }


}
