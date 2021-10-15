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
          title: Text('Virtual Closet'),
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(children: <Widget>[
              Column(
                children: [
                  Text('Login'),
                ],
              ),
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
                  controller: emailText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
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
                      Authentication.forgotPassword(email: emailText.text, context: context);
                    }
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.blue,
                  ),
                  child: Text('Forgot Password')),
              Container(
                  height: 50,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                    ),
                    child: Text('Login'),
                    onPressed: () {
                      print("Login functionality here");
                      if (emailText.text == "") {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Enter email")
                        ));
                      }
                      else if (passwordText.text == "") {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Enter password")
                        ));
                      }
                      else {
                        Future<MyUser?> user =
                        Authentication.signInWithEmailPassword(
                            email: emailText.text,
                            password: passwordText.text,
                            context: context);
                      }
                      /*user.then((value) async {
                        if (value?.email != null) {
                          print(value?.email);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MyHomePage(
                                      title: 'Virtual Closet Home',
                                      user: value!,
                                    )),
                          );
                        }
                        else {
                          print("Null email; login failed");
                        }
                      });*/
                    },
                  )),
              Container(
                  child: Row(
                    children: <Widget>[
                      Text('New User?'),
                      TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.blue,
                          ),
                          child: Text(
                            'Sign up',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () => {
                            widget.toggleView(),
                            /*
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),*/
                          })
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ))
            ])));
  }
}