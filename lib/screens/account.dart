import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:virtual_closet/service/database.dart';
import 'package:virtual_closet/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        trailing: Icon(Icons.arrow_forward_rounded),
        title: const Text("Account"),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ProfilePage()));
        },
      ),
      const ListTile(
        trailing: Icon(Icons.arrow_forward_rounded),
        title: Text("Preferences"),
      ),
      const ListTile(
          trailing: Icon(Icons.arrow_forward_rounded),
          title: Text("Connect to Google"))
    ]));
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static final FirebaseAuth auth = FirebaseAuth.instance;

  User? user;
  bool _isEditable = false;
  String? name;
  String? email;
  late final nameController;
  late final lastNameController;
  late String dob;
  final DateFormat dateFormat = DateFormat("MM/dd/yyyy");

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    email = user?.email;
    nameController = TextEditingController();
    lastNameController = TextEditingController();
  }
  final _formKey1 = GlobalKey<FormState>();
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    lastNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text("My Account"),
        ),
        body: Padding(
            padding: EdgeInsets.all(8.0),
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  buildPersonalDetails(context),
                  SizedBox(height: 20),
                  buildPrivacy(context),
                ]))));
  }

  Widget buildPersonalDetails(BuildContext context) {

    return StreamBuilder<MyUserData>(
        stream: DatabaseService(uid: user!.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            MyUserData? data = snapshot.data;
            nameController.text = data!.name;
            lastNameController.text = data.lastName;
            dob = data.dob;
            return Container(
                height: 320,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    )),
                child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Form(
                        key: _formKey1,
                        child: Column(children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text("Personal details",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    iconSize: 18,
                                    icon: _isEditable
                                        ? const Icon(Icons.check)
                                        : const Icon(Icons.edit),
                                    onPressed: () async {
                                      if (_formKey1.currentState!.validate()) {
                                          data.name = nameController.text;
                                          data.lastName = nameController.text;
                                          await DatabaseService(uid: user!.uid)
                                              .updateUserData(data);

                                      }
                                      setState(() {
                                        _isEditable = !_isEditable;
                                      });
                                    },
                                  )),
                            ],
                          ),
                          TextFormField(

                            style: TextStyle(fontSize: 15),
                            decoration: const InputDecoration(
                              labelText: "Email",
                              //contentPadding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0)
                            ),
                            enabled: false,
                            initialValue: email,
                          ),
                          TextFormField(
                            autofocus: true,
                            style: TextStyle(fontSize: 15),
                            decoration: const InputDecoration(
                                labelText: "First name",
                                labelStyle: TextStyle(fontSize: 15)),
                            enabled: _isEditable,
                            controller: nameController,
                          ),
                          TextFormField(
                            autofocus: true,
                            style: TextStyle(fontSize: 15),
                            decoration: const InputDecoration(
                                labelText: "Last name",
                                labelStyle: TextStyle(fontSize: 15)),
                            enabled: _isEditable,
                            controller: lastNameController,
                          ),
                          TextFormField(
                              autofocus: true,
                              style: TextStyle(fontSize: 15),
                              decoration: const InputDecoration(
                                  labelText: "Date of birth",
                                  labelStyle: TextStyle(fontSize: 15)),
                              initialValue: dob,
                              enabled: _isEditable,
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) => Container(
                                        height: 150,
                                        child: Column(children: [
                                          TextButton(
                                              style: TextButton.styleFrom(
                                                  minimumSize: Size.zero,
                                                  padding: EdgeInsets.zero,
                                                  alignment:
                                                      Alignment.topRight),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Save")),
                                          Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  3,
                                              child: CupertinoDatePicker(
                                                  initialDateTime:
                                                      DateTime.now(),
                                                  maximumYear: 2030,
                                                  minimumYear: 1970,
                                                  mode: CupertinoDatePickerMode
                                                      .date,
                                                  onDateTimeChanged:
                                                      (DateTime newdate) {
                                                    setState(() {
                                                      dob = dateFormat
                                                          .format(newdate);
                                                    });
                                                  }))
                                        ])));
                              }),
                        ]))));
          } else {
            return Center(
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                      width: 2,
                    )),
                    height: MediaQuery.of(context).size.height * 0.45,
                    width: MediaQuery.of(context).size.width * 0.9));
          }
        });
  }

  Widget buildPrivacy(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.96,
        height: 120,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 1,
            )),
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
          child: Wrap(
            direction: Axis.vertical,
            spacing: -5,
            children: <Widget>[
              const Text("Privacy",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                  onPressed: () {
                    try {
                      auth.sendPasswordResetEmail(email: user!.email!);
                      print("Sent password reset email!");
                    } on FirebaseAuthException catch (e) {
                      if (e.code == "auth/invalid-email") {
                        print("Invalid email");
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.topLeft),
                  child: const Text('Reset Password',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ))),
              TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, alignment: Alignment.topLeft),
                  child: const Text("Delete account",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      )))
            ],
          ),
        ));
  }
}
