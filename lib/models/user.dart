import 'package:cloud_firestore/cloud_firestore.dart';


class MyUser {
  final String uid;
  MyUser(this.uid);

   @override
  bool operator ==(Object other) =>
    identical(this, other) ||
     other is MyUser &&
     uid == other.uid;
  @override
  int get hashCode => uid.hashCode ;
}

class MyUserData {
  final String? uid;
  String email;
  String name;
  String lastName;
  String dob;
  MyUserData({this.uid,required this.email, required this.name, required this.lastName, required this.dob});
}