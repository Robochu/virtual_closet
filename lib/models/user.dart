import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String uid;
  MyUser(this.uid);
}

class MyUserData {
  final String? uid;
  String name;
  String? lastName;
  DateTime dob;
  MyUserData({this.uid, required this.name, this.lastName, required this.dob});
}