import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtual_closet/service/database.dart';

class Clothing {
  String? uid;
  String? path;
  String? filename;
  String? link;
  String category;
  String sleeves;
  String color;
  String materials;

  Clothing(this.uid, this.path, this.category, this.sleeves, this.color, this.materials);

  Clothing.usingLink(this.uid, this.link, this.category, this.sleeves, this.color, this.materials);

  Future<void> upload() async {
    File image = File(path!);

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
      filename = basename(path!);
      UploadTask task = FirebaseStorage.instance.ref('clothes/$uid/$filename').putFile(image, metadata);
      (await task).ref.getDownloadURL().then((link) async => {
        await DatabaseService(uid: uid).updateUserCloset(this, link)
      });
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print('If this ever gets printed, complain to Oleg.');
    }
  }
}
