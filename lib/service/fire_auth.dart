import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'database.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  Authentication({required this.auth});
  final FirebaseAuth auth;

  static MyUser? _createUser(User? user) {
    if (user != null) {
      return MyUser(user.uid);
    }
    return null;
  }
  MyUser? get currentUser {
    return _createUser(auth.currentUser);
  }
  //create a stream to listen to authentication status changes
  Stream<MyUser?> get user {
    return auth.authStateChanges().map(_createUser);
  }

  Future<MyUser?> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
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
      if (user != null) {
        MyUserData? myUser = MyUserData(lastName: '', name: name, dob: '', email: email);
        await DatabaseService(uid: user.uid).updateUserData(myUser);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('This password is too weak');
        return Future<MyUser?>.value(null);
      } else if (e.code == 'email-already-in-use') {
        print('Account already exists for this email');
        return Future<MyUser?>.value(null);
      }
    } catch (e) {
      print(e);
    }
    return _createUser(user);
  }

  Future<MyUser?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        return Future<MyUser?>.value(null);
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
        return Future<MyUser?>.value(null);
      }
    }
    return _createUser(user);
  }

  void forgotPassword({required String email}) async {
    try {
      auth.sendPasswordResetEmail(email: email);
      print("Sent password reset email!");
    } on FirebaseAuthException catch (e) {
      if (e.code == "auth/invalid-email") {
        print("Invalid email");
      }
    }
  }



  Future signOut() async {
    try {
      User? user = auth.currentUser;
        return await auth.signOut();

    } catch (e) {
      print(e);
      return null;
    }
  }
}
