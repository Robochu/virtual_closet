import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService(this.uid);

  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference closetCollection = FirebaseFirestore.instance.collection('closets');
  Future updateUserData(String name, String email) async{
    createClosetSpace(name);
    return await usersCollection.doc(uid).set({
      'name' : name,
      'email': email,
      'uid': this.uid
    });

  }

  Future createClosetSpace(String name) async {
    return await closetCollection.doc(uid).set({
      'owner': name,
    });
  }
}