import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_closet/clothes.dart';
import 'package:virtual_closet/models/user.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

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

  Future updateUserCloset(Clothing item, Future<String?> location) async {
    //DocumentReference closet = closetCollection.doc(uid);
    CollectionReference closet = usersCollection.doc(uid).collection('closet');
    return await closet.doc().set({
      'category': item.category,
      'sleeves': item.sleeves,
      'color': item.color,
      'material': item.materials,
      'imageURL': await location
    });
  }

  Future createClosetSpace(String name) async {
    //return await closetCollection.doc(uid).set({});
    return await usersCollection.doc(uid).collection('closet').doc().set({});
  }

  Stream<List<Clothing>> get closet {
    return usersCollection.doc(uid).collection('closet').snapshots().map(_clothingFromSnapshot);

  }

  List<Clothing> _clothingFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc){
      return Clothing(
        uid,
        doc['imageURL'] ?? '',
        doc['category'] ?? '',
        doc['sleeves'] ?? '',
        doc['color'] ?? '',
        doc['material'] ?? ''
      );
    }).toList();
  }

  Stream<MyUserData> get userData {
    return usersCollection.doc(uid).snapshots().map(_dataFromSnapshot);
  }

  MyUserData _dataFromSnapshot(DocumentSnapshot snapshot) {
    return MyUserData(
        this.uid,
        snapshot['name'],
        usersCollection.doc(uid).collection('closet')
    );
  }
}