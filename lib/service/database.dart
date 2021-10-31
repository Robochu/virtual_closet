import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_closet/clothes.dart';
import 'package:virtual_closet/models/user.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  Future updateUserData(String name, String email) async{
    return await usersCollection.doc(uid).set({
      'name' : name,
      'email': email,
      'uid': this.uid
    });

  }

  Future updateUserCloset(Clothing item, String location) async {
    CollectionReference closet = usersCollection.doc(uid).collection('closet');
    return await closet.doc(item.filename).set({
      'category': item.category,
      'sleeves': item.sleeves,
      'color': item.color,
      'material': item.materials,
      'isLaundry': item.isLaundry,
      'imageURL': location,
      'fileName' : item.filename
    }, SetOptions(merge: true));
  }

  Future deleteItemFromCloset(Clothing item) async {
    return await usersCollection.doc(uid).collection('closet').doc(item.filename).delete();
  }

  Future createClosetSpace(String name) async {
    return await usersCollection.doc(uid).collection('closet').doc().set({});
  }

  Stream<List<Clothing>> get closet {
    return usersCollection
        .doc(uid)
        .collection('closet')
        .snapshots()
        .map((event) => event.docs.map(
            (doc) => Clothing.usingLink(
                uid,
                doc['fileName'] ?? '',
                doc['imageURL'] ?? '',
                doc['category'] ?? '',
                doc['sleeves'] ?? '',
                doc['color'] ?? '',
                doc['material'] ?? '',
                doc['isLaundry'] ?? '')).toList());
  }

  Stream<MyUserData> get userData {
    return usersCollection.doc(uid).snapshots().map(_dataFromSnapshot);
  }

  MyUserData _dataFromSnapshot(DocumentSnapshot snapshot) {
    return MyUserData(
        uid: this.uid,
        name: snapshot['name'] ?? '',
        lastName: snapshot['lastName'] ?? '',
        dob: snapshot['dob'] ?? DateTime.now(),
    );
  }
}