import 'package:flutter/material.dart';
import 'package:virtual_closet/clothes.dart';
import 'package:virtual_closet/screens/combinations/designer.dart';
import 'outfit.dart';

class Combo extends StatefulWidget {
  const Combo({Key? key}) : super(key: key);

  @override
  State<Combo> createState() => _ComboState();
}

class _ComboState extends State<Combo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  void press(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Designer(outfit: Outfit("", []),),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column (
            children: <Widget>[
              const SizedBox(height: 30),
              Center(
                  child: ElevatedButton(
                    onPressed: () => press(context),
                    child: const Text(
                        "Design an outfit",
                        style: TextStyle(fontSize: 20)
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        )
                    ),
                  )
              )
            ]
        )
    );
  }
}