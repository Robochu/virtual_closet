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
//import 'package:tflite_flutter/tflite_flutter.dart';
//import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:tflite/tflite.dart';

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

  /*late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;

  late List<int> _inputShape;
  late List<int> _outputShape;

  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;

  late TfLiteType _inputType;
  late TfLiteType _outputType;*/

  final String _labelsFileName = 'assets/labels.txt';

  final String _modelFilePath = 'assets/model-export_icn_tflite-Bingabad_20211104015315-2021-11-14T17_06_32.199644Z_model.tflite';

  ImageFromGalleryScreenState(this.type);

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);
    //_interpreterOptions = InterpreterOptions();
    loadModel();
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
        //predict();
        //print(_outputBuffer);
        var recognitions = Tflite.runModelOnImage(path: _image.path);
        print(recognitions);
        Clothing item = Clothing.full(user!.uid, _image.path, '', '', 'Tops', 'Short', 'Black', '', 'T-shirt', false, '');
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

  //AI code

  /*Future<void> loadModel() async {
    try {
      interpreter =
      await Interpreter.fromAsset(_modelFilePath, options: _interpreterOptions);
      print('Interpreter Created Successfully');

      _inputShape = interpreter.getInputTensor(0).shape;
      _outputShape = interpreter.getOutputTensor(0).shape;
      _inputType = interpreter.getInputTensor(0).type;
      _outputType = interpreter.getOutputTensor(0).type;

      //_outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  TensorImage _preProcess() {
    int cropSize = min(_inputImage.height, _inputImage.width);
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(
        _inputShape[1], _inputShape[2], ResizeMethod.NEAREST_NEIGHBOUR))
        .build()
        .process(_inputImage);
  }

  void predict() {
    _inputImage = TensorImage(_inputType);
    _inputImage.loadImage(_image);
    _inputImage = _preProcess();
    interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
  }

  void close() {
    interpreter.close();
  }*/





  /// Gets the model ready for inference on images.
  static Future<String> loadModel() async {
    Tflite.close();
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
        labels: "assets/labels.txt",
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
  }
}
