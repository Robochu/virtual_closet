import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtual_closet/screens/home/home.dart';
import 'package:virtual_closet/service/fire_auth.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:virtual_closet/main.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key, required this.toggleView}) : super(key: key);
  final Function toggleView;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController nameText = TextEditingController();
  TextEditingController emailText = TextEditingController();
  TextEditingController passwordText = TextEditingController();
  TextEditingController confirmPasswordText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Virtual Closet'),
        ),
        body:
        Padding(
            padding: EdgeInsets.all(10),
            child: ListView(children: <Widget>[
              /*FutureBuilder(
                future: _initializeFirebase(),
                builder: (BuildContext context,
                    AsyncSnapshot<FirebaseApp> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      children: [
                        Text('Login'),
                      ],
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),*/
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Virtual Closet',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 36),
                  )),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: nameText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Name',
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: emailText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Email',
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: passwordText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Password',
                  ),
                  obscureText: true,
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: confirmPasswordText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Password Again',
                  ),
                  obscureText: true,
                ),
              ),
              Container(
                  height: 50,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                    ),
                    child: Text('Done'),
                    onPressed: () {
                      if ((nameText.text == null) || (nameText.text == "")) {
                        print("Please enter a name");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Please enter a name")
                        ));
                      }
                      else if (emailText.text == "") {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Please enter an email")
                        ));
                      }
                      else if (passwordText.text == "") {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Please enter a password")
                        ));
                      }
                      else {
                        if (passwordText.text == confirmPasswordText.text) {
                          Future<MyUser?> user = Authentication(auth: FirebaseAuth.instance)
                              .registerWithEmailPassword(
                              name: nameText.text,
                              email: emailText.text,
                              password: passwordText.text,
                              context: context);
                          user.then((value) async {
                            if ((value != null) && (value.uid != null)) {
                              //don't call navigator to prevent stacking up, auth_screen is taking care of navigate to home screen after signup/login

                            }
                            else {
                              print("Null email; sign up failed");
                              /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("Invalid email")
                              ));*/
                            }
                          });
                        }
                        else {
                          print("Passwords must match");
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Passwords must match")
                          ));
                        }
                      }
                    },
                  )),
              Container(
                  child: Row(
                    children: <Widget>[
                      Text('Have an account?'),
                      TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.blue,
                          ),
                          child: Text(
                            'Login here',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () => {
                            widget.toggleView(),

                          })
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ))
            ])));
  }
}