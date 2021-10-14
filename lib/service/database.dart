import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_closet/clothes.dart';
import 'package:virtual_closet/models/user.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  //final CollectionReference closetCollection = FirebaseFirestore.instance.collection('closets');
  Future updateUserData(String name, String email) async{
    createClosetSpace(name);
    return await usersCollection.doc(uid).set({
      'name' : name,
      'email': email,
      'uid': this.uid
    });

  }

  Future updateUserCloset(Clothing item) async {
    //DocumentReference closet = closetCollection.doc(uid);
    CollectionReference closet = usersCollection.doc(uid).collection('closet');
    return await closet.doc().set({
      'category': item.category,
      'sleeves': item.sleeves,
      'color': item.color,
      'material': item.materials,
      'imageURL': item.link,
    });
  }

  Future createClosetSpace(String name) async {
    //return await closetCollection.doc(uid).set({});
    return await usersCollection.doc(uid).collection('closet').doc().set({});
  }
/*
  Stream<List<Clothing>> get closet {
    return usersCollection.doc(uid).collection('closet').snapshots().map(_clothingFromSnapshot);

  }*/

  Stream<List<Clothing>> get closet {
    return usersCollection
        .doc(uid)
        .collection('closet')
        .snapshots()
        .map((event) => event.docs.map(
            (doc) => Clothing(
              uid,
                doc['imageURL'] ?? '',
                doc['category'] ?? '',
                doc['sleeves'] ?? '',
                doc['color'] ?? '',
                doc['material'] ?? '')).toList());
  }

  Future getCloset() {
    return FirebaseFirestore.instance
        .collectionGroup('closet')
        .where('uid', isEqualTo: uid)
        .get();
  }
/*
  void userSnapshot() {
    final Query closet = FirebaseFirestore.instance.collectionGroup('closet').where('uid', isEqualTo: uid);
    final Future<QuerySnapshot> querySnapshot = closet.get();
    final List<Clothing> clothes = _clothingFromSnapshot(querySnapshot);
  }

  List<Clothing> _clothingFromSnapshot(Future<QuerySnapshot> snapshot) {
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
  }*/

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