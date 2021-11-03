import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_closet/clothes.dart';
import 'package:virtual_closet/models/user.dart';

class DatabaseService {
  final String? uid;
  final FirebaseFirestore firestoreDb;
  DatabaseService({this.uid, FirebaseFirestore? firestoreDb})
      : firestoreDb = firestoreDb ?? FirebaseFirestore.instance;

  //final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  Future updateUserData(MyUserData user) async{
    return await firestoreDb.collection('users').doc(uid).set({
      'name' : user.name,
      'email': user.email,
      'uid': this.uid,
      'lastName': user.lastName,
      'dob': user.dob,
    });

  }

  Future updateUserCloset(Clothing item, String location) async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
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
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    return await usersCollection.doc(uid).collection('closet').doc(item.filename).delete();
  }

  Future createClosetSpace(String name) async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    return await usersCollection.doc(uid).collection('closet').doc().set({});
  }

  Stream<List<Clothing>> get closet {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
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

  Future<MyUserData> get userData {
    return firestoreDb.collection('users').doc(uid).get().then(_dataFromSnapshot);
  }

  MyUserData _dataFromSnapshot(DocumentSnapshot snapshot) {
    if(!snapshot.exists) {
      return MyUserData(
          uid: this.uid, email: '', name: '', lastName: '', dob: '');
    }
    return MyUserData(
        uid: this.uid,
        email: snapshot['email'],
        name: snapshot['name'] ?? '',
        lastName: snapshot['lastName'] ?? '',
        dob: snapshot['dob'] ?? '',
    );
  }
}