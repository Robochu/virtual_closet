import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_closet/service/database.dart';
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
  late DateTime dob;

  late String? initName;

  @override
  void initState() {
    super.initState();
    initName = user?.displayName;
    user = auth.currentUser;
    name = user?.displayName;
    email = user?.email;
    nameController = TextEditingController();
    lastNameController = TextEditingController();
  }

  final _formKey = GlobalKey<FormState>();

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
        body: SafeArea(
            child: Column(children: <Widget>[
          buildPersonalDetails(context),
          buildPrivacy(context),
        ])));
  }

  Widget buildPersonalDetails(BuildContext context) {
    return StreamBuilder<MyUserData>(
        stream: DatabaseService(uid: user!.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            MyUserData? data = snapshot.data;
            nameController.value = data!.name;
            lastNameController.value = data.lastName;
            dob = data.dob;
            return Container(
                width: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    )),
                child: Form(
                    key: _formKey,
                    child: ListView(children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Text("Personal details",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: _isEditable?
                                const Icon(Icons.check)
                                : const Icon(Icons.edit),
                                onPressed: () {
                                  setState(() {

                                    _isEditable = true;
                                  });
                                },
                              )),
                        ],
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Email",
                        ),
                        enabled: false,
                        initialValue: email,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "First name",
                        ),
                        enabled: _isEditable,
                        controller: nameController,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Last name",
                        ),
                        enabled: _isEditable,
                        controller: lastNameController,
                      ),
                      TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Date of birth",
                          ),
                          enabled: _isEditable,
                          onTap: () {
                            showDatePicker(
                                context: context,
                                initialDate: dob,
                                firstDate: DateTime(1970),
                                lastDate: DateTime.now())
                            .then((selectedDate) {

                            });
                          }),
                      Container(
                          child: Text(email!, style: TextStyle(fontSize: 20))),
                    ])));
          } else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }

  Widget buildPrivacy(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
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
                primary: Colors.blue,
              ),
              child: Text('Reset Password')),
          TextButton(onPressed: () {}, child: const Text("Delete account"))
        ],
      ),
    );
  }
}
