import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:virtual_closet/models/user.dart';
import 'service/fire_auth.dart';
import 'package:provider/provider.dart';
import 'screens/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<MyUser?>.value(
        value: Authentication(auth: FirebaseAuth.instance).user,
        initialData: null,
        child: MaterialApp(
          title: 'Virtual Closet',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Wrapper(),
        ));
  }
}




