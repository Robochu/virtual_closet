import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:virtual_closet/screens/authentication/auth_screen.dart';
import 'package:virtual_closet/screens/home/home.dart';
import '../models/user.dart';

/*
 * Class to handle switching between authentication and homepage.
 * Provider.of<MyUser> automatically detects authentication status and call appropriate screen
 */
class Wrapper extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);

    if(user == null) {
      return AuthenticateScreen();
    } else {
      return MyHomePage(title: 'Virtual Closet App', user: user);
    }
  }

}