import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
      'uid': uid,
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
      'fileName' : item.filename,
      'item': item.item,
      'inLaundryFor': item.inLaundryFor
    }, SetOptions(merge: true));
  }

  Future updateOutfit(String name, List<Clothing> outfit) async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    CollectionReference outfits = usersCollection.doc(uid).collection('outfits');
    return await outfits.doc(name).set({
      'name': name,
      'clothes': outfit,
    }, SetOptions(merge: true));
  }

  Future updateLaundryDetail(Clothing item, DateTime date) async {
    DateFormat dateFormat = DateFormat.yMd();
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    CollectionReference closet = usersCollection.doc(uid).collection('closet');
    return await closet.doc(item.filename).set({
      'inLaundryFor': dateFormat.format(date)
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
                doc['item'] ?? '',
                doc['isLaundry'] ?? '',
                doc['inLaundryFor'] ?? '')).toList());
  }

  Stream<List<Clothing>> getFilteredItem(String itemType) {
    itemType = "T-shirt"; //for testing
    return FirebaseFirestore.instance.collection('users')
        .doc(uid)
        .collection('closet')
        .where("item", isEqualTo: itemType).snapshots()
        .map((event) => event.docs.map(
            (doc) => Clothing.usingLink(
            uid,
            doc['fileName'] ?? '',
            doc['imageURL'] ?? '',
            doc['category'] ?? '',
            doc['sleeves'] ?? '',
            doc['color'] ?? '',
            doc['material'] ?? '',
            doc['item'] ?? '',
            doc['isLaundry'] ?? '',
            doc['inLaundryFor'] ?? '')).toList());
  }

  Future<MyUserData> get userData {
    return firestoreDb.collection('users').doc(uid).get().then(_dataFromSnapshot);
  }

  MyUserData _dataFromSnapshot(DocumentSnapshot snapshot) {
    if(!snapshot.exists) {
      return MyUserData(
          uid: uid, email: '', name: '', lastName: '', dob: '');
    }
    return MyUserData(
        uid: uid,
        email: snapshot['email'],
        name: snapshot['name'] ?? '',
        lastName: snapshot['lastName'] ?? '',
        dob: snapshot['dob'] ?? '',
    );
  }
}