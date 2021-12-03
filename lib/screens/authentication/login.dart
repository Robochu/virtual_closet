import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtual_closet/service/fire_auth.dart';
import 'package:virtual_closet/models/user.dart';

class Login extends StatefulWidget {
  const Login({Key? key, required this.toggleView}) : super(key: key);
  final Function toggleView;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController emailText = TextEditingController();
  TextEditingController passwordText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Virtual Closet'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(children: <Widget>[
              Column(
                children: const [
                  Text('Login'),
                ],
              ),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Virtual Closet',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 36),
                  )),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: emailText,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: passwordText,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                  obscureText: true,
                ),
              ),
              TextButton(
                  onPressed: () {
                    //print("Open forgot password screen");
                    if (emailText.text == "") {
                      print("Enter email");
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Enter email")
                      ));
                    }
                    else {
                      Authentication(auth: FirebaseAuth.instance).forgotPassword(email: emailText.text, context: context);
                    }
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.blue,
                  ),
                  child: const Text('Forgot Password')),
              Container(
                  height: 50,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                    ),
                    child: const Text('Login'),
                    onPressed: () {
                      print("Login functionality here");
                      if (emailText.text == "") {
                        print("Enter email");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Enter email")
                        ));
                      }
                      else if (passwordText.text == ""){
                        print("Enter password");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Enter password")
                        ));
                      }
                      else {
                        Authentication(auth: FirebaseAuth.instance)
                            .signInWithEmailPassword(
                            email: emailText.text,
                            password: passwordText.text,
                            context: context);
                      }
                    },
                  )),

              Container(
                  child: Row(
                    children: <Widget>[
                      const Text('New User?'),
                      TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.blue,
                          ),
                          child: const Text(
                            'Sign up',
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