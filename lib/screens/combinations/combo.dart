import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_closet/clothes.dart';
import 'dart:math' as math;
import 'package:virtual_closet/models/user.dart';
import 'package:virtual_closet/screens/combinations/designer.dart';
import 'package:virtual_closet/service/database.dart';
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
          builder: (context) => Designer(
            outfit: Outfit("", [], ''),
          ),
        ));
  }



  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);
    return StreamBuilder<List<Outfit>>(
        stream: DatabaseService(uid: user!.uid).outfits,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Outfit>? outfits = snapshot.data;
            return Scaffold(
                body: Column(children: <Widget>[
              const SizedBox(height: 30),
              Center(
                  child: ElevatedButton(
                onPressed: () => press(context),
                child: const Text("Design an outfit",
                    style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              )),
                  outfits!.isEmpty ?
                      const Center(
                        child: Text("You don't have any outfit combination yet. Let's design some!")
                      )
                      : Expanded(child: GridView.count(
                      crossAxisCount: 2,
                      // Generate 100 widgets that display their index in the List.
                      children: List.generate(
                          outfits.length, (index) {

                        return InkWell(
                          child: Padding (
                              padding: const EdgeInsets.all(15),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    constraints: const BoxConstraints.expand(
                                      height: 200.0,
                                    ),
                                    alignment: Alignment.center,

                                    decoration: BoxDecoration(
                                      //can't display preview image because query is not fast enough
                                      color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)
                                    ),
                                    child: Text((outfits[index].name == '') ? 'Outfit' : outfits[index].name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                            color: Colors.white,
                                            /*
                                            shadows: [
                                              Shadow (
                                                  blurRadius: 10.0,
                                                  color: Colors.black
                                              )
                                            ]*/
                                        )
                                    )
                                  )
                              )),
                          onTap: () {Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Designer(
                                  outfit: outfits[index],
                                ),
                              ));},
                        );
                      }
                  )))
            ]));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
