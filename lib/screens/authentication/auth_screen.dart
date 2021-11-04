import 'package:flutter/cupertino.dart';
import 'package:virtual_closet/screens/authentication/login.dart';
import 'package:virtual_closet/screens/authentication/signup.dart';
class AuthenticateScreen extends StatefulWidget {
  @override
  _AuthenticateScreenState createState() => _AuthenticateScreenState();
}

class _AuthenticateScreenState extends State<AuthenticateScreen> {

  bool showLogin = true;
  void toggleView(){
    //print(showSignIn.toString());
    setState(() => showLogin = !showLogin);
  }

  @override
  Widget build(BuildContext context) {
    if (showLogin) {
      return Login(toggleView:  toggleView);
    } else {
      return SignUpPage(toggleView:  toggleView);
    }
  }
}