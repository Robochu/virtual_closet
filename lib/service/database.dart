import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:virtual_closet/clothes.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:virtual_closet/screens/combinations/outfit.dart';

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
      'inLaundryFor': item.inLaundryFor,
      'isFavorite': item.isFavorite,
    }, SetOptions(merge: true));
  }

  Future updateOutfit(String name, List<Clothing> outfit, String id) async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    CollectionReference outfits = usersCollection.doc(uid).collection('outfits');
    List<String?> items = <String>[];
    for(var item in outfit) {
      items.add(item.filename);
      //print(items.last.path);
    }
    if(id == '') {
      id = Clothing.random.nextInt(4294967296).toString();
    }
    return await outfits.doc(id).set({
      'name': name,
      'clothes': items,
      'id': id
    }, SetOptions(merge: true));
  }
  Future updateFavorite(Clothing item)  async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    CollectionReference closet = usersCollection.doc(uid).collection('closet');
    return await closet.doc(item.filename).set({
      'isFavorite': item.isFavorite,
    }, SetOptions(merge: true));
  }

  Future updateLaundryDetail(Clothing item, DateTime date) async {
    DateFormat dateFormat = DateFormat.yMd();
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    CollectionReference closet = usersCollection.doc(uid).collection('closet');
    return await closet.doc(item.filename).set({
      'inLaundryFor': dateFormat.format(date),
    }, SetOptions(merge: true));
  }

  Future deleteItemFromCloset(Clothing item) async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    return await usersCollection.doc(uid).collection('closet').doc(item.filename).delete();
  }
  Future deleteOutfit(Outfit outfit) async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    return await usersCollection.doc(uid).collection('outfits').doc(outfit.id).delete();

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
                doc['isLaundry'] ?? false,
                doc['inLaundryFor'] ?? '',
                doc['isFavorite'] ?? false)).toList());
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
            doc['isLaundry'] ?? false,
            doc['inLaundryFor'] ?? '',
            doc['isFavorite'] ?? false)).toList());
  }

  Stream<List<Outfit>> get outfits {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    return usersCollection
        .doc(uid)
        .collection('outfits')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(
        (doc) {
          List<String> item_refs = List.from(doc['clothes']);
          List<Clothing> items = <Clothing>[];

          for(var ref in item_refs)  {
            usersCollection.doc(uid).collection('closet').doc(ref).get().then((snapshot) {
              if(!snapshot.exists) {
                item_refs.remove(ref);
                FirebaseFirestore.instance.collection('users')
                    .doc(uid).collection('outfits').doc(doc.id).set({
                  'clothes': item_refs,
                }, SetOptions(merge: true));

              } else {
                items.add(Clothing.usingLink(
                    uid,
                    snapshot['fileName'] ?? '',
                    snapshot['imageURL'] ?? '',
                    snapshot['category'] ?? '',
                    snapshot['sleeves'] ?? '',
                    snapshot['color'] ?? '',
                    snapshot['material'] ?? '',
                    snapshot['item'] ?? '',
                    snapshot['isLaundry'] ?? '',
                    snapshot['inLaundryFor'] ?? '',
                    snapshot['isFavorite'] ?? false));}});

          }

          return Outfit(doc['name'] ?? '', items, doc['id'], ref: item_refs);
        }).toList()
    );
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