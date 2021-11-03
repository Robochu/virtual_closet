import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:virtual_closet/service/fire_auth.dart';
import 'mock.dart';


final tUser = MockUser(
  isAnonymous: false,
  uid: 'T3STU1D',
  email: 'testing.unit@gmail.com',
  displayName: 'UnitTest',
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

  });
}
