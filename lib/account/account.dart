import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtual_closet/account/google_link.dart';
import 'package:virtual_closet/account/preference.dart';
import 'package:virtual_closet/account/profile.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
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
      ListTile(
          trailing: const Icon(Icons.arrow_forward_rounded),
          title: const Text("Connect to Google"),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => GoogleLinking()));
          }),
    ]));
  }
}
