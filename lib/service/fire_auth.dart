import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'database.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static MyUser? _createUser(User? user) {
    if (user != null) {
      return MyUser(user.uid);
    }
    return null;
  }

  //create a stream to listen to authentication status changes
  Stream<MyUser?> get user {
    return auth.authStateChanges().map(_createUser);
  }

  static Future<MyUser?> registerWithEmailPassword({
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
        await DatabaseService(uid: user.uid).updateUserData(name, email);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('This password is too weak');
        return Future<Null>.value(null);
      } else if (e.code == 'email-already-in-use') {
        print('Account already exists for this email');
        return Future<Null>.value(null);
      }
    } catch (e) {
      print(e);
    }
    return _createUser(user);
  }

  static Future<MyUser?> signInWithEmailPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        return Future<Null>.value(null);
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
        return Future<Null>.value(null);
      }
    }
    return _createUser(user);
  }

  static void forgotPassword({required String email}) async {
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
      User? user = await auth.currentUser;
        return await auth.signOut();

    } catch (e) {
      print(e);
      return null;
    }
  }
}
