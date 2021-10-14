import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_closet/models/user.dart';
import '../../clothes.dart';
import '../../service/database.dart';
import 'package:virtual_closet/screens/closet/closet.dart';


//listen for changes in the user's collection and update the closet UI
class ClosetWatcher extends StatelessWidget {
  const ClosetWatcher({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);
    return Closet(uid: user!.uid);
  }

}