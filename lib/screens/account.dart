import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtual_closet/service/fire_auth.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtual_closet/main.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  static final FirebaseAuth auth = FirebaseAuth.instance;

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  User? user;

  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    name = user?.displayName;
    email = user?.email;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView(children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Text(
              'My Account',
              style: optionStyle
            )
          ),
          Container(
            child: Text(
                name!,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            )
          ),
          Container(
            child: Text(
              email!,
              style: TextStyle(fontSize: 20)
            )
          ),
          TextButton(
              onPressed: () {
                try {
                  auth.sendPasswordResetEmail(email: user!.email!);
                  print("Sent password reset email!");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Sent password reset email")
                  ));
                }
                on FirebaseAuthException catch(e) {
                  if (e.code == "auth/invalid-email") {
                    print("Invalid email");
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Please enter valid email")
                    ));
                  }
                }
              },
              style: TextButton.styleFrom(
                primary: Colors.blue,
              ),
              child: Text('Reset Password'))
        ])
      )
    );
  }
}