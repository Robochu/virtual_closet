import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'database.dart';

class Authentication {
  static Future<User?> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
      user!.updateDisplayName(name);
      user = auth.currentUser;

      //create a document for this user in database
      if(user != null) {
        await DatabaseService(user.uid).updateUserData(email);
      }

    } on FirebaseAuthException catch(e) {
      if (e.code == 'weak-password') {
        print('This password is too weak');
        return Future<Null>.value(null);
      } else if (e.code == 'email-already-in-use') {
        print('Account already exists for this email');
        return Future<Null>.value(null);
      }
    } catch(e) {
      print(e);
    }
    return user;
  }

  static Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch(e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        return Future<Null>.value(null);
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
        return Future<Null>.value(null);
      }
    }
    return user;
  }
}