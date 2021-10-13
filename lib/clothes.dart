import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Clothing {
  static String uid = "temp";

  String imagePath;
  String category;
  String sleeves;
  String color;
  String materials;

  Clothing(this.imagePath, this.category, this.sleeves, this.color, this.materials);

  static Future<List<Clothing>> download() async {
    List<Clothing> result = <Clothing>[];
    await FirebaseStorage.instance.ref().child('clothes/$uid/').listAll().then((res) async {
      for (var ref in res.items) {
        await ref.getDownloadURL().then((link) async {
          await ref.getMetadata().then((metadata) => {
            result.add(Clothing(
              link,
              metadata.customMetadata!['category']!,
              metadata.customMetadata!['sleeves']!,
              metadata.customMetadata!['color']!,
              metadata.customMetadata!['materials']!,
            ))
          });
        });
      }
    });
    return result;
  }

  Future<void> upload() async {
    File image = File(imagePath);

    // Create your custom metadata.
    SettableMetadata metadata = SettableMetadata(
      customMetadata: <String, String>{
        'category': category,
        'sleeves': sleeves,
        'color': color,
        'materials': materials,
      },
    );

    try {
      // Pass metadata to any file upload method e.g putFile.
      await FirebaseStorage.instance.ref('clothes/$uid/temp').putFile(image, metadata);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print('If this ever gets printed, complain to Oleg.');
    }
  }
}
