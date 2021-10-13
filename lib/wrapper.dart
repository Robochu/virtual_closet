import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:virtual_closet/auth_screen.dart';

import 'main.dart';
import 'models/user.dart';

class Wrapper extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);

    if(user == null) {
      return AuthenticateScreen();
    } else {
      return MyHomePage(title: 'Virtual Closet App');
    }
  }

}