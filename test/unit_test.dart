import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:virtual_closet/service/database.dart';
import 'package:virtual_closet/service/fire_auth.dart';
import 'mock.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';


final tUser = MockUser(
  isAnonymous: false,
  uid: 'T3STU1D',
  email: 'testing.unit@gmail.com',
  displayName: 'UnitTest',

);
final tUserData = MyUserData(lastName: 'Test',
  name: 'Unit',
  email: 'testing.unit@gmail.com',
  dob: '11/03/2021',
  uid: 'T3STU1D'
);


void main() {
  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('Authentication test', () {
    final MyUser expectUser = MyUser(tUser.uid);

    test('signInWithEmailPassword returns a MyUser user', () async {
      final firebaseAuth = MockFirebaseAuth(signedIn:false, mockUser: tUser);
      final _myAuth = Authentication(auth: firebaseAuth);
      MyUser? myUser = await _myAuth.signInWithEmailPassword(
          email: 'testing.unit@gmail.com', password: 'unit123test456');
      expect(myUser, expectUser);
      expect(myUser!.uid, expectUser.uid);
    });
    test('signInWithEmailPassword with incorrect email and password', () async {
      final firebaseAuth = MockFirebaseAuth();
      final _myAuth = Authentication(auth: firebaseAuth);
      MyUser? myUser = await _myAuth.signInWithEmailPassword(
          email: 'testing.unit1@gmail.com', password: '456test123unit');
      expect(myUser!.uid, isNot(expectUser.uid));
    });

    test('sign out', ()async {
      final _auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
      final _myAuth1 = Authentication(auth: _auth);
      await _myAuth1.signOut();
      expect(_auth.currentUser, isNull);
    });
  });

  group('Database service test', () {
    setUp(() async {
      await Firebase.initializeApp();
    });
    final instance = FakeFirebaseFirestore();
    DatabaseService databaseService = DatabaseService(uid: tUser.uid, firestoreDb: instance);

    test('updateUserData create the user`s doc in the database', () async {
      databaseService.updateUserData(tUserData);
      final collectionRef = await instance.collection('users').get();
      final docRef = await instance.collection('users').doc(tUser.uid).get();
      expect(collectionRef.size, 1);
      expect(docRef.exists, true);
      expect(docRef['name'], tUserData.name);
      expect(docRef['lastName'], tUserData.lastName);
      expect(docRef['email'], tUserData.email);
      expect(docRef['dob'], '11/03/2021');

    });
    test('updateUserData update the user`s doc in the database', () async {
      databaseService.updateUserData(MyUserData(
          email: tUserData.email, name: tUserData.name, lastName: 'Test2' , dob: '11/05/2021'));
      final collectionRef = await instance.collection('users').get();
      final docRef = await instance.collection('users').doc(tUser.uid).get();

      //should not make a new document
      expect(collectionRef.size, 1);
      expect(docRef.exists, true);
      expect(docRef['name'], tUserData.name);
      expect(docRef['lastName'], 'Test2');
      expect(docRef['lastName'], isNot(tUserData.lastName));
      expect(docRef['email'], tUserData.email);
      expect(docRef['dob'], '11/05/2021');
      expect(docRef['dob'], isNot('11/03/2021'));
    });

    test('updateUserData will only update one document', () async {
      //put some data in the database
      instance.collection('users').doc(tUser.uid).set({
        'name': 'Test1',
        'lastName': 'TestTest',
        'dob': '12/30/1999',
        'email': 'testtest@gmail.com'
      });
      instance.collection('users').doc('some-random-uid').set({
        'name': 'Test2',
        'lastName': 'Test123',
        'dob': '05/20/1999',
        'email': 'test123@gmail.com'
      });
      databaseService.updateUserData(tUserData); //should only update doc tUser.uid
      final collectionRef = await instance.collection('users').get();
      final docRef = await instance.collection('users').doc(tUser.uid).get();
      final docRef2 = await instance.collection('users').doc('some-random-uid').get();

      expect(collectionRef.size, 2);
      expect(docRef['name'], tUserData.name);
      expect(docRef['lastName'], tUserData.lastName);
      expect(docRef['email'], tUserData.email);
      expect(docRef['dob'], '11/03/2021');
      //docRef2 should not have the same value
      expect(docRef2['name'], isNot(tUserData.name));
      expect(docRef2['lastName'], isNot(tUserData.lastName));
      expect(docRef2['email'], isNot(tUserData.email));
      expect(docRef2['dob'], isNot('11/03/2021'));
    });

    test('get userData returns a MyUserData object', () async {
      //set up a document
      instance.collection('users').doc(tUser.uid).set({
        'name': tUserData.name,
        'lastName': tUserData.lastName,
        'dob': tUserData.dob,
        'email': tUserData.email
      });

      MyUserData realUserData = await databaseService.userData;
      expect(realUserData, tUserData);
    });

    test('get userData returns a MyUserData with empty fields except uid when document not found', () async {
      instance.collection('users').doc(tUser.uid).delete();
      MyUserData realUserData = await databaseService.userData;

      expect(realUserData.uid, tUserData.uid);
      expect(realUserData.email, '');
      expect(realUserData.name, '');
      expect(realUserData.dob, '');
      expect(realUserData.lastName, '');
    });
  });
}
