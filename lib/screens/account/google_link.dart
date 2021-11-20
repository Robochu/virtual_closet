
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLinking extends StatelessWidget{

  linkGoogle() async {


  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AlertDialog(
      title: const Text("Allow access to Google Calendar"),
      content: const Text("The app will have access to your Google Calendar. Do you wish to continue?"),
      actions: [
        TextButton(
          onPressed: () {
            linkGoogle();
          },
          child: const Text("CONTINUE"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("CANCEL"),
        ),
      ],
      )
    );
  }

}