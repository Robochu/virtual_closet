// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:virtual_closet/clothes.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:virtual_closet/screens/detail.dart';
import 'package:firebase_ml_custom/firebase_ml_custom.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:collection/collection.dart';
//import 'package:tflite/tflite.dart';

class ImageFromGalleryScreen extends StatefulWidget {
  final type;

  const ImageFromGalleryScreen(this.type);

  @override
  ImageFromGalleryScreenState createState() =>
      ImageFromGalleryScreenState(type);
}

class ImageFromGalleryScreenState extends State<ImageFromGalleryScreen> {
  var _image;
  var imagePicker;
  var type;
  var _user;

  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;

  late List<int> _inputShape;
  late List<int> _outputShape;

  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;

  late TfLiteType _inputType;
  late TfLiteType _outputType;

  late List<String> labels;
  final int _labelsLength = 1001;

  final String _labelsFileName = 'assets/dict.txt';

  final String _modelFilePath = 'model-export_icn_tflite-Bingabad_20211104015315-2021-11-14T17_06_32.199644Z_model.tflite';

  NormalizeOp preProcessNormalizeOp = NormalizeOp(0, 1);
  NormalizeOp postProcessNormalizeOp = NormalizeOp(0, 255);

  late var _probabilityProcessor;

  ImageFromGalleryScreenState(this.type);

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);
    _user = user;
    _interpreterOptions = InterpreterOptions();
    _interpreterOptions.threads = 1;
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
      try {
        loadModel();
        loadLabels();
        String prediction = predict();
        print("PREDICTION: " + prediction);
        String category;
        String length;
        String color;
        String itemName;

        if (prediction.contains("hat")) {
          category = "Accessories";
          itemName = "Hat";
          length = "N/A";
          color = prediction.substring(0, prediction.indexOf(' '));
          color = color[0].toUpperCase() + color.substring(1);
        }
        else if (prediction.contains("jacket")) {
          category = "Outerwear";
          itemName = "Jacket";
          length = "Long";
          color = prediction.substring(0, prediction.indexOf(' '));
          color = color[0].toUpperCase() + color.substring(1);
        }
        else if (prediction.contains("pants")) {
          category = "Bottoms";
          itemName = "Pants";
          length = "Long";
          color = prediction.substring(0, prediction.indexOf(' '));
          color = color[0].toUpperCase() + color.substring(1);
        }
        else if (prediction.contains("shoe")) {
          category = "Shoes";
          itemName = "Shoes";
          length = "N/A";
          color = prediction.substring(0, prediction.indexOf(' '));
          color = color[0].toUpperCase() + color.substring(1);
        }
        else if (prediction.contains("shorts")) {
          category = "Bottoms";
          itemName = "Shorts";
          length = "Short";
          color = prediction.substring(0, prediction.indexOf(' '));
          color = color[0].toUpperCase() + color.substring(1);
        }
        else if (prediction.contains("suit")) {
          category = "Tops";
          itemName = "Suit";
          length = "Long";
          color = prediction.substring(0, prediction.indexOf(' '));
          color = color[0].toUpperCase() + color.substring(1);
        }
        else if (prediction.contains("t-shirt")) {
          category = "Tops";
          itemName = "T-shirt";
          length = "Short";
          color = prediction.substring(0, prediction.indexOf(' '));
          color = color[0].toUpperCase() + color.substring(1);
        }
        else {
          category = "Accessories";
          itemName = "Other";
          length = "N/A";
          color = "Multicolor";
        }

        //Clothing item = Clothing.full(user!.uid, _image.path, '', '', 'Tops', 'Short', 'Black', '', 'T-shirt', false, '');
        Clothing item = Clothing.full(user!.uid, _image.path, '', '', category, length, color, '', itemName, false, '', false);
        //Tflite.close();
        close();
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                DetailPage(clothing: item, editable: true)));
      } catch (exception) {
        print("Failed on getting your image and it's labels: $exception");
        print('Continuing with the program...');
        _showMyDialog();
        rethrow;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: <Widget>[
          const SizedBox(
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
                });
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
          const SizedBox(height:60),
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

  //AI code

  Future<void> loadModel() async {
    try {
      print("LOADING\nTHE\nMODEL\n");
      interpreter = await Interpreter.fromAsset(_modelFilePath, options: _interpreterOptions);
      print('Interpreter Created Successfully');

      _inputShape = interpreter.getInputTensor(0).shape;
      _outputShape = interpreter.getOutputTensor(0).shape;
      _inputType = interpreter.getInputTensor(0).type;
      _outputType = interpreter.getOutputTensor(0).type;

      _outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);

      _probabilityProcessor =
          TensorProcessorBuilder().add(postProcessNormalizeOp).build();

    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  Future<void> loadLabels() async {
    labels = await FileUtil.loadLabels(_labelsFileName);
    if (labels.length == _labelsLength) {
      print('Labels loaded successfully');
    } else {
      print('Unable to load labels');
    }
  }

  TensorImage _preProcess() {
    int cropSize = min(_inputImage.height, _inputImage.width);
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(_inputShape[1], _inputShape[2], ResizeMethod.NEAREST_NEIGHBOUR))
        .build()
        .process(_inputImage);
  }

  String predict() {
    _inputImage = TensorImage.fromFile(_image);
    /*_inputImage = TensorImage(_inputType);
    imageImage = Image.file(_image);
    _inputImage.loadImage(Image.file(_image));*/
    _inputImage = _preProcess();
    interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
    Map<String, double> labeledProb = TensorLabel.fromList(
        labels, _probabilityProcessor.process(_outputBuffer))
        .getMapWithFloatValue();
    final pred = getTopProbability(labeledProb);
    return pred.key;
  }

  void close() {
    interpreter.close();
  }

  MapEntry<String, double> getTopProbability(Map<String, double> labeledProb) {
    var pq = PriorityQueue<MapEntry<String, double>>(compare);
    pq.addAll(labeledProb.entries);

    return pq.first;
  }

  int compare(MapEntry<String, double> e1, MapEntry<String, double> e2) {
    if (e1.value > e2.value) {
      return -1;
    } else if (e1.value == e2.value) {
      return 0;
    } else {
      return 1;
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to use this image?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                goToDetails();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void goToDetails() async {
    try {
      loadModel();
      loadLabels();
      String prediction = predict();
      print("PREDICTION: " + prediction);
      String category;
      String length;
      String color;
      String itemName;

      if (prediction.contains("hat")) {
        category = "Accessories";
        itemName = "Hat";
        length = "N/A";
        color = prediction.substring(0, prediction.indexOf(' '));
        color = color[0].toUpperCase() + color.substring(1);
      }
      else if (prediction.contains("jacket")) {
        category = "Outerwear";
        itemName = "Jacket";
        length = "Long";
        color = prediction.substring(0, prediction.indexOf(' '));
        color = color[0].toUpperCase() + color.substring(1);
      }
      else if (prediction.contains("pants")) {
        category = "Bottoms";
        itemName = "Pants";
        length = "Long";
        color = prediction.substring(0, prediction.indexOf(' '));
        color = color[0].toUpperCase() + color.substring(1);
      }
      else if (prediction.contains("shoe")) {
        category = "Shoes";
        itemName = "Shoes";
        length = "N/A";
        color = prediction.substring(0, prediction.indexOf(' '));
        color = color[0].toUpperCase() + color.substring(1);
      }
      else if (prediction.contains("shorts")) {
        category = "Bottoms";
        itemName = "Shorts";
        length = "Short";
        color = prediction.substring(0, prediction.indexOf(' '));
        color = color[0].toUpperCase() + color.substring(1);
      }
      else if (prediction.contains("suit")) {
        category = "Tops";
        itemName = "Suit";
        length = "Long";
        color = prediction.substring(0, prediction.indexOf(' '));
        color = color[0].toUpperCase() + color.substring(1);
      }
      else if (prediction.contains("t-shirt")) {
        category = "Tops";
        itemName = "T-shirt";
        length = "Short";
        color = prediction.substring(0, prediction.indexOf(' '));
        color = color[0].toUpperCase() + color.substring(1);
      }
      else {
        category = "Accessories";
        itemName = "Other";
        length = "N/A";
        color = "Multicolor";
      }
      Clothing item = Clothing.full(_user!.uid, _image.path, '', '', category, length, color, '', itemName, false, '', false);
      //Clothing item = Clothing.full(_user!.uid, _image.path, '', '', 'Tops', 'Short', 'Black', '', 'T-shirt', false, '');
      //Tflite.close();
      close();
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              DetailPage(clothing: item, editable: true)));
    } catch (exception) {
      print("Failed on getting your image and it's labels: $exception");
      print('Continuing with the program...');
      rethrow;
    }
  }





/*
  /// Gets the model ready for inference on images.
  static Future<String> loadModel() async {
    print("LOADING\nTHE\nMODEL");
    final modelFile = await loadModelFromFirebase();
    return loadTFLiteModel(modelFile);
  }

  /// Downloads custom model from the Firebase console and return its file.
  /// located on the mobile device.
  static Future<File> loadModelFromFirebase() async {
    try {
      // Create model with a name that is specified in the Firebase console
      FirebaseCustomRemoteModel model = FirebaseCustomRemoteModel('clothing_recognition');

      // Specify conditions when the model can be downloaded.
      // If there is no wifi access when the app is started,
      // this app will continue loading until the conditions are satisfied.
      FirebaseModelDownloadConditions conditions =
      FirebaseModelDownloadConditions(
          androidRequireWifi: true,
          androidRequireDeviceIdle: true,
          androidRequireCharging: true,
          iosAllowCellularAccess: false,
          iosAllowBackgroundDownloading: true);

      // Create model manager associated with default Firebase App instance.
      FirebaseModelManager modelManager = FirebaseModelManager.instance;

      // Begin downloading and wait until the model is downloaded successfully.
      await modelManager.download(model, conditions);
      assert(await modelManager.isModelDownloaded(model) == true);

      // Get latest model file to use it for inference by the interpreter.
      var modelFile = await modelManager.getLatestModelFile(model);
      assert(modelFile != null);
      return modelFile;
    } catch (exception) {
      print('Failed on loading your model from Firebase: $exception');
      print('The program will not be resumed');
      rethrow;
    }
  }

  /// Loads the model into some TF Lite interpreter.
  /// In this case interpreter provided by tflite plugin.
  static Future<String> loadTFLiteModel(File modelFile) async {
    try {
      await Tflite.loadModel(
        model: "assets/model-export_icn_tflite-Bingabad_20211104015315-2021-11-14T17_06_32.199644Z_model.tflite",
        labels: "assets/dict.txt",
        numThreads: 1, // defaults to 1
        isAsset: true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate: false // defaults to false, set to true to use GPU delegate
        // useGpuDelegate: true,
      );
      return 'Model is loaded';
    } catch (exception) {
      print(
          'Failed on loading your model to the TFLite interpreter: $exception');
      return 'Failed to load model';
    }
  }*/
}
