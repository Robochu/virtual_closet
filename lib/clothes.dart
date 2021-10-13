import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtual_closet/service/database.dart';

class Clothing {
  String? uid;
  String imagePath;
  String category;
  String sleeves;
  String color;
  String materials;

  Clothing(this.uid, this.imagePath, this.category, this.sleeves, this.color, this.materials);
/*
  Future<List<Clothing>> download() async {
    List<Clothing> result = <Clothing>[];
    await FirebaseStorage.instance.ref().child('clothes/$uid/').listAll().then((res) async {
      for (var ref in res.items) {
        await ref.getDownloadURL().then((link) async {
          await ref.getMetadata().then((metadata) => {
            result.add(Clothing(uid,
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
  }*/

  Future<String?> upload() async {
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
      UploadTask task = FirebaseStorage.instance.ref('clothes/$uid/').putFile(image, metadata);
      return (await task).ref.getDownloadURL();
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print('If this ever gets printed, complain to Oleg.');
    }

  }
}

class ClothingToStorage {

}
