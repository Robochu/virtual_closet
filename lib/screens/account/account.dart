import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtual_closet/screens/account/google_link.dart';
import 'package:virtual_closet/screens/account/preference.dart';
import 'package:virtual_closet/screens/account/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtual_closet/service/fire_auth.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  final Authentication _auth = Authentication(auth: FirebaseAuth.instance);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(children: <Widget>[
          ListTile(
            trailing: const Icon(Icons.arrow_forward_rounded),
            title: const Text("Account"),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
          ListTile(
              trailing: const Icon(Icons.arrow_forward_rounded),
              title: const Text("Preferences"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PreferencePage()));
              }),
          /*
          ListTile(
              trailing: const Icon(Icons.arrow_forward_rounded),
              title: const Text("Connect to Google"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => GoogleLinking()));
              }),*/
          Card(
            shape: RoundedRectangleBorder (borderRadius: BorderRadius.circular(10)),
            color: Colors.lightBlueAccent,
            child: FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text('Logout'),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
          ),
        ]));
  }
}
