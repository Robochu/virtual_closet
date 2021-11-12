import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtual_closet/account/google_link.dart';
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
      const ListTile(
        trailing: Icon(Icons.arrow_forward_rounded),
        title: const Text("Preferences"),
      ),
      ListTile(
          trailing: const Icon(Icons.arrow_forward_rounded),
          title: const Text("Connect to Google"),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => GoogleLinking()));
        }),

    ]));
  }
}


