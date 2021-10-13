import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String uid;
  MyUser(this.uid);
}

class MyUserData {
  final String? uid;
  final String name;
  final CollectionReference userCloset;

  MyUserData(this.uid, this.name, this.userCloset);
}